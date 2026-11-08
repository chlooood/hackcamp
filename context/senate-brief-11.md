# Senate run 11 brief: pitch structure and demo rating

Written 2026-11-08, about 12:30am. Facts below come from the repo (main at 167393d), README.md, context/status.md and the Devpost overview re-read tonight. Anything marked UNVERIFIED has not been run or confirmed.

## Event facts (Devpost, re-read tonight)
- HackCamp 2026, UBC Vancouver, nwPlus. 24 hours, Nov 7 to 8. Theme: identify a problem facing a community and build a solution that makes a meaningful difference.
- Submission deadline on the Devpost overview: Nov 8, 12:00pm MST (= 11:00am Pacific in Vancouver). The older schedule line said 12:15pm. Treat 11:00am Pacific as real until organizers say otherwise.
- Required: GitHub repo. Figma link (needed for Best Design and Most Accessible Design). Demo video up to 4 minutes is optional but "highly recommended". The earlier note about a live 4 minute pitch plus 4 minutes of Q&A at a judging table still stands.
- Judging criteria, no weights: Problem & User Research, Innovation, Technical Implementation, Design & User Experience, Presentation.
- Automatic: Overall Winner, Beginner Overall Winner, nwChoice. Opt-in and relevant: Best Design (Figma link), Community Impact (impact statement), Most Accessible Design and Best Problem-Solution Fit (beginner teams only), Best Use of Gemini API, Best Use of Auth0. The Devpost page states no opt-in limit; an earlier event page said one superlative. UNVERIFIED, ask organizers.
- Beginner definition is not stated on the page. UNVERIFIED whether we count.

## Product
Plop: a gamified, privacy-first, social gut diary with a doctor-facing record. Mascot Ploopy. Mission: destigmatize poo so "I plopped" is as ordinary as "I ran 5k".
- 5 second log: pick Bristol type 1 to 7, or photo scan (Gemini pre-fills, user confirms or edits). Task photos (proof of a daily habit) stay on the phone.
- The scan never says "no blood": only "possible blood" or "can't tell from a photo". The server writes that wording, not the model. Not a medical device, never diagnoses, no cancer-detection claim. No photo is stored by Plop.
- Record screen: 30 days, frequency, shape spread, possible-blood dates, tags (stress, period), notes for the doctor.
- Buddies see activity only: logged today, streak, rank, cheers. Never photo, Bristol type, colour, blood flag or cycle data. "What buddies see" screen with switches, discreet mode, real "Delete everything".
- Points are called Deuces. Weekly tiers, ranked opt-in or casual play.
- Research is desk research from public sources. We did not interview users. Two surveys were run or commissioned by companies. Never claim "first".
- Stage demo uses Play-Doh or illustrated samples, never real stool.

## Demo state, stated honestly
- The phone app (public/index.html) now follows the user's "Front End Ploopy" design: 13 screens, teal, Nunito, mascot Ploopy. Hash routing, plain JS. Figma page "App screens & flow" has all 13 screens as editable layers.
- Scan (api/scan.js): Gemini returns structured fields; the score out of 100 is fixed tables plus ratings (shape 40, colour 30, texture 30), plus two ideas for the day. Tested locally on 7 illustrated samples with real Gemini. UNVERIFIED on Play-Doh, on a phone, on venue wifi, and for latency.
- Login (api/auth.js, Auth0) and database (api/data.js, Supabase): tested locally with simulated Auth0 and a stand-in Supabase client and local Postgres. NOT run against the real Supabase project. Real Auth0 login NOT tried; Auth0 needs the callback URLs. Login switches itself off if Auth0 is not set up for the address.
- NOT deployed to Vercel. The camera needs HTTPS, so there is no phone demo until it is.
- Cached demo mode (`?mode=cached`) replays known-good scans so the demo does not depend on wifi. Tested in a browser, not on a phone.
- Interactive pitch (pitch/index.html, one file, works offline): 14 steps, about 4:10. Animated opener, a "fig. 1" anatomical plate where an orange travels through the body and Ploopy pops out ("Plop. Everyone does it."), then 4 chapters on a quest map: The problem, The app, The record, Real talk, then a goal flag with confetti. Embeds the real app in a phone frame. Keys: right arrow or Space next (also drives the phone), N notes, T timer. The "What we didn't do" slide was removed.
- Data on slides: more than 1 in 4 adults with a bowel disorder (Palsson, n 5,931); 71% would rather do something unpleasant than talk about poop (Oshi Health / Harris, vendor-funded); 25% delayed a doctor out of embarrassment, over two months on average (BUPA, covers any embarrassing symptom, UK, 2019); IBS in women 6.1% vs men 3.2%; endometriosis IBS odds ratio 3.26. Links were re-opened and the wording corrected tonight.
- README written, with an honesty section. Live link is a placeholder.
- Not built: the full doctor summary view with the exports a doctor would use, onboarding with the cycle question, a streak freeze (check the app), accessibility audit.

## Known conflicts and risks inside our own project
1. Gamification rule says rewards are for effort only and never for Bristol type, colour or blood. The current build lets the scan score (derived from Bristol type and colour) move Deuces. The pitch does not claim effort-only scoring and the notes give a straight answer if asked. The Senate should rule on whether this is defensible or a contradiction that a judge will find.
2. Scan screen copy says "Nobody ever sees it. Not even us." That overclaims: the photo goes to Gemini. Gemini free tier lets Google use inputs and human reviewers read them; paid tier does not train on inputs. The demo must use a billed key.
3. Gemini API is 18+ only and not for medical advice.
4. The old logged decisions (Senate runs 8 and 9) said to lead the pitch with the doctor summary and the privacy design, not the stool. The current pitch leads with a comic opener and the mission. Say if that should change.
5. A teammate (Zan) prototype exists (prototype/plop.html) with conflicting privacy copy and health advice cards. Status of that reconciliation is unclear.
6. Team may hit the deadline with no deployed URL. The fallback is the offline interactive pitch plus cached mode.

## Time
About 11 hours to the deadline if it is 11:00am Pacific. The user wants to sleep and rehearse. Assume at most 6 hours of build time left and one rehearsal slot. Hours are guesses.

## What we want back
A. Pitch structure for 4:00 live plus a 4 minute optional video: second-by-second timeline, what is on screen and what is said, who speaks, what to cut.
B. Demo rating, 1 to 10 on each of the five judging criteria as it stands now, one sentence each, then the score reachable by the deadline if the fix list is followed. Say which scores are most likely wrong.
C. The five most likely ways the live demo fails on stage, with a mitigation each.
D. Fix list ranked by impact per hour, with a "do not do" list. Include whether to deploy, merge, or freeze.
E. The eight hardest judge questions (privacy and Gemini data, medical device, who did you talk to, why share this, why not an existing app, gross factor, the scoring conflict, beginner status) with two honest sentences each. Mark any answer that needs a missing fact "NEED FACT".
F. Which single prize to opt into, or whether to opt into more, given the unknown limit.
G. Dissents and open questions.

## Binding terms
- Plop is final. Do not relitigate the idea.
- Do not reverse a logged decision without saying so.
- Do not recommend anything that breaks the privacy rules above.
- Label every claim as evidence or as simulated opinion. No flattery.
