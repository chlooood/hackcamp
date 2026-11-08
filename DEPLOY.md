# Deploying Plop

What is here:
- `public/index.html`: the phone app (scan, score, ranks, buddies, record).
- `api/scan.js`: Gemini scan route. Scores out of 100 and writes two ideas for the day.
- `api/auth.js`: Auth0 login (server side).
- `api/data.js`: the only thing that reads or writes the database, always as the logged-in user.
- `db/schema.sql` and `db/seed.sql`: the Supabase database and the fake demo data.
- `dev-server.js`: runs all of the above on your laptop.

No secret ever goes to the phone or into git. They live in `.env` on your laptop and in Vercel's environment variables.

## 1. Supabase (database)
1. In the project, open **SQL Editor > New query**, paste all of `db/schema.sql` and press **Run**. If a "destructive operation" warning pops up, confirm it. It only drops old Plop tables.
2. New query again: paste all of `db/seed.sql` and **Run**. This adds the fake buddies Zan, Chloe and Mo and 12 fake players. Re-run it on demo day so "checked in today" is fresh.
3. **Project Settings > Database > Connection string**: copy the **Transaction pooler** string (port 6543), put your database password in it, and use it as `DATABASE_URL`.

Anonymous sign-ins and the publishable key are no longer used. Row level security is on with no policies, so the public keys can't read anything.

## 2. Auth0 (login)
In the Auth0 dashboard, open **Applications > your app > Settings**:
1. Application type: **Regular Web Application**.
2. **Allowed Callback URLs**: `http://localhost:3000/api/auth/callback, https://YOUR-APP.vercel.app/api/auth/callback`
3. **Allowed Logout URLs**: `http://localhost:3000/, https://YOUR-APP.vercel.app/`
4. **Allowed Web Origins**: `http://localhost:3000, https://YOUR-APP.vercel.app`
5. Save. Optional: under **Authentication > Social**, turn on Google so people can log in with one tap.

## 3. Vercel (hosting, HTTPS for the camera)
1. vercel.com: Add New Project, import `chlooood/hackcamp`. Framework preset: **Other**. Leave build settings empty (`vercel.json` sets the output folder).
2. **Settings > Environment Variables**, add every name from `.env.example`:
   `GEMINI_API_KEY`, `GEMINI_MODEL` (`gemini-3.8-flash`), `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, `AUTH0_SECRET` (32+ random characters: `openssl rand -hex 32`), `DATABASE_URL`.
3. Deploy, then put the real `.vercel.app` address into the Auth0 URLs from step 2.
4. On the phone: open the link, then Share > Add to Home Screen.

## Run it on your laptop
```bash
npm install
cp .env.example .env    # fill it in
npm run dev             # http://localhost:3000
```
Without `.env` the app still runs in demo mode. Without `DATABASE_URL` or the Auth0 values, login is hidden and the app stays on demo data.

## Before judging
- Do one live scan with the Play-Doh sample. If it's slow or fails, use `YOUR-LINK/?mode=cached` (or Record > Demo settings > Cached demo run). The screen says "Cached demo run".
- Record > Demo settings also has: make the next scan unclear (shows the "you pick" path), add demo buddies, simulate a missed day, show the promotion screen.
- Use a phone hotspot, not venue Wi-Fi.
- Set a quota cap on the Gemini key in AI Studio. The scan route is public, so anyone with the link can use it.
- After the event, generate new copies of the Gemini key, the Auth0 client secret and the Supabase database password. They were shared in a chat.

## Two-phone test
1. Phone A: log in, Buddies > Invite, send the link.
2. Phone B: open the link, log in. Both phones list each other.
3. Log on A. B shows "Checked in" within 30 seconds. Cheer from B; A sees "cheered you".
4. Ranked on a new account shows the "Join ranked?" screen first.

## Not done yet
- Deleting your account removes all your Plop data. The Auth0 login itself stays until someone deletes it in the Auth0 dashboard (doing it from the app needs the Auth0 Management API).
- Rank and Deuces are still worked out on the phone and saved by the server, so a determined user could edit their own rank. Fine for a demo; move the maths to the server before a real launch.
- The global top 100 is still labelled demo data.
