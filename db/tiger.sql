-- Plop on Tiger Data (Tiger Cloud: Postgres + TimescaleDB).
-- Run order on a fresh Tiger service:  db/schema.sql  ->  db/tiger.sql  ->  db/seed.sql
-- (npm run db:tiger does all three.) Re-running schema.sql wipes Plop data, then run this again.
--
-- What Tiger adds for Plop, whose data is a daily time series (one log a day, Deuces over time):
--   * entries and gp_events become hypertables, split into weekly chunks by day.
--   * Old chunks are compressed (columnstore) after 90 days, so a year of logs stays small.
--   * weekly_deuces is a continuous aggregate: Deuces per player per week, kept up to date by
--     Tiger itself. It powers the real global board (api/data.js op "board").
--   * daily_community is a continuous aggregate of check-ins and average score per day.

create extension if not exists timescaledb;

-- A hypertable's unique keys must include its time column, so the id-only primary keys become
-- (id, day). unique (user_id, day) on entries already includes day.
alter table public.entries   drop constraint entries_pkey,   add primary key (id, day);
alter table public.gp_events drop constraint gp_events_pkey, add primary key (id, day);

select create_hypertable('public.entries',   by_range('day', interval '7 days'), migrate_data => true);
select create_hypertable('public.gp_events', by_range('day', interval '7 days'), migrate_data => true);

-- ---------- compression ----------
-- Columnstore compression can't be used on tables with row level security. RLS only existed to
-- lock out Supabase's public API keys; Tiger has no public data API and only our server (the
-- table owner, which RLS never applied to) connects, so the time-series tables drop it here.
alter table public.entries   disable row level security;
alter table public.gp_events disable row level security;
alter table public.entries set (
  timescaledb.compress, timescaledb.compress_segmentby = 'user_id', timescaledb.compress_orderby = 'day desc, id');
alter table public.gp_events set (
  timescaledb.compress, timescaledb.compress_segmentby = 'user_id', timescaledb.compress_orderby = 'day desc, id');
select add_compression_policy('public.entries',   interval '90 days');
select add_compression_policy('public.gp_events', interval '90 days');

-- ---------- continuous aggregates ----------
-- Weeks start on Monday (time_bucket's default origin is Monday 2000-01-03).
create materialized view public.weekly_deuces
with (timescaledb.continuous, timescaledb.materialized_only = false) as
select time_bucket(interval '7 days', day) as week, user_id, sum(delta)::int as deuces, count(*)::int as events
from public.gp_events
group by week, user_id
with no data;

create materialized view public.daily_community
with (timescaledb.continuous, timescaledb.materialized_only = false) as
select time_bucket(interval '1 day', day) as day, count(*)::int as checkins, round(avg(score))::int as avg_score
from public.entries
group by 1
with no data;

-- Refresh the last two months every 15 minutes; anything newer is added live at query time.
select add_continuous_aggregate_policy('public.weekly_deuces',   start_offset => interval '60 days', end_offset => interval '1 day', schedule_interval => interval '15 minutes');
select add_continuous_aggregate_policy('public.daily_community', start_offset => interval '60 days', end_offset => interval '1 day', schedule_interval => interval '15 minutes');

-- ---------- the global board ----------
-- Top players this week by Deuces, only people who switched on "Show me on the global board".
-- Returns pseudonymous handles only. me_rank is p_user's place (null if hidden or no Deuces).
create or replace function public.global_board(p_user text, p_today date, p_limit int default 100)
returns table (pos int, handle text, mascot text, deuces int, is_me boolean, players int)
language sql stable as $$
  with wk as (
    select w.user_id, sum(w.deuces)::int as deuces
    from public.weekly_deuces w
    where w.week = time_bucket(interval '7 days', p_today)
    group by w.user_id
  ), ranked as (
    select p.id, p.handle, p.mascot, wk.deuces,
           (rank() over (order by wk.deuces desc, p.handle))::int as pos
    from wk join public.profiles p on p.id = wk.user_id
    where p.global_on and not p.paused
  )
  select r.pos, r.handle, r.mascot, r.deuces, r.id = p_user, (select count(*)::int from ranked)
  from ranked r
  where r.pos <= p_limit or r.id = p_user
  order by r.pos;
$$;

-- ---------- logins (written by api/auth.js after each successful Auth0 login) ----------
-- One row per login: who (Auth0 sub), when, and which provider (google-oauth2, auth0, ...).
-- No email, no IP, no tokens. Rows older than 180 days are dropped automatically, and deleting
-- your account removes yours at once (cascade from profiles).
drop table if exists public.logins cascade;
create table public.logins (
  user_id   text not null references public.profiles (id) on delete cascade,
  at        timestamptz not null default now(),
  provider  text not null default '' check (char_length(provider) <= 40)
);
select create_hypertable('public.logins', by_range('at', interval '7 days'));
create index logins_user_at on public.logins (user_id, at desc);
select add_retention_policy('public.logins', interval '180 days');

-- Daily active players, kept up to date by Tiger.
create materialized view public.daily_logins
with (timescaledb.continuous, timescaledb.materialized_only = false) as
select time_bucket(interval '1 day', at) as day, count(distinct user_id)::int as players, count(*)::int as logins
from public.logins
group by 1
with no data;
select add_continuous_aggregate_policy('public.daily_logins', start_offset => interval '30 days', end_offset => interval '1 hour', schedule_interval => interval '15 minutes');

-- Called once per login: make sure the profile exists, record the login, return the profile.
create or replace function public.record_login(p_user text, p_name text, p_provider text)
returns public.profiles language plpgsql as $$
declare p public.profiles;
begin
  p := public.ensure_profile(p_user, p_name);
  insert into public.logins (user_id, provider) values (p_user, left(coalesce(p_provider, ''), 40));
  return p;
end $$;
