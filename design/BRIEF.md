# Plop design brief

For Codex, Claude Code and anyone designing screens. Read `.agents/skills/anti-ai-slop/SKILL.md` first, then this. Design work goes in `design/`, not in `prototype/plop.html` (Zan owns that file).

## The brief in one line each
- **User:** students 18 to 25 in a friend group of about five. Not a patient, not a gamer.
- **Job:** log a poo in 5 seconds, one hand, then feel it was ordinary.
- **Tone:** warm, matter-of-fact, a little funny. Never gross, never clinical, never preachy.
- **Constraint:** the mission is to destigmatize poo. Every screen should make "I plopped" feel as normal as "I ran 5k".
- **Hard rules from the logs:** no pink or gendered coding; a warm neutral palette; 3 mascot colourways the user picks; mascot never reacts to the Bristol type; every type gets the same celebration; no stool imagery anywhere in the UI; no "normal" or "abnormal" labels; rank copy says "Rank shows effort, not health"; blood copy says "Possible blood" or "Can't tell from a photo", never "no blood".

## Watch out for our own palette trap
"Warm neutral" can slide into cream paper + serif + terracotta, which the anti-slop skill lists as the new default. Warm neutral is still the decision. Pick the ground, one ownable accent and the type pairing on purpose, and say why. No purple, no pink, no Duolingo green.

## Screens to design (one Figma frame each, phone size)
1. Home and log (one primary action, quick log and nothing to report within thumb reach)
2. Scan reading (waiting state)
3. Confirm or edit the guess (type picker, confidence, blood note, disclaimer)
4. Scan failed, "Not sure, you pick"
5. Saved (streak, cheer from a friend)
6. Circle (friends see activity only: logged today, streak, cheers)
7. League (weekly 0 to 100 effort score, "Rank shows effort, not health")
8. Doctor summary (30 days: frequency, type spread, possible-blood dates, chips, cycle ribbon, notes)
9. Onboarding including "Do you track a cycle? (optional)", mascot colourway, discreet mode
10. Privacy ledger (what friends can see, revoke, delete all data)
Design empty, error and long-text states for at least the log, circle and summary screens.

## Accessibility (needed for Best Design)
Text 16px or larger, tap targets 48px or larger, contrast 4.5:1, never colour alone (label beside every colour), visible focus, respect reduced motion. Write a short accessibility note to paste into Devpost.

## Figma handoff
Best Design needs a Figma link. Codex output is code, so someone imports the screens into Figma (see the chat notes) or rebuilds the key frames there. Keep the Figma file to the 10 screens above and share a view link.
