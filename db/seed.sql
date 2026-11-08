-- Plop fake demo data. Run AFTER db/schema.sql, in Supabase: SQL Editor > New query > paste > Run.
-- Safe to re-run: it deletes the previous demo accounts first, then rebuilds them with dates
-- relative to today, so re-run it on demo day to make "logged today" fresh.
--
-- What it makes (all fake: ids start with "demo|", invite codes start with "demo"):
--   * Zan, Chloe and Mo: buddies with each other, a month of logs, streaks, ranks and cheers.
--   * 12 fake players with made-up handles, for a fuller database.
--   * demo_join(user): the server calls it for Record > Demo settings > Add demo buddies, so
--     you become buddies with Zan, Chloe and Mo, and Zan cheers you.
-- Real users are never touched.

-- Local "today" for the hackathon (Pacific Time, UBC). Change if you demo somewhere else.
create or replace function public.demo_today() returns date
language sql stable as $$ select (now() at time zone 'America/Vancouver')::date $$;

-- ---------- wipe old demo accounts (cascades to every Plop row they own) ----------
delete from public.profiles where id like 'demo|%';

-- ---------- build ----------
do $$
declare
  t date := public.demo_today();
  -- name, handle, invite code, mascot, tier, div, gp, streak length, logged today?, check-in time
  people jsonb := '[
    ["Zan",   "SwiftPlum3",  "demozan1", "#B5764A", 4, 1, 62, 23, true,  "08:12"],
    ["Chloe", "HappyYam5",   "demochl1", "#8E9CCB", 3, 3, 40,  6, true,  "10:40"],
    ["Mo",    "BoldPear71",  "demomoo1", "#8DB08F", 2, 1, 85,  4, false, null],
    ["",      "CosmicFig88", "demo0001", "#B5764A", 6, 1, 90, 41, true,  "07:05"],
    ["",      "BraveBean9",  "demo0002", "#8E9CCB", 6, 1, 55, 37, true,  "06:48"],
    ["",      "SunnyKiwi12", "demo0003", "#8DB08F", 6, 2, 70, 30, true,  "09:15"],
    ["",      "CalmMango4",  "demo0004", "#B5764A", 5, 1, 20, 22, false, null],
    ["",      "LuckyOat60",  "demo0005", "#8E9CCB", 5, 2, 45, 19, true,  "11:30"],
    ["",      "ZenBeet23",   "demo0006", "#8DB08F", 5, 3, 10, 15, true,  "08:55"],
    ["",      "MightyLeek8", "demo0007", "#B5764A", 4, 2, 80, 12, false, null],
    ["",      "TinyTaro41",  "demo0008", "#8E9CCB", 4, 3, 30,  9, true,  "12:10"],
    ["",      "NeatBasil2",  "demo0009", "#8DB08F", 3, 1, 65,  7, true,  "07:40"],
    ["",      "PlumpPea17",  "demo0010", "#B5764A", 3, 2, 15,  5, false, null],
    ["",      "GentleRye30", "demo0011", "#8E9CCB", 2, 2, 50,  3, true,  "10:05"],
    ["",      "QuietLeek77", "demo0012", "#8DB08F", 1, 3,  5,  2, false, null]
  ]';
  p jsonb;
  uid text;
  d date;
  k int;
  len int;
  sc int;
  br int;
  chip_pool text[] := array['Stress','New food','Travel','Bad sleep','Meds','Bloated'];
begin
  perform setseed(0.42);  -- same fake data every run
  for p in select * from jsonb_array_elements(people) loop
    uid := 'demo|' || lower(p->>1);
    insert into public.profiles (id, display_name, handle, invite_code, mascot, tier, div, gp, mode, league_joined, global_on, created_at)
    values (uid, p->>0, p->>1, p->>2, p->>3, (p->>4)::smallint, (p->>5)::smallint, (p->>6)::smallint, 'ranked', true, true, now() - interval '40 days');

    -- the current streak: consecutive days ending today (or yesterday if not logged today)
    len := (p->>7)::int;
    for k in 0 .. len - 1 loop
      d := (case when (p->>8)::boolean then t else t - 1 end) - k;
      br := (array[4,4,4,4,3,5,4,3,5,2,6])[1 + floor(random() * 11)::int];
      sc := greatest(35, least(98, (array[0,92,78,88,93,82,70,60])[1 + br] + floor(random() * 9)::int - 4));
      insert into public.entries (user_id, day, kind, score, bristol, colour, confidence, comfort, chips, blood, created_at)
      values (uid, d, case when random() < 0.85 then 'scan' else 'pick' end, sc, br,
              (array['brown','brown','light brown','dark brown'])[1 + floor(random() * 4)::int],
              round((0.65 + random() * 0.3)::numeric, 2), case when sc >= 80 then 0 when sc >= 60 then 1 else 2 end,
              case when random() < 0.2 then array[chip_pool[1 + floor(random() * 6)::int]] else '{}' end, false,
              ((d + coalesce((p->>9)::time, time '09:00')) at time zone 'America/Vancouver'));
      insert into public.gp_events (user_id, day, delta, reason)
      values (uid, d, 15 + case when sc >= 85 then 6 when sc >= 60 then 3 else 0 end, 'check-in');
    end loop;
    -- a few older logs before a gap, so streaks look real
    for k in len + 2 .. len + 8 loop
      d := t - k;
      insert into public.entries (user_id, day, kind, score, bristol, colour, confidence, comfort)
      values (uid, d, 'scan', 70 + floor(random() * 25)::int, 4, 'brown', 0.8, 0)
      on conflict do nothing;
    end loop;
  end loop;

  -- Zan, Chloe and Mo are all buddies
  insert into public.buddies (user_id, buddy_id)
  select a.id, b.id from public.profiles a, public.profiles b
  where a.invite_code in ('demozan1','demochl1','demomoo1') and b.invite_code in ('demozan1','demochl1','demomoo1') and a.id <> b.id;

  -- cheers today: Zan cheered Chloe and Mo, Chloe cheered Zan
  insert into public.cheers (from_id, to_id, day)
  select f.id, x.id, t from public.profiles f, public.profiles x
  where (f.invite_code, x.invite_code) in (('demozan1','demochl1'), ('demozan1','demomoo1'), ('demochl1','demozan1'));
end $$;

-- ---------- demo_join: make a user buddies with Zan, Chloe and Mo ----------
drop function if exists public.demo_join() cascade;
create or replace function public.demo_join(p_user text) returns int
language plpgsql as $$
declare n int;
begin
  insert into public.buddies (user_id, buddy_id)
  select p_user, p.id from public.profiles p where p.invite_code in ('demozan1','demochl1','demomoo1')
  union all
  select p.id, p_user from public.profiles p where p.invite_code in ('demozan1','demochl1','demomoo1')
  on conflict do nothing;
  get diagnostics n = row_count;
  -- Zan says hi
  insert into public.cheers (from_id, to_id, day)
  select p.id, p_user, public.demo_today() from public.profiles p where p.invite_code = 'demozan1'
  on conflict do nothing;
  return n / 2;
end $$;
do $$ begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'revoke all on function public.demo_join(text), public.demo_today() from public, anon, authenticated';
  end if;
end $$;

-- quick check
select display_name, handle, tier, div,
       (select count(*) from public.entries e where e.user_id = p.id) as logs
from public.profiles p where invite_code like 'demo%' order by tier desc, div;
