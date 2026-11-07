# Architecture

Keep this current. Update it when the design changes.

## One-line pitch
Log your poop in five seconds, let an AI read the photo, keep a streak with a few friends, and walk into the doctor's office with a record.

## Where this came from
This replaces Wave V2 (the user's call, 2026-11-07, see decisions.md). Photo scan, gamification and social tracking already exist in app stores (Dieta, PoopCheck, PoopMates, Unchikun). We chose to build anyway. Our edge is fun and polish, a privacy-first design (photos never stored, friends see activity and not health data), and an optional cycle layer. The pitch must not claim "first".

## Product
- **Core loop (never cut):** open the app, one big Log button, camera or "skip photo", the scan returns a Bristol type (1 to 7), colour, confidence and a "possible blood" flag, the user confirms or edits on one screen, the entry saves, the streak ticks, the mascot reacts. Target: five seconds.
- **Photo scan (never cut, with confirm and failure path):** Gemini vision with structured JSON output, called server-side. The photo is analysed in memory and discarded. Only the structured result is stored. Low confidence, a refusal or an error shows "Not sure, you pick" with the manual picker.
- **Blood wording (never cut):** the scan never says "no blood". It says "possible blood" or "can't tell from a photo". The user can set the flag by hand. Copy says this is not a diagnosis and to see a doctor about blood.
- **Quick log without photo (never cut):** an illustrated Bristol picker. The whole app works with no camera.
- **Gamification:** an original mascot of our own (not borrowed from any brand) that reacts to logging and grows through three stages. Streaks with a freeze. Small daily and weekly quests. Badges. Rule: reward logging, never outcomes. No ranking or points for any Bristol type, no shame copy for any type, a missed day is never punished.
- **Social, "buddies" (never cut, activity only):** invite by link, accept to join, a circle of about five. By default a buddy sees only: logged today, streak, mascot level, emoji cheers (three fixed). Photos, Bristol type, colour, blood flag and cycle data are never shared unless the user turns on a specific field for a specific buddy. Remove or leave takes effect immediately. Nobody is added without accepting.
- **Doctor summary (after the gate):** one page for the last 30 days: frequency, Bristol distribution, "possible blood" entries with dates, notes, a timeline. On-screen first, PDF is cuttable. Not a diagnosis.
- **Context chips (after the core loop):** one-tap, user-defined tags (travel, new food, stress, sleep, medication, cycle day) that show on the doctor summary as plain side-by-side lists. Cycle day is one chip among many, off by default, never shared with buddies, with no opt-in for sharing. The app computes no correlation and implies no cause. A quick comfort/bloating scale with neutral labels sits beside the chips for everyone. The cycle-overlay chart is a roadmap slide, not built. Not gendered.
- **Accessibility:** large targets, high contrast, no colour-only state, text for every illustration, a "plain words" setting that swaps cute names for clinical ones, reduced motion, full use without the camera.
- **Privacy:** delete-my-data button, no third-party analytics. Check the Gemini API data terms for the tier we use before the demo and say what we found.

## Honesty rules (say aloud and show on screen)
- Not a medical device. No diagnosis. Scan and summary screens say so.
- Scan accuracy on real stool is untested. For scale, a research smart toilet reached about 82 percent balanced accuracy on form and about 75 percent on blood. We claim no number of our own.
- The demo uses Play-Doh or illustrated samples, never real stool, and we say so.
- Similar apps exist. We do not say first.
- Research is desk-based from public sources, not interviews.
- The buddies in the demo are seeded and labelled.

## Prize
Open. Gemini is now core (the scan). Auth0 is login and invites. The rules allow one opt-in. Recommendation: Gemini (Senate run 8 agrees). Decide by about hour 3 and confirm timing with organizers. Until decided, rules.md still says Auth0.

## Stack (proposed, not confirmed)
- Frontend and backend: Next.js with TypeScript on Vercel (public URL so two phones can open it)
- Database: Supabase Postgres, DB only
- Scan: Gemini vision, structured output, server route, image held in memory only
- Auth: Auth0 passwordless login and invitations. If the prize pick moves to Gemini, a plain magic link is acceptable.
- Buddy updates: polling. No native push.
- Status: all TODO until the team confirms.

## Diagram

```mermaid
flowchart LR
    User -->|photo or Bristol pick| App
    App -->|image in memory| Gemini
    Gemini -->|type, colour, confidence, possible-blood| App
    App -->|confirm or edit| User
    App -->|structured entry only| DB[(Database)]
    App -->|streak, mascot| User
    App -->|activity only: logged today, streak, cheers| Buddies
    User -->|opt in per field per buddy| Buddies
    DB -->|30-day summary| Doctor[Doctor summary]
```

## Added scope (Senate run 9, size S, unratified; hours are the Senate's guesses, re-estimate)
Build order: core loop (quick log, scan with confirm, streak with freeze, buddy activity), doctor summary on screen, demo-safe mode and scan-failure states, context chips, privacy ledger.
- **Demo-safe mode and scan-failure states (about 4h):** blurry, not-a-sample and low-confidence photos return plain "cannot tell from a photo" states. A one-tap cached result is labelled on screen as a recording. Rehearse on venue wifi. The blood wording stays exact.
- **Privacy ledger, minimal (about 3 to 4h):** a read-only "what buddies see" screen with per-field state, revoke, and delete-everything that really deletes the account and stored results. Declining an invite and removing a buddy are silent. Test delete and silent decline on two phones. If it slips, ship the read-only screen with revoke.
- **Context chips (about 3h):** see Product. Never shown to buddies.
- **Pause, streak-off and freeze (about 1.5h):** pause is invisible to buddies by default (a generic "away" label is opt-in). The streak can be turned off and the mascot still works. Test the leave paths in the demo build.
- **PWA manifest and install prompt (about 0.5h).** Push stays on the roadmap.
- **Accessibility pass (about 2h):** text labels beside every colour and Bristol type, large tap targets, reduced-motion toggle, screen-reader labels.
- **Nothing to report (about 1h):** a one-tap entry that counts as logging, with neutral copy.
- **Doctor-summary notes (about 1.5h):** a free-text "questions I want to ask" field, local to the user, no auto-suggestions.
- **Mascot mood follows logging only:** happier when you check in, calm when you pause, no reaction to type or colour.
- **Do not build:** a trend, insight or correlation engine; leaderboards, points or rank by type; photo storage or image history; an AI chat that explains results; public feeds or default health sharing; wearables.
- **Demo moments:** (1) a live Play-Doh scan with a deliberate blurry failure, then a good shot and confirm, showing that only the structured record is stored; (2) a two-phone privacy proof: invite and accept, the buddy sees only "logged today" and the streak, silently decline a second invite, open the ledger, delete everything and show it gone.
- **Medical-claim flag:** no signposting copy (phone numbers, "call 8-1-1") near the possible-blood flag until a clinician reviews it. Copy stays "see a doctor".

## Hour-8 gate (two real phones)
Login works. A buddy invite is accepted. A photo of a Play-Doh sample goes to Gemini and returns a type, the user confirms, the entry saves and the streak ticks. The buddy's phone shows "logged today". Quick log without a photo works. The scan failure path ("Not sure, you pick") works. If the scan fails the gate, the manual picker becomes the main path and the scan is a bonus.

## First-hour spike
Run Gemini vision on five test images (Play-Doh, illustrations). Check refusals, latency and JSON validity before building around it.

## Cut order, first to last
Not built, roadmap slide only unless everything else is done: cycle-overlay chart, weekly recap card, mascot cosmetics, group quests, push reminders.
Among built items, cut first to last: doctor-summary notes, context chips, mascot stages beyond three, doctor summary PDF (keep on-screen), emoji reactions beyond three, nothing-to-report log, privacy-ledger polish (keep the read-only view, revoke and a true delete), doctor summary on-screen.
Never cut: quick log, scan with confirm and failure path, streak with freeze, pause and streak-off (invisible to buddies by default), login, buddy invite and accept with activity-only sharing, photos not stored, the blood wording, the labelled cached demo, the PWA manifest, text labels beside colour.

## Rubric map
- Problem Research: IBS prevalence, cycle-linked symptoms, diagnosis delay in young adults, the stigma of talking about it. Desk-based, see research.md.
- Technical: Gemini vision with structured output, auth and invitations, privacy-by-design data flow.
- Design: five-second log, mascot, plain-words mode, accessibility.
- Innovation: privacy-first social and the optional cycle layer. Not first, and we say so.
- Pitch: a memorable hook, an honest limits slide, a clear privacy answer.

## Pitch and demo safety (Senate run 8)
- Lead the pitch with the doctor summary and the privacy design (photo discarded, buddies see activity only, never "no blood"), not the stool.
- Scripted Q and A answer: "We log, we never diagnose. The possible-blood flag only prompts a doctor visit." Do not pitch cancer detection.
- User confirm-or-edit is the real product. Gemini only pre-fills. Keep the manual path.
- A cached known-good demo run sits behind a live/cached switch, so a stage network failure cannot stall the pitch. Pre-cache a good run before hour 8.
- Illustrated or Play-Doh samples only. Never cite the smart-toilet 82 and 75 percent figures as ours.
- The cycle layer is a roadmap slide unless everything else is done. Cite only the sourced facts (IBS about 12 percent in women vs 8.6 percent in men, endometriosis OR 3.26).

## Demo order
Open, tap Log, scan a Play-Doh sample, show the confidence and confirm, mascot reacts and streak ticks, the buddy's phone shows "Sam logged today" and a cheer, the privacy screen showing what buddies can and cannot see, the doctor summary, optionally the cycle overlay, then the honest limits slide.

## Who owns what
- Design lead (the user): mascot, log flow, screens, plain-words mode.
- Backend and data: Gemini route, database, auth, buddies.
- Research and pitch: sources, test images, privacy slide, the 4-minute pitch and Q and A.
