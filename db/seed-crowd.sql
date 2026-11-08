-- Plop fake crowd: 240 made-up players so the global board, tiers and Tiger's summaries look
-- like a real community. Run AFTER db/seed.sql (npm run db:tiger does). Safe to re-run: it
-- deletes the previous crowd first. All fake: ids start with "demo|crowd", no real people.
--
-- Each player gets a habit (how often they log), so the data looks lived-in:
--   * 45 days of logs and Deuces, scores that fit the Bristol type, a few skipped days
--   * a tier that roughly matches how steady they are
--   * logins on the days they logged (Tiger "logins" hypertable)
--   * about 70% show up on the global board; the rest keep it off

delete from public.profiles where id like 'demo|crowd%';

do $$
declare
  t date := public.demo_today();
  adj  text[] := array['Quiet','Brave','Sunny','Cosmic','Swift','Happy','Bold','Calm','Lucky','Zen','Mighty','Tiny','Neat','Gentle','Plump','Fuzzy','Jolly','Spicy','Breezy','Merry'];
  noun text[] := array['Otter','Bean','Kiwi','Fig','Plum','Yam','Pear','Mango','Oat','Beet','Leek','Taro','Basil','Rye','Pea','Lentil','Prune','Bran','Chia','Quinoa'];
  first text[] := array['Ava','Ben','Cleo','Dev','Eli','Fay','Gus','Hana','Ivan','Jade','Kai','Lena','Milo','Nia','Omar','Pia','Quinn','Ravi','Sana','Theo','Uma','Vik','Wren','Yuki','Zara'];
  mascots text[] := array['#B5764A','#8DB08F','#8E9CCB'];
  chip_pool text[] := array['Stress','New food','Travel','Bad sleep','Meds','Bloated','Cramps'];
  i int; k int; uid text; habit real; d date; br int; sc int; logs int; tier int; scanned boolean;
begin
  perform setseed(0.7);  -- same crowd every run
  for i in 1 .. 240 loop
    uid := 'demo|crowd' || lpad(i::text, 3, '0');
    habit := 0.25 + random() * 0.72;                     -- chance of logging on a given day
    tier := least(6, greatest(0, floor(power(habit, 1.7) * 6.4 + random() * 1.4 - 0.5)::int));  -- most players sit mid-ladder
    insert into public.profiles (id, display_name, handle, invite_code, mascot, tier, div, gp, mode, league_joined, global_on, created_at)
    values (uid,
            case when random() < 0.6 then first[1 + floor(random() * array_length(first, 1))::int] else '' end,
            adj[1 + floor(random() * 20)::int] || noun[1 + floor(random() * 20)::int] || (100 + i)::text,
            'democ' || lpad(i::text, 3, '0'),
            mascots[1 + floor(random() * 3)::int],
            tier, 1 + floor(random() * 3)::int, floor(random() * 99)::int,
            case when random() < 0.8 then 'ranked' else 'casual' end, true,
            random() < 0.7,
            now() - make_interval(days => 46 + floor(random() * 60)::int));
    logs := 0;
    for k in 0 .. 44 loop
      d := t - k;
      -- today only for some (it's still early), and steady players skip less
      continue when (k = 0 and random() > habit * 0.8) or random() > habit;
      br := (array[4,4,4,4,4,3,5,3,5,2,6,1,7])[1 + floor(random() * (case when habit > 0.6 then 9 else 13 end))::int];
      sc := greatest(12, least(99, (array[22,58,84,95,78,52,30])[br] + floor(random() * 13)::int - 6));
      scanned := random() < 0.82;                           -- the rest picked a type without a photo
      insert into public.entries (user_id, day, kind, score, bristol, colour, confidence, comfort, chips, created_at)
      values (uid, d, case when scanned then 'scan' else 'pick' end,
              case when scanned then sc end, br,
              (array['brown','brown','brown','light brown','dark brown','yellow'])[1 + floor(random() * 6)::int],
              round((0.6 + random() * 0.38)::numeric, 2),
              case when sc >= 80 then 0 when sc >= 60 then 1 when sc >= 40 then 2 else 3 end,
              case when random() < 0.18 then array[chip_pool[1 + floor(random() * 7)::int]] else '{}' end,
              least(now() - interval '5 minutes', (d + time '06:30' + make_interval(mins => floor(random() * 840)::int)) at time zone 'America/Vancouver'));
      insert into public.gp_events (user_id, day, delta, reason)
      values (uid, d, 10 + case when not scanned then 0 when sc >= 90 then 20 when sc >= 80 then 14 when sc >= 70 then 8 when sc >= 60 then 3
                               when sc >= 50 then 0 when sc >= 40 then -6 else -15 end, 'check-in');
      if to_regclass('public.logins') is not null then
        execute 'insert into public.logins (user_id, at, provider) values ($1, $2, $3)'
          using uid, least(now() - interval '5 minutes', (d + time '06:00' + make_interval(mins => floor(random() * 900)::int)) at time zone 'America/Vancouver'),
                (array['google-oauth2','google-oauth2','auth0','apple'])[1 + floor(random() * 4)::int];
      end if;
      logs := logs + 1;
    end loop;
  end loop;

  -- a few crowd players are buddies with each other, and cheer today
  insert into public.buddies (user_id, buddy_id)
  select a, b from (values ('demo|crowd001','demo|crowd002'), ('demo|crowd002','demo|crowd001'),
                           ('demo|crowd003','demo|crowd004'), ('demo|crowd004','demo|crowd003'),
                           ('demo|crowd005','demo|crowd001'), ('demo|crowd001','demo|crowd005')) v(a, b)
  on conflict do nothing;
end $$;

-- quick check
select count(*) as crowd_players,
       count(*) filter (where global_on) as on_board,
       (select count(*) from public.entries where user_id like 'demo|crowd%') as logs
from public.profiles where id like 'demo|crowd%';
