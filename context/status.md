# Status (handoff file)

Update this at the end of every session, whichever agent or person you are. Overwrite, do not append.

## Done
- Repo set up with CLAUDE.md, AGENTS.md, and the context/ folder.
- Idea: Gut Check, a gamified, social gut diary with Gemini photo scan (the user's call, 2026-11-07). Final. Reaffirmed after Senate run 10 and a competitor check of its alternatives: every alternative has shipped competitors too. Wave V2, Paper Trail and the run 10 ideas are shelved, not deleted. See decisions.md and research.md.
- Architecture, cut order, hour-8 gate, honesty rules and a gut-health research section are written.
- context/sponsors.md now has an Entire section (what it is, install steps, what `entire enable` changes, the public-repo transcript warning).

## In progress
- A teammate (Zan Tian) uploaded a front-end only prototype: `GutCheck — working prototype.html` (commit 512002a). Single file, React and Tailwind from CDNs, no backend, mock random scan (no Gemini call). Screens: Profile, Health, Log, League, Settings. Stack not confirmed; no real backend yet.
- Prototype conflicts with logged decisions, to resolve with the team: competitive rating goes up and down with scan score (effort-only is logged); privacy copy says photos are analysed on-device (we send them to Gemini and discard); health advice cards and fixed hydration/fibre readouts (do-not-build); gender, age, conditions and medications profile fields; one log per day lock; no quick log, confirm/edit or failure path; friends rank sharing defaults on; no streak freeze, buddy invite, gentle day, habits or cycle chip.
- Entire is installed and enabled on the user's laptop (v0.13.1, Claude Code hooks, push_sessions false, settings committed in 3b03f2a). The agent sandbox could not install it, so each teammate installs it on their own laptop. Steps are in sponsors.md.

## Next (in order)
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
