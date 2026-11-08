*Senate:** size M, 5 senators: Grace Hopper, Steve Jobs, Richard Feynman, Chanakya, George Orwell

**Outcome:** no consensus after 3 of 3 rounds; the final draft below is unratified

## Answer

**Labels.** "(brief)" marks evidence from the brief. Everything else is simulated opinion from the senate.

## Rules that govern everything below
1. **Verify-then-say.** A claim ships on stage, screen, README or Devpost only after someone has checked it. Until then it uses the fallback wording.
   - "Plop stores nothing" needs someone to read `api/scan.js` and the Vercel log settings and confirm nothing is stored or logged. If that isn't done by the freeze gate, the line becomes "The photo is sent to Gemini to be read," and nothing more.
   - "Not used for training" stays out of the pitch, README and Devpost until someone re-reads Google's current paid-tier terms. The brief says the paid tier doesn't train on inputs, but that is a claim to confirm, not to repeat.
   - **Technical is scored 5 until one real phone scan passes on the deployed build, on hotspot or cellular.** Then it is 7. Write the result down, failures included.
2. **Print these rules and every NEED FACT mark at the top of the speaker notes**, in the same type as the script, so they are in front of the team at 9am.
3. **Stated partial reversal of logged runs 8 and 9.** Those runs said to lead with the doctor summary and the privacy design, not the stool. We now open with a comic opener capped at **20 seconds**, then go straight to the problem. Privacy gets its own beat in the demo. The doctor summary can't lead anyway, since the full view isn't built (brief). Everything else in runs 8 and 9 stands.

## A. Pitch structure

### Live, 4:00 (two speakers, S1 and S2)
The interactive pitch runs about 4:10 (brief), so cut about 20 seconds. Merge "Real talk" and the goal flag into one close. Drop the IBS 6.1% vs 3.2% and endometriosis stats from the slides and keep them in the notes. Run the phone frame in cached mode (`?mode=cached`) unless the deployed build has passed a phone test.

| Time | On screen | Said | Who |
|---|---|---|---|
| 0:00–0:20 | Animated opener, then the "fig. 1" plate: the orange travels through, Ploopy pops out | "Plop. Everyone does it." Hard cap 20s. | S1 |
| 0:20–0:55 | Problem slide, three figures, each labeled | More than 1 in 4 adults have a bowel disorder (Palsson, n 5,931). 25% delayed seeing a doctor out of embarrassment, over two months on average (BUPA, any embarrassing symptom, UK, 2019). The 71% figure is **vendor-funded** (Oshi/Harris), so say so. Then: "This is desk research. We didn't interview users." | S1 |
| 0:55–1:50 | Phone frame: 5-second log, Bristol 1–7, scan with a Play-Doh or illustrated sample | Pick a type, or scan and Gemini pre-fills. You confirm or edit. The wording is written by our server, not the model: "possible blood" or "can't tell from a photo." Never "no blood." | S2 drives, S1 narrates |
| 1:50–2:30 | "What buddies see" screen, switches, discreet mode, Delete everything | Buddies see activity only: logged today, streak, rank, cheers. Never photo, type, colour, blood or cycle. Privacy line, only as verified (Q1 wording). | S2 |
| 2:30–3:20 | Record screen: 30 days, frequency, shape spread, possible-blood dates, tags, notes | "This is what you'd bring to a doctor." Say plainly that the export views are not built yet. | S1 |
| 3:20–3:50 | One merged close, goal flag with confetti | One breath of limits: not a medical device, never diagnoses, desk research with no interviews, doctor exports not built. Then land on "I plopped" being as ordinary as "I ran 5k." | S1 or S2 |
| 3:50–4:00 | Hold | Buffer. Do not fill it. | — |

**Cut if over time:** the 71% stat first, then the Figma mention.

### Video, optional, target 3:45 (max 4:00)
One voice-over. Record from the deployed phone only if the first take works. Otherwise use the cached-mode screen recording. A rough, true video beats a late, perfect one.

| Time | Content |
|---|---|
| 0:00–0:20 | Opener and fig. 1 |
| 0:20–0:50 | Problem, labeled figures |
| 0:50–1:45 | Log and scan walkthrough |
| 1:45–2:20 | Privacy: buddies, switches, discreet mode, Delete everything |
| 2:20–2:50 | Record screen |
| 2:50–3:15 | How it's built: Gemini returns structured fields, the score comes from fixed tables, and the server writes the safety wording. Mention Auth0 and Supabase only if verified live; otherwise say "login is built and tested locally." |
| 3:15–3:45 | Close and limits, same as live |

## B. Demo rating (simulated opinion)

