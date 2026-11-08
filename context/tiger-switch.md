# Handoff: switch the database from Supabase to Tiger Data (owner: Riley)

**Status 2026-11-08 ~10:50 MST: DONE and live on https://plop-beryl.vercel.app.** Tiger service in AWS us-west-2; `npm run db:tiger` loads `db/schema.sql`, `db/tiger.sql`, `db/seed.sql`. All four tests below passed on Tiger (same-day upsert overwrites, delete-everything empties all five tables, buddy_activity works on the hypertable, load matches the raw rows). The aggregate built is `weekly_deuces` (real weekly global board) plus `daily_community`, not the doctor summary. Supabase is untouched as a fallback: put its pooler string back in `DATABASE_URL`.

Written 2026-11-08. The original handoff follows. Copy exact commands from Tiger's own quickstart, because their hypertable and compression syntax has changed across versions.

## Why this is a small change
- The app talks to Postgres only through `api/_lib/db.js` (`DATABASE_URL`, `postgres` library, SSL on). Nothing uses the Supabase API or Supabase Auth. Login is Auth0.
- Tiger Data is TimescaleDB on Tiger Cloud, which is Postgres.

## What to change
1. Get a Tiger Cloud service and its connection string. Put it in `DATABASE_URL` locally and in Vercel. Check whether `prepare: false` in `db.js` is still needed (harmless if kept).
2. Copy `db/schema.sql` to a Tiger version. Remove the Supabase-only parts: the comments about the SQL editor, the `anon` / `authenticated` role revokes if the roles do not exist, and any `public.` assumptions that fail.
3. Make `entries` a hypertable partitioned on `day`.
   - A hypertable's partition column must be in every unique constraint. Today `entries` has `id` as primary key and `unique (user_id, day)`. Change the primary key to `(id, day)` and keep `unique (user_id, day)`. The upsert `on conflict (user_id, day)` in `api/data.js` (around line 74) depends on that constraint.
4. Add a continuous aggregate for the 30-day doctor summary: weekly visit counts and Bristol-type counts per user. Add a refresh policy.
5. Add compression (columnstore) on old chunks, segmented by `user_id`.
6. Update `db/seed.sql` if the changed keys break it, `DEPLOY.md`, `.env.example` and the schema header comment.

## Do not break
- Buddies never read `entries`. They read activity only through `buddy_activity()`. Re-test it on the hypertable.
- "Delete everything" cascades from `profiles` to `entries`, `gp_events`, `buddies` and `cheers`. Re-test it.
- No photos are stored. The aggregate holds structured fields only, and it stays server-side.
- Do not say the app is built for scale. The data is a few demo users and 30 days each. Honest wording: "We use a hypertable and a continuous aggregate for the doctor summary."

## Test before merging (the Senate's freeze gate is 3:00am)
- Run schema and seed on a throwaway Tiger service.
- Log an entry twice on the same day (the upsert must overwrite, not error).
- Read the app's `load` call and compare the 30-day summary with the raw rows.
- Delete everything and confirm every table is empty for that user.
- Do not merge after the freeze unless it passed all four tests. If it fails, stay on the current database and tell the team.

## Open
- Prize opt-in: Best Use of Tiger Data vs Best Design. The limit is unconfirmed (see rules.md). Using Tiger tech without opting in is allowed.
