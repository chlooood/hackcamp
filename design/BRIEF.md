# Plop design brief

Updated 2026-11-08 to match the shipped app (`public/index.html`, the "Front End Ploopy" design) and the Figma file. The earlier version described a cobalt, paper and cocoa palette that was never shipped.

For anyone designing screens. Design work goes in `design/` and Figma, not in `prototype/plop.html` (Zan owns that file).

## The brief in one line each
- **User:** students 18 to 25 in a friend group of about five. Not a patient, not a gamer.
- **Job:** log a poo in 5 seconds, one hand, then feel it was ordinary.
- **Tone:** warm, matter-of-fact, a little funny. Never gross, never clinical, never preachy.
- **Mission:** destigmatize poo. Every screen should make "I plopped" feel as normal as "I ran 5k".
- **Hard rules from the logs:** no pink or gendered coding; the mascot never reacts to the Bristol type and every type gets the same celebration; no stool imagery in the UI outside the scan; no "normal" or "abnormal" labels; rank shows effort, not health.

## What shipped

**Look.** Teal ground, white cards, Nunito (600 to 900), and Ploopy, the mascot, in several colourways (switch under Record, Demo settings).

| Token | Hex | Use |
|---|---|---|
| teal | #0D9488 | primary action, brand ground |
| teal-dark | #0B6E64 | text and icons on light teal tints, pressed states |
| teal-soft, teal-tile, teal-pale | #E6F7F5, #D5F5F0, #CCF5EF | tinted fills |
| ink | #3C3C3C | body text |
| muted, faint | #6F6F6F, #9AA5A5 | secondary text, hints |
| line, track, card | #EDEFEF, #E3E8E8, #F4F6F6 | borders, tracks, card fills |
| indigo | #4F46E5 | global board toggle and banner |
| orange | #F97316 | streak flame |
| gold | #F2B705 | tier colour, mascot colourway |
| night | #141C30 | camera and dark screens |
| red | #C0312B | real alerts |

League tiers (Iron, Bronze, Silver, Gold, Platinum, Diamond, Mythic) each have their own colour pair.

**Screens in the app** (hash routes): login, home, snap, scan, pick, result, checked, record, ranked, tiers, global, join, promoted, deranked, privacy. The Figma page "App screens & flow" has 13 frames in three flows. Confirm which routes those frames cover and design any that are missing.

## Departures from the earlier brief (decide, then update this file)
- **Teal, not a warm neutral palette.** Intentional. The cobalt, tangerine, cocoa and mocha palette is dropped.
- **Indigo and a purple tier (Mythic).** The earlier brief said no purple. Keep them or recolour the global board and the top tier.
- **A flame icon for the streak.** The earlier brief ruled this out because an orange flame is Duolingo's symbol, and the team wanted a look that doesn't resemble it. Keep it or swap the icon.
- **Ranked tiers.** Metal-style tiers sit close to game conventions. The rule stays: rank shows effort, not health, and every league screen says so.

## Accessibility (needed for Best Design)
Targets: text 16px or larger, tap targets 48px or larger, contrast 4.5:1 for normal text, never colour alone (a label beside every colour), visible focus, respect reduced motion.

Measured contrast of the shipped colours (computed, not eyeballed):

| Pair | Ratio | Verdict |
|---|---|---|
| ink on white | 11.0:1 | pass |
| muted on white | 5.0:1 | pass |
| white on teal-dark | 6.1:1 | pass |
| white on indigo | 6.3:1 | pass |
| white on red | 5.7:1 | pass |
| teal-dark on teal-soft | 5.5:1 | pass |
| **white on teal (primary buttons)** | **3.7:1** | **fails for small text; passes only for large text and UI shapes** |
| **faint on white** | **2.5:1** | **fails; use only for decoration, never for text that matters** |
| **orange flame on white** | **2.8:1** | **below 3:1 for graphics** |

Fix before claiming accessibility: use teal-dark for button fills that carry small white text, or make that text large and bold; check where faint is used as text. Do not claim an accessibility audit has been done. Write a short, honest accessibility note for Devpost from this table.

## Figma handoff
Best Design needs a Figma link: https://www.figma.com/design/n6vlmh5saWGs1k7fOicHJ0. Pages: "Foundations" (colour variables, built before the teal decision and still showing the cobalt palette, so update it to the table above) and "App screens & flow" (13 screens as editable layers, Nunito). Judges should read Foundations, then the screens, then this brief.