| Criterion | Now | Reachable by deadline | One sentence |
|---|---|---|---|
| Problem & User Research | 4 | 5 | Desk research only, two vendor-run surveys, no interviews. Say that plainly on stage, because it is the honest ceiling. |
| Innovation | 6 | 6 | Server-written safety wording, activity-only social layer and the "destigmatize" framing are distinctive. We can't claim "first," and no competitor audit exists. |
| Technical Implementation | 5 | 7 only after a real phone scan passes on the deployed build, otherwise 5 | Scan is tested locally on 7 illustrated samples. Auth0 and Supabase have not run against the real services, and nothing is deployed (brief). |
| Design & UX | 7 | 8 | 13 screens in Figma and the app, consistent mascot and palette. No accessibility audit, so no accessibility claims. |
| Presentation | 7 | 8 | Strong comic hook, but one rehearsal slot only, and the live demo has several unrun paths. |

**Most likely wrong:** Technical. It could be 3 if the demo fails on stage or 7 if it works, and no phone test exists yet. Presentation is second, since it is untested under time pressure. Problem & Research may be scored 5 by a generous judge, but we plan on 4.

## C. Five ways the live demo fails

1. **No HTTPS, so the camera is blocked** (not deployed, brief). Mitigation: deploy, or run `?mode=cached` and say "cached replay of real scans" on stage.
2. **Venue wifi or Gemini latency or timeout.** Mitigation: cached mode as the default, with a hotspot as backup. Never wait on a spinner on stage.
3. **Play-Doh scan gives odd output**, since it is untested on Play-Doh (brief). Mitigation: run it once tonight and record the result. If it is bad, use the illustrated samples.
4. **Real Auth0 or Supabase fails.** Neither has run live (brief). Mitigation: login switches itself off if Auth0 isn't set up for the address (brief). Don't show login unless it passed a real test.
5. **Overrun, or the phone frame desyncs from the slides.** The pitch is 4:10 as it stands. Mitigation: use the cut list in section A, rehearse once with a timer (T key), and use the arrow key or Space to drive the phone.

## D. Fix list, ranked by impact per hour

**Gates (hard, not suggestions):** deploy gate at **1:30am**, freeze gate at **3:00am**, early submission **9:30am Pacific**. The deadline is treated as **11:00am Pacific** until organizers say otherwise (brief). **Tired-team rule:** whoever is at the keyboard at 1:30am does not get "ten more minutes." If the gate is missed, switch to the fallback immediately (offline pitch, cached mode, README stating the live link is unavailable) and nobody debugs Auth0 or Supabase afterward.

1. **Fix the "Nobody ever sees it. Not even us." copy** (about 15 min, non-negotiable). The photo goes to Gemini, so replace it with "The photo is sent to Google's Gemini to read it." Add "Plop doesn't keep it" only after rule 1 verification.
2. **Verify privacy facts** (about 30 min): `api/scan.js`, Vercel log settings, and that the demo key is a billed key (brief). Re-read Google's paid-tier terms. Record what was found.
3. **Deploy to Vercel and run one real phone scan** by 1:30am, on hotspot or cellular. Run the Play-Doh sample once and write down the result. Update the README's placeholder live link.
4. **Submit a complete Devpost entry** the moment the deploy passes the phone test, or at the 1:30am gate if it does not. It needs the repo, the Figma link, the README and a rough cached-mode video. The 9:30am pass then becomes an improvement pass, not the first submission. A missing submission scores zero, and a rough one can be improved.
5. **Freeze at 3:00am.** Nothing merges after that except copy fixes and a revert if something breaks. Merge only what has been tested. Don't merge Zan's `prototype/plop.html`, whose privacy copy and health advice cards conflict with ours (brief). Either exclude it from the submission or label it clearly as a separate exploratory prototype.
6. **Decouple Deuces from the scan score** so Deuces reward logging effort only (about 1 hour). This is last priority and the first item dropped if time runs short. If it is dropped, Q7 states the flaw plainly.
7. **Cut the pitch to 4:00, then rehearse once** against the timer, with the phone frame and the notes page. Then sleep.
8. **Record the video** (cached-mode screen recording if the phone take fails).
9. **9:30am Pacific:** final Devpost improvement pass, and check the Devpost deadline once more.

**Ask organizers tonight:** the real deadline (11:00am vs 12:15pm), the opt-in limit, and the beginner definition (all UNVERIFIED in the brief).

**Do not do:** debug Auth0 or Supabase after the gate; build the doctor summary exports, cycle onboarding or a streak freeze; run an accessibility audit and then claim anything from it; add features after the freeze; use the words "first," "no blood," or "not used for training" (until verified); put real stool anywhere; reopen the idea.

## E. Eight hardest judge questions

