# Status (handoff file)

Update this at the end of every session, whichever agent or person you are. Overwrite, do not append. Last updated 2026-11-08, about 2am Pacific.

## Done
- Idea and mission: Plop, a gamified, privacy-first gut diary with a Gemini photo scan. Mission: make "I plopped" as ordinary as "I ran 5k". Final, no more re-deciding.
- App is live at https://plop-beryl.vercel.app (README link): plain HTML/JS front end, Vercel functions (api/scan.js Gemini, api/auth.js Auth0, api/data.js), Ploopy design (teal, Nunito). `?mode=cached` replays known-good scans.
- Database moved to Tiger Cloud (merged in d7c704a): hypertables, compression, continuous aggregates, 240 seeded demo players. Handoff notes are in context/tiger-switch.md; architecture.md already describes it.
- Scan tested locally on 7 illustrated samples with real Gemini. Server writes the blood wording ("possible blood" or "can't tell from a photo"), never "no blood".
- Privacy copy fixed on the scan screen ("Your photo is sent to Google's Gemini to be read. Plop doesn't save it."). api/scan.js writes and logs nothing of the photo.
- Interactive pitch (pitch/index.html, about 4:10, offline). Rebuild with `python3 pitch/build.py` after changing the app.
- Research: desk surveys re-opened and corrected (research.md); our own poll of 11 hackathon participants is in the README.
- Senate run 11 done (context/senate-result-11.md). Simulated opinion, no consensus. Main advice: no claim ships unverified, deploy then freeze at 3:00am, early Devpost submission, Best Design as the single opt-in.
- Devpost post drafted: context/devpost.md (Tiger section, Privacy section, Best Design Figma guide, community impact statement, tags). README rewritten to match.
- Entire: sessions push to a private repo (chlooood/hackcamp-checkpoints), first checkpoint confirmed, automatic policy. Only sessions on the user's laptop are recorded. Graph and Brain are not set up.
- design/BRIEF.md rewritten for the shipped teal design.

## In progress
- Two VERIFY lines in context/devpost.md: Gemini paid tier (confirm the Vercel key is billed, re-read Google's terms) and the Figma Foundations page (still shows the old cobalt palette; the app is teal).
- Devpost still says Auth0 login is deployed. Nobody has confirmed a real login on the live link.
- Figma MCP hit its Starter plan call limit, so Figma pages and names could not be checked from the agent.

## Next (in order)
1. Ask organizers on Discord: real deadline (Devpost says 12:00pm MST, which is 11:00am Pacific), how many superlative prizes a team can opt into, what counts as a Beginner team.
2. Run one real scan on a phone on the live link (hotspot or cellular), with a Play-Doh sample. Write down the result, failures included. Technical stays rated a 5 until this passes.
3. Verify privacy facts: Vercel log settings, Gemini billing and current paid-tier terms. Delete the VERIFY lines.
4. Check Auth0 login on the live link. Confirm Tiger policies (compression, retention, aggregates) are applied on the deployed database.
5. Update the Figma Foundations page to the teal palette. Fix contrast in the app (white on teal buttons is 3.7:1, faint text is 2.5:1, see design/BRIEF.md).
6. Decide the departures in design/BRIEF.md: indigo and a purple tier, the flame streak icon, metal-style tiers.
7. Decide whether the scan score still moves Deuces. It conflicts with the effort-only rule. Fix it, or say so plainly in the Devpost and in Q&A.
8. Cut the pitch to 4:00 (cut the 71% stat first, cap the opener at 20 seconds), rehearse once with the timer.
9. Opt-in pick: Best Design if the limit is one. Add Gemini, Community Impact and, if beginner status is confirmed, Best Problem-Solution Fit if there is no limit.
10. Submit a complete Devpost entry early (target 9:30am Pacific): repo, Figma link, README, optional cached-mode video up to 4 minutes.

## Blockers and open questions
- Deadline timezone, opt-in limit and beginner definition are unconfirmed (see rules.md and prizes.md).
- Prototype conflicts (prototype/plop.html, Zan's): privacy copy, health advice cards, profile fields. Not merged into the app. Do not submit it as the product.
- Name availability for "Plop" has not been checked.
- Starter habits need sources and ideally a clinician's read. No signposting copy near the possible-blood flag until a clinician reviews it.
- Teammates' Entire adoption is unverified. Graph and Brain are not set up; there is no measured token saving, so Entire is not a prize target.
- Research links should be re-opened by someone on the team before the numbers go on a slide.
- No cancer-detection or "first" claims anywhere. Stage demo uses Play-Doh or illustrations.

## How to run it
- Locally: `npm install`, copy `.env.example` to `.env` and fill it in, `npm run dev`. Database: `TIGER_URL=... npm run db:tiger`. Deploy steps are in DEPLOY.md.
