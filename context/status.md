# Status (handoff file)

Update this at the end of every session, whichever agent or person you are. Overwrite, do not append.

## Done
- Repo set up with CLAUDE.md, AGENTS.md, and the context/ folder.
- Idea: Plop, a gamified, social gut diary with Gemini photo scan (the user's call, 2026-11-07). Final. Reaffirmed after Senate run 10 and a competitor check of its alternatives: every alternative has shipped competitors too. Wave V2, Paper Trail and the run 10 ideas are shelved, not deleted. See decisions.md and research.md.
- Architecture, cut order, hour-8 gate, honesty rules and a gut-health research section are written.
- context/sponsors.md now has an Entire section (what it is, install steps, what `entire enable` changes, the public-repo transcript warning).

- Mission set 2026-11-08: destigmatize poo (see architecture.md "Mission" and decisions.md). Scoring set to effort plus consistency, with Zan's prototype as the UI base.

- Prototype scoring and leaderboard are Zan's to build. My effort-only version is in commit 72bb838 (reverted in the next commit). The spec Zan should follow is in architecture.md "Points, leagues and gentle day" (effort-only, 100 per scan photo, consistency multiplier, weekly 0 to 100 score, rank never reads scan results).

- Phone demo built (not yet deployed): public/index.html (quick log, photo scan, confirm or pick, failure path, streak, scripted buddy, cached demo switch) and api/scan.js (Gemini, server-side, fixed blood wording). API logic and page flow pass local tests (mocked Gemini, jsdom). Deploy steps are in DEPLOY.md. Never run against real Gemini yet.

- Anti-slop skill added for design work: Vinayak-Shukla-03/anti-ai-slop (MIT, markdown only, reviewed) in .agents/skills/ for Codex and .claude/skills/ for Claude Code. design/BRIEF.md is the design brief. CLAUDE.md and AGENTS.md point to the skill.

## In progress
- Interactive pitch (branch interactive-pitch): pitch/index.html, one file, works offline. Edit pitch/src.html, then run `python3 pitch/build.py` to rebuild; it embeds the current public/index.html and every PNG in pitch/ploopy/. 14 steps, about 4:10 (cut the IBS slide first if long). Keys: right arrow or Space next (also drives the phone), left back, N notes, T timer, R reset app, ? help.
  - Structure: animated opener, a "fig. 1" anatomical plate in the style of the sourcebook references (a person in profile bites an orange; it travels down the oesophagus, through stomach, small and large intestine with a drawn trail; Ploopy pops out; "Plop. Everyone does it."), then 4 chapters on a quest map at the top left ("Quest: make 'I plopped' normal"): 1 The problem, 2 The app, 3 The record, 4 Real talk, then a Goal flag with confetti and squishable Ploopys.
  - Transitions: a 1-second teal tile wipe with a chapter card, only when moving forward into a new chapter, only over the left side. The phone never moves; on data slides it dims.
  - Data slides: more than 1 in 4 adults with a bowel disorder (Palsson, Rome IV, n 5,931); 71% would rather do something unpleasant than talk about poop and 35% google it out of embarrassment (Oshi Health / Harris Poll 2026, vendor, marked Secondary); 25% delayed a doctor out of embarrassment, average over two months (BUPA n 1,245, marked Secondary); IBS women 6.1% vs men 3.2% (Palsson) and endometriosis IBS odds ratio 3.26, CI 1.97 to 5.39 (PubMed 32949284). Nobody has re-opened these links yet; do that before saying them on stage.
  - Removed: the "What we didn't do" slide (user's call). Play-Doh and "not a diagnosis" are still said on the scan and result slides.
  - Built on the merged scoring as designed (the scan score moves Deuces). The pitch does not claim effort-only scoring; the notes give a straight answer if judges ask.
  - Fixed: links inside the phone (href="#...") used to load the pitch inside the phone.
- Points renamed from GP to Deuces everywhere users see them (public/index.html and the pitch). Code names (state.gp, gpLog) are unchanged.
- Supabase database built on branch supabase-db: db/schema.sql (tables, RLS, buddy functions, tested on local Postgres 15 with stubbed Supabase auth) and a sync layer in public/index.html (tested in the browser with a stand-in Supabase client: sign-in, load, check-in, cheers, invites, offline queue, remove buddy, delete everything). Not yet run against a real Supabase project. Next: create the project, enable anonymous sign-ins, run the schema, fill public/config.js (steps in DEPLOY.md), then the two-phone test.
- public/index.html now follows the user's "Front End Ploopy" design (13 screens, teal, Nunito, mascot Ploopy). Scan still goes to api/scan.js; cached demo, forced-unclear scan, simulate missed day, promotion screen and mascot colour are under Record > Demo settings. Tested in a browser in cached mode, not yet on a phone or against real Gemini. The design conflicts with several logged decisions (see the last line of decisions.md); the team needs to confirm them.
- A teammate (Zan Tian) uploaded a front-end only prototype: `prototype/plop.html` (commit 512002a). Single file, React and Tailwind from CDNs, no backend, mock random scan (no Gemini call). Screens: Profile, Health, Log, League, Settings. Stack not confirmed; no real backend yet.
- Prototype conflicts with logged decisions. Scoring is now settled and built in the prototype. Still open and not yet agreed with Zan: privacy copy says photos are analysed on-device (we send them to Gemini and discard); health advice cards and fixed hydration/fibre readouts (do-not-build); gender, age, conditions and medications profile fields; one log per day lock; no quick log, confirm/edit or failure path; friends rank sharing defaults on; no streak freeze, buddy invite, gentle day, habits or cycle chip.
- Entire is installed and enabled on the user's laptop (v0.13.1, Claude Code hooks, push_sessions false, settings committed in 3b03f2a). The agent sandbox could not install it, so each teammate installs it on their own laptop. Steps are in sponsors.md.

## Next (in order)
0. Before judging (deadline 12:00pm MST per the Devpost overview; the schedule says 12:15, treat 12:00 as real): deploy to Vercel and run one live Gemini scan on the demo phone, else present with the cached scan; decide whether to merge Riley's supabase-db branch (if merged, rebuild the pitch and check it loads); merge interactive-pitch; ask organizers how many prize opt-ins are allowed; start the Devpost submission; write a README; rehearse to 4:00 plus Q and A; re-open the research links; optional 4-minute video (screen-record the pitch).
1. Teammates: `git pull`, install Entire (Scoop `entire/entire` on Windows), run `entire enable --agent claude-code --skip-push-sessions`, then `entire status`. The user's laptop is done.
2. Confirm stack and hosting (public URL, works on two phones).
3. Hour-1 Gemini spike: five test images (Play-Doh, illustrations). Check refusals, latency, JSON validity. Pass: usable type on at least 4 of 5, a sensible low-confidence answer on a bad photo, a reply in about 3 seconds. Fail: the manual picker is the main path and the scan is a bonus.
4. Login working on one phone.
5. The log loop: quick log first, then photo scan, confirm, entry saved, streak ticks.
6. Buddy invite and accept, activity-only feed ("logged today", streak, cheers).
7. Mascot and design pass (the user leads).
8. Hour-8 gate on two real phones (see architecture.md).
9. After the gate, add points and habit check-ins, the friends league and gentle day, then in this order if time allows (Senate run 9, plus the cycle ribbon): doctor summary on screen, demo-safe mode and scan-failure states, context chips and the opt-in cycle ribbon with discreet mode, privacy ledger (read-only, revoke, true delete), pause and streak-off, PWA manifest, accessibility pass, nothing-to-report, doctor-summary notes. Quests, weekly recap, mascot cosmetics and the cycle-overlay chart are roadmap slides.
10. Lock the demo script by hour 10. Final hours: rehearse the 4-minute pitch and Q and A. No new features.

## Blockers and open questions
- Deploy to Vercel and run the 5-image Gemini spike. Verify the model name, response shape and latency with a real key (the docs could not be fetched). Gemini data-retention terms are still unchecked, and the page says the photo is sent to Google and then dropped.
- Prize opt-in: see context/prizes.md. Best Design (needs a Figma link) and Community Impact (needs an impact statement) are open to all and were missing from rules.md. Devpost does not state an opt-in limit. Submission deadline per Devpost: Nov 8, 12:00pm MST on the overview page (12:15pm on the schedule page); winners 1:00pm MST. Confirm the timezone with organizers.
- Tell Zan the scoring change: the score-driven rating goes, effort plus a consistency multiplier replaces it. Confirm with the user that "consistency" means showing up (logging and habit streaks), not consistently healthy results.
- Check whether "Plop" is available as a name (renamed from Gut Check on 2026-11-08; decisions.md keeps the old name in historical lines). Pitch hand-raise and stats need a teammate to re-open the research.md links.
- Points, friends league, global leaderboard and gentle day were decided on 2026-11-07 (see architecture.md and decisions.md). Starter habits need a source link each, and ideally a clinician's read, before the demo. The habit-photo bonus on food photos carries a nudge-to-food-logging risk; mitigations are in decisions.md.
- Ask organizers: how many superlative prizes can a team opt into (rules.md says one, the user was told several may be allowed, no source found), is judging by peers or a panel, and when must the opt-in be declared. Then update rules.md.
- Prize opt-in is open: Gemini (recommended) or Auth0. Entire (a projector) is a third option only if the team wants to build a measured token-savings story, which is not planned. Decide by about hour 3.
- Entire: decide whether session transcripts get pushed to the public repo. Default is no. Read a transcript for emails, keys or personal details before ever pushing.
- Make a cached known-good demo run behind a live/cached switch before hour 8.
- Check Gemini latency, quota, accuracy and data-retention terms, and PIPEDA and BC privacy rules for health-adjacent data, before the pitch.
- No signposting copy (phone numbers) near the possible-blood flag until a clinician reviews it.
- Senate run 9 hours are guesses and the result was unratified. The builder re-estimates before committing to the added scope.
- Confirm all three teammates are comfortable pitching this to judges.
- Competitor research is stopped (hackathon, best idea). The pitch just never says "first".
- Female-accessible UI: design lead sketches the cycle onboarding question, cycle ribbon, 3 mascot colourways and discreet mode early. Ask at least two people who track a cycle to read the wording.
- Someone on the team must open each link in context/research.md and confirm the numbers before they go on a slide.

## How to run it
- TODO once code exists.

- Figma file n6vlmh5saWGs1k7fOicHJ0: colour variables and specimen done (page Foundations). No screens built there yet; designer builds them via Codex.
