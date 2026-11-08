# Deploying the Plop phone demo

What is here: `public/index.html` is the phone page (quick log, photo scan, confirm or pick, streak, scripted buddy cheer). `api/scan.js` is the Gemini route. Zan's `prototype/plop.html` is separate and is not deployed by this.

## Host it on Vercel (about 10 minutes, free, gives you HTTPS)
Camera access on a phone needs HTTPS, so open the page from a Vercel link, not a file.

1. Get a Gemini API key from Google AI Studio. Never paste it into chat or commit it.
2. vercel.com: sign in with GitHub, Add New Project, import `chlooood/hackcamp`.
3. Framework preset: Other. Output Directory: `public`. Leave build settings empty.
4. Environment variables: `GEMINI_API_KEY` (required). `GEMINI_MODEL` (optional, default `gemini-2.5-flash`; check the current model name in AI Studio and set it here if that one is gone).
5. Deploy. Open the `.vercel.app` link on the phone you will present with.
6. Safari or Chrome: Share, Add to Home Screen. It opens full screen like an app.

## Before judging
- Run one live scan on the phone with the Play-Doh sample. If it fails or is slow, use the cached run: open `YOUR-LINK/?mode=cached` (or Demo settings, Cached demo run). The page labels it "Cached demo run".
- Demo settings also has "Make the next scan unclear" (shows the Not sure, you pick path) and "Seed a 6-day demo streak". Both are demo data kept on the phone only.
- Use a phone hotspot, not venue Wi-Fi.
- In AI Studio set a quota cap on the key, and delete the key after the event. The Vercel link is public, so anyone with it can spend your quota.

## Not done yet
Real login, real buddies (the buddy is scripted), points and leaderboard (Zan's prototype), doctor summary, privacy ledger, app icon. The demo says the buddy is scripted on screen.
