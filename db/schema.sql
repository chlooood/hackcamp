-- Plop database schema (Supabase Postgres)
-- Run once: Supabase dashboard > SQL Editor > New query > paste this file > Run (confirm the
-- "destructive operation" prompt: it drops old Plop tables first). Re-running WIPES Plop data.
--
-- Who talks to this database: only our own server (api/data.js), using DATABASE_URL.
-- Users log in with Auth0, so a user id is the Auth0 "sub" (for example "auth0|65ab..." or
-- "google-oauth2|1098..."). Phones never get database keys.
--
-- Privacy model (see context/architecture.md):
--   * Row level security is ON with no policies, so the public Supabase API keys can read nothing.
--   * The server only ever reads and writes the logged-in user's own rows.
--   * Buddies never read your entries. They only get activity through buddy_activity():
--     logged today, streak and rank, and only the parts you share. Pausing hides all of it.
--   * Photos are never stored anywhere. entries holds only the structured result.

-- ---------- clean slate ----------
drop function if exists public.ensure_profile() cascade;
drop function if exists public.ensure_profile(text, text) cascade;
drop function if exists public.current_streak(uuid, date) cascade;
drop function if exists public.current_streak(text, date) cascade;
drop function if exists public.buddy_activity(date) cascade;
drop function if exists public.buddy_activity(text, date) cascade;
drop function if exists public.accept_invite(text) cascade;
drop function if exists public.accept_invite(text, text) cascade;
drop function if exists public.remove_buddy(uuid) cascade;
drop function if exists public.remove_buddy(text, text) cascade;
drop function if exists public.delete_me() cascade;
drop function if exists public.demo_join() cascade;
drop function if exists public.demo_join(text) cascade;
drop function if exists public.touch_updated_at() cascade;
drop table if exists public.cheers cascade;
drop table if exists public.buddies cascade;
drop table if exists public.gp_events cascade;
drop table if exists public.entries cascade;
drop table if exists public.profiles cascade;

-- ---------- tables ----------
create table public.profiles (
  id            text primary key check (char_length(id) between 3 and 128),  -- Auth0 sub
  display_name  text not null default '' check (char_length(display_name) <= 40),
  handle        text not null unique,                      -- pseudonymous, for the global board
  invite_code   text not null unique default substr(md5(gen_random_uuid()::text), 1, 8),
  mascot        text not null default '#B5764A' check (mascot ~ '^#[0-9A-Fa-f]{6}$'),
  tier          smallint not null default 0 check (tier between 0 and 6),   -- 0 Iron .. 6 Mythic
  div           smallint not null default 3 check (div between 1 and 3),    -- 3 is the bottom division
  gp            smallint not null default 0 check (gp between 0 and 99),    -- GP inside the division
  shields       smallint not null default 2 check (shields between 0 and 2),
  mode          text not null default 'casual' check (mode in ('ranked', 'casual')),
  league_joined boolean not null default false,            -- opted in to ranked at least once
  share_checkin boolean not null default true,
  share_streak  boolean not null default true,
  share_rank    boolean not null default true,
  discreet      boolean not null default false,
  paused        boolean not null default false,
  global_on     boolean not null default false,            -- opt-in, separate switch
  plain_names   boolean not null default false,
  notes         text not null default '' check (char_length(notes) <= 2000),  -- "things to ask", private
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table public.entries (
  id          bigint generated always as identity primary key,
  user_id     text not null references public.profiles (id) on delete cascade,
  day         date not null,                               -- the user's local date
  kind        text not null check (kind in ('scan', 'pick')),
  score       smallint check (score between 0 and 100),    -- null for no-photo logs
  bristol     smallint check (bristol between 1 and 7),
  colour      text check (colour in ('brown','light brown','dark brown','yellow','green','pale','reddish','black','unclear')),
  confidence  real check (confidence between 0 and 1),
  comfort     smallint not null default 0 check (comfort between 0 and 3),
  chips       text[] not null default '{}',
  blood       boolean not null default false,
  created_at  timestamptz not null default now(),
  unique (user_id, day)
);

create table public.gp_events (
  id          bigint generated always as identity primary key,
  user_id     text not null references public.profiles (id) on delete cascade,
  day         date not null,
  delta       smallint not null,
  reason      text not null check (char_length(reason) <= 60),
  created_at  timestamptz not null default now()
);

-- Stored in both directions once an invite is accepted.
create table public.buddies (
  user_id     text not null references public.profiles (id) on delete cascade,
  buddy_id    text not null references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, buddy_id),
  check (user_id <> buddy_id)
);

create table public.cheers (
  from_id     text not null references public.profiles (id) on delete cascade,
  to_id       text not null references public.profiles (id) on delete cascade,
  day         date not null,
  created_at  timestamptz not null default now(),
  primary key (from_id, to_id, day)
);

create index entries_user_day on public.entries (user_id, day desc);
create index gp_events_user_day on public.gp_events (user_id, day desc);
create index cheers_to_day on public.cheers (to_id, day);

create function public.touch_updated_at() returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;
create trigger profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

-- ---------- lock the public API out ----------
-- RLS on with no policies: Supabase's anon/authenticated keys see nothing. Our server connects
-- as the table owner, which RLS does not apply to.
alter table public.profiles  enable row level security;
alter table public.entries   enable row level security;
alter table public.gp_events enable row level security;
alter table public.buddies   enable row level security;
alter table public.cheers    enable row level security;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'revoke all on public.profiles, public.entries, public.gp_events, public.buddies, public.cheers from anon, authenticated';
  end if;
end $$;

-- ---------- functions (called by the server with the logged-in user's id) ----------
-- Create (or fetch) a profile with a generated pseudonymous handle.
create function public.ensure_profile(p_user text, p_name text) returns public.profiles
language plpgsql as $$
declare
  p public.profiles;
  adj text[] := array['Quiet','Brave','Sunny','Cosmic','Swift','Happy','Bold','Calm','Lucky','Zen','Mighty','Tiny','Neat','Gentle','Plump'];
  noun text[] := array['Otter','Bean','Kiwi','Fig','Plum','Yam','Pear','Mango','Oat','Beet','Leek','Taro','Basil','Rye','Pea'];
  h text;
begin
  select * into p from public.profiles where id = p_user;
  if found then return p; end if;
  loop
    h := adj[1 + floor(random() * array_length(adj, 1))::int]
      || noun[1 + floor(random() * array_length(noun, 1))::int]
      || (1 + floor(random() * 99))::int;
    exit when not exists (select 1 from public.profiles where handle = h);
  end loop;
  insert into public.profiles (id, handle, display_name)
  values (p_user, h, left(coalesce(p_name, ''), 40))
  on conflict (id) do nothing;
  select * into p from public.profiles where id = p_user;
  return p;
end $$;

-- Consecutive logged days ending today (or yesterday, if today is not logged yet).
create function public.current_streak(p_user text, p_today date) returns int
language sql stable as $$
  with days as (
    select distinct day from public.entries where user_id = p_user and day <= p_today
  ), anchor as (
    select case when exists (select 1 from days where day = p_today) then p_today else p_today - 1 end as d
  ), numbered as (
    select day, row_number() over (order by day desc) as rn
    from days where day <= (select d from anchor)
  )
  -- walking back from the anchor, a day belongs to the streak while there is no gap
  select count(*)::int from numbered where day = (select d from anchor) - (rn - 1)::int;
$$;

-- What p_user may see about each buddy: activity only, filtered by that buddy's share switches.
create function public.buddy_activity(p_user text, p_today date)
returns table (
  buddy_id text, display_name text, mascot text,
  logged_today boolean, logged_at timestamptz, streak int,
  tier smallint, div smallint, cheered_me boolean, i_cheered boolean
)
language sql stable as $$
  select
    p.id,
    p.display_name,
    p.mascot,
    case when p.paused or not p.share_checkin then null
         else exists (select 1 from public.entries e where e.user_id = p.id and e.day = p_today) end,
    case when p.paused or not p.share_checkin then null
         else (select e.created_at from public.entries e where e.user_id = p.id and e.day = p_today) end,
    case when p.paused or not p.share_streak then null
         else public.current_streak(p.id, p_today) end,
    case when p.share_rank and p.mode = 'ranked' then p.tier end,
    case when p.share_rank and p.mode = 'ranked' then p.div end,
    exists (select 1 from public.cheers c where c.from_id = p.id and c.to_id = p_user and c.day = p_today),
    exists (select 1 from public.cheers c where c.from_id = p_user and c.to_id = p.id and c.day = p_today)
  from public.buddies b
  join public.profiles p on p.id = b.buddy_id
  where b.user_id = p_user
  order by p.display_name;
$$;

-- Opening an invite link is the accept. Links both ways. Returns the inviter's name.
create function public.accept_invite(p_user text, p_code text) returns text
language plpgsql as $$
declare inviter public.profiles;
begin
  select * into inviter from public.profiles where invite_code = lower(trim(p_code));
  if not found then raise exception 'invite not found'; end if;
  if inviter.id = p_user then raise exception 'that is your own invite'; end if;
  insert into public.buddies (user_id, buddy_id) values (p_user, inviter.id), (inviter.id, p_user)
    on conflict do nothing;
  return inviter.display_name;
end $$;

-- Removing is silent and immediate, both directions. Cheers between you go too.
create function public.remove_buddy(p_user text, p_buddy text) returns void
language sql as $$
  delete from public.buddies
   where (user_id = p_user and buddy_id = p_buddy)
      or (user_id = p_buddy and buddy_id = p_user);
  delete from public.cheers
   where (from_id = p_user and to_id = p_buddy)
      or (from_id = p_buddy and to_id = p_user);
$$;

-- Nobody outside the server may call these.
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.ensure_profile(text, text), public.current_streak(text, date), public.buddy_activity(text, date), public.accept_invite(text, text), public.remove_buddy(text, text) from public, anon, authenticated';
  end if;
end $$;