1. **Privacy and Gemini data.** "The photo is sent to Google's Gemini to read it. Plop stores nothing." *NEED FACT: confirm in `api/scan.js` and the Vercel log settings that nothing is stored or logged, and re-read the paid-tier terms before saying "not used for training." Gemini is 18+ only (brief), so don't say anything beyond this on stage.*
2. **Medical device.** "Plop is not a medical device and never diagnoses. The wording 'possible blood' or 'can't tell from a photo' is written by our server, not by the model, and we never say 'no blood.'" Gemini is not for medical advice (brief), and we don't use it that way.
3. **Who did you talk to.** "Nobody yet. Our research is desk research from public sources, and two of the surveys were run by companies. Interviews are the next step." No NEED FACT, but do not exaggerate it.
4. **Why share this.** "Sharing is opt-in, and buddies see activity only: logged today, streak, rank, cheers. They never see photo, type, colour, blood flag or cycle data." There are switches, a discreet mode and a real Delete everything (brief).
5. **Why not an existing app.** *NEED FACT: no competitor audit is in the brief, so don't name apps or claim "first."* "We haven't audited every tracker, so we won't say we're first. Our bet is the privacy defaults, the activity-only social layer and a record built for the doctor visit."
6. **Gross factor.** "Yes, it's uncomfortable, and that is the problem: the 71% figure shows people avoid talking about it, though that survey is vendor-funded. We handle it with a mascot, humor and discreet mode, and our stage demo uses Play-Doh, never real stool."
7. **Scoring conflict.** If decoupled: "We found that scan scores derived from shape and colour moved Deuces, which broke our effort-only rule, so we fixed it." If not: "That is a real contradiction in the build. Our rule is effort-only rewards, and we didn't get it fixed in time." *NEED FACT: state which one is true at freeze.*
8. **Beginner status.** *NEED FACT: the definition isn't stated on the page and we haven't confirmed whether we count (brief).* "We don't know yet whether the rules count us. We'll go with whatever the organizers say."

## F. Prize opt-in

**Opt into Best Design** (Figma link, which is required anyway). The page states no limit, but an earlier event page said one superlative (UNVERIFIED), so assume one.
- **Add Community Impact only if organizers confirm there is no limit.** The statement is a plain conditional one: "Many people avoid talking about bowel health. Desk figures: more than 1 in 4 adults have a bowel disorder (Palsson, n 5,931); 25% delayed seeing a doctor out of embarrassment, over two months on average (BUPA, UK, 2019, any embarrassing symptom). Plop is a 5-second log and a private record for the doctor visit. It is not a medical device and does not diagnose. We have not interviewed users and make no claim about how many people it helps." An impact statement is not a research claim, so the missing interviews limit what it says rather than bar it.
- **Don't opt into** Most Accessible Design (no audit, beginner status unknown), Best Problem-Solution Fit (beginner-only, unknown), Best Use of Auth0 (never run live), or Best Use of Gemini (a weaker fit than Design).

## G. Dissents and open questions
- **Orwell would opt into Community Impact now**, and accepts the majority position only because no interviews exist.
- **Hopper vs the others on cut order:** Hopper ranks decoupling last and first to drop. If it is dropped, Q7 must state the flaw plainly.
- **Problem & Research:** Jobs holds it at 4 and says so on stage. A generous judge could score 5.
- **Open (ask organizers):** deadline time, opt-in limit, beginner definition.
- **Open (check in the repo):** whether a streak freeze exists, and what happened to the Zan prototype reconciliation.
- **Open (unverified):** Play-Doh scan quality, venue wifi latency, and any real Auth0 or Supabase run.

## Points of agreement

- Deploy first, then freeze at 3:00am. Fix the "Not even us" copy before anything else.
- No claim ships unverified. "Plop stores nothing" needs a code and log check, "not used for training" needs a terms re-read, and Technical stays at 5 until a real phone scan passes on the deployed build.
- The NEED FACT marks and the verify-then-say rules are printed at the top of the speaker notes.
- Submit a complete Devpost entry early, then improve it by 9:30am Pacific. Treat 11:00am Pacific as the deadline until organizers answer.
- Decouple Deuces from the scan score if time allows, and state the flaw plainly in Q7 if it doesn't.
- Merge "Real talk" and the goal flag into one close of about 30 seconds, and cap the opener at 20 seconds as a stated partial reversal of runs 8 and 9.
- Opt into Best Design only. Add Community Impact only if organizers confirm there is no limit.
- "Desk research, no interviews" appears next to the stats, and the 71% figure is labeled vendor-funded wherever it appears.

## Amendments proposed in the last vote

- *in the spirit of Grace Hopper*: Fold in the gates and the earlier Devpost submission time (about 9:30am Pacific) from my last position, plus a "tired-team rule" so the deploy gate cannot slide.
- *in the spirit of Steve Jobs*: Add a hard rule that the stage line "Plop doesn't store it" and the 7 for Technical are claimed only after they are verified, and print that rule in the speaker notes.
- *in the spirit of Richard Feynman*: Fold my two verification points into the draft as hard rules: (1) Q1 and the stage privacy line carry only what someone has confirmed tonight, and (2) the Technical 7 stays labeled a hope until a real phone scan passes on the deployed build, with the result written down.
- *in the spirit of Chanakya*: Add the early-submission step and the Hopper gates into section D explicitly, and print the NEED FACT marks in the speaker notes; otherwise I sign.
- *in the spirit of George Orwell*: The draft still lacks my three changes: print the Q1 NEED FACT mark in the speaker notes, write Community Impact as a plain conditional statement, and keep the dissent wording as "Orwell would opt into Community Impact."

---
Backend `claude`, 19 model calls, 245.3s wall time. Transcript: C:\Users\chloe\.senate\transcripts\1794124892-plop-a-hackcamp-2026-project-read.md