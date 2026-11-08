# Deploying the Plop phone demo

What is here: `public/index.html` is the phone page built from the Front End Ploopy design (home, photo scan, score result, quick pick, check-in GP, ranks, buddies, privacy, record). Demo switches live under Record > Demo settings. `api/scan.js` is the Gemini route. `db/schema.sql` is the Supabase database and `public/config.js` holds its public connection details.

## Host it on Vercel (about 10 minutes, free, gives you HTTPS)
Camera access on a phone needs HTTPS, so open the page from a Vercel link, not a file.

1. Get a Gemini API key from Google AI Studio. Never paste it into chat or commit it.
2. vercel.com: sign in with GitHub, Add New Project, import `chlooood/hackcamp`.
3. Framework preset: Other. Output Directory: `public`. Leave build settings empty.
4. Environment variables: `GEMINI_API_KEY` (required). `GEMINI_MODEL` (optional, default `gemini-2.5-flash`; check the current model name in AI Studio and set it here if that one is gone).
5. Deploy. Open the `.vercel.app` link on the phone you will present with.
6. Safari or Chrome: Share, Add to Home Screen. It opens full screen like an app.

## Set up the database (Supabase, about 10 minutes, free)
Without this the app runs on demo data saved on the phone. With it, logs, rank, buddies and cheers are saved for real.

1. supabase.com: New project. Pick a region near you and save the database password somewhere safe (you won't need it in the app).
2. Authentication > Sign In / Providers (or Settings): turn on **Allow anonymous sign-ins**. Each phone gets its own private account with no login screen.
3. SQL Editor > New query: paste all of `db/schema.sql` and Run. Re-running it wipes Plop data, so run it once.
4. Project Settings > API: copy the **Project URL** and the **anon public** key into `public/config.js`, then commit and push. The anon key is meant to be public; row level security protects the data. Never put the `service_role` key in the repo.
5. Redeploy on Vercel. Record > Demo settings > Database should say "Connected as …".
6. Two-phone test: on phone A, Buddies > add your name > Invite and send the link. Open it on phone B and add a name there too. Both phones should list each other. Log on A, and B sees "Checked in" within 30 seconds.

What the database stores: the structured result (type, colour, score, comfort, chips, blood flag), GP events, rank, settings and buddy links. Never a photo. Buddies only ever get logged-today, streak and rank through `buddy_activity()`, and only what each person shares. "Delete everything" removes the account and every row.

## Before judging
- Run one live scan on the phone with the Play-Doh sample. If it fails or is slow, use the cached run: open `YOUR-LINK/?mode=cached` (or Record > Demo settings > Cached demo run). The page labels it "Cached demo run".
- Demo settings also has "Make the next scan unclear" (shows the Not sure, you pick path) and "Reset to demo data" and "Simulate a missed day". Both are demo data kept on the phone only.
- Use a phone hotspot, not venue Wi-Fi.
- In AI Studio set a quota cap on the key, and delete the key after the event. The Vercel link is public, so anyone with it can spend your quota.

## Not done yet
Login across devices (each phone is its own anonymous account, so a cleared browser starts fresh), the global top 100 (still demo data, labelled), PDF export beyond the browser's print, app icon. Rank and GP are calculated on the phone, so a determined user could edit their own rank; fine for a demo, move to the server before a real launch.
