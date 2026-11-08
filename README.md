<p align="center">
  <img src="pitch/ploopy/caramel-yay.png" width="140" alt="Ploopy, the Plop mascot">
</p>

<h1 align="center">Plop</h1>

<p align="center"><b>Everyone does it. So say it with us: "I plopped."</b><br>
A gut diary that makes logging a poo as normal as logging a run.</p>

<p align="center">
  Built in 24 hours at <b>HackCamp 2026</b> (nwPlus, UBC Vancouver, Nov 7 to 8)<br>
  <a href="#demo">Demo</a> · <a href="https://www.figma.com/design/n6vlmh5saWGs1k7fOicHJ0">Figma</a> · <a href="pitch/index.html">Interactive pitch</a> · <a href="#run-it">Run it</a>
</p>

---

## The problem

- **More than 1 in 4 adults** meet the Rome IV criteria for a functional bowel disorder ([Palsson et al., *Gastroenterology*](https://cdr.lib.unc.edu/downloads/fx719s748), online survey, US, Canada and UK, n = 5,931).
- **71%** of US adults would rather do something unpleasant, like sit in traffic, than talk about poop socially, and **35%** often look it up online because they're too embarrassed to ask a doctor ([Oshi Health / Harris Poll](https://oshihealth.com/newsroom/press-releases/new-report-lets-talk-sht-digestive-health-denial-and-the-cost-of-staying-quiet-reveals-widespread-digestive-health-issues-accompanied-by-stigma-and-embarrassment/), n = 2,091, Jan 2026, a survey commissioned by a GI care company).
- **1 in 4** people have put off seeing a doctor out of embarrassment. For bowel and bladder symptoms, the wait averaged **nearly 10 weeks** ([BUPA survey](https://www.djsresearch.co.uk/HealthMarketResearchInsightsAndFindings/article/Embarrassing-symptoms-cause-1-in-4-people-to-delay-visiting-GP-survey-finds-04286), UK, n = 1,245, 2019).
- IBS under Rome IV is almost twice as common in women (**6.1% vs 3.2%**, Palsson et al.), and women with endometriosis have about **3x the odds** of IBS ([meta-analysis, PubMed 32949284](https://pubmed.ncbi.nlm.nih.gov/32949284/), OR 3.26, 95% CI 1.97 to 5.39).

When people finally see a doctor, they describe weeks of symptoms from memory. Plop gives them a dated record, and makes the habit of keeping one feel normal.

## What it does

| | |
|---|---|
| **Log in seconds** | Snap a photo or pick from 7 simple shapes. One tap if you'd rather skip the photo. |
| **Photo scan** | Gemini reads shape and colour and pre-fills the entry. You confirm or change it. It never says "no blood": only "possible blood" or "can't tell from a photo". |
| **Deuces and ranks** | Earn Deuces for check-ins and small daily habits, climb weekly tiers with friends, or play casual. |
| **Buddies** | Friends see that you showed up and your streak. Never your photo, type or colour. |
| **Your record** | 30 days on one page: frequency, shape spread, possible-blood dates, tags like stress or period, and notes for your doctor. |
| **Privacy you can see** | A "What buddies see" screen with switches, a discreet mode, and a real "Delete everything". |

Mascot **Ploopy** cheers you on when you check in.

## Demo

- **Interactive pitch:** open `pitch/index.html` in Chrome. It runs offline and embeds the real app in a phone frame. Press → or Space to advance, N for notes, T for the timer.
- **Screens and flow:** [Figma file](https://www.figma.com/design/n6vlmh5saWGs1k7fOicHJ0), page "App screens & flow".
- **Live app:** _add the Vercel link here._

## How we built it

```
public/index.html   the phone app: plain HTML, CSS and JS, hash routing, no framework
api/scan.js         Vercel serverless function that calls Gemini (server-side key)
db/schema.sql       Supabase Postgres: tables, row level security, buddy functions
public/config.js    Supabase URL and anon key (empty = demo data only)
pitch/              the interactive pitch: src.html + build.py -> index.html
context/            decisions, research, status: our running project log
```

- **Gemini** reads the photo in memory on the server and returns structured fields only (usable, Bristol type, colour, possible blood, confidence). The app writes the blood wording itself, so the model can never tell someone "no blood".
- **Supabase** stores the structured entry, Deuces, rank, settings and buddy links. Every table has row level security. Buddies read activity through one function that returns only "logged today", streak, rank and cheers.
- **No photo is ever stored** by Plop.
- **Cached demo mode** (`?mode=cached`) replays known-good scans so a demo never depends on venue wifi.

## Run it

```bash
# 1. Just look at it: open public/index.html, add ?mode=cached
# 2. Deploy (camera needs HTTPS): import the repo on Vercel, output directory "public",
#    set GEMINI_API_KEY (and optionally GEMINI_MODEL). See DEPLOY.md.
# 3. Optional database: run db/schema.sql in Supabase, turn on anonymous sign-ins,
#    put the project URL and anon key in public/config.js.
# Rebuild the pitch after changing the app:
python3 pitch/build.py
```

## Being honest about it

- **Not a medical device.** Plop logs, it never diagnoses. "Possible blood" only suggests talking to a doctor.
- **Research is desk research** from public sources. We did not interview users. Two of the surveys above were run or commissioned by companies.
- **On stage we use Play-Doh**, never real samples. Demo buddies and leaderboard players are seeded.
- **Gemini terms:** on the free tier Google may use inputs to improve its products and human reviewers may read them, so health photos should only go through a billed (paid tier) key. The API is 18+ only, and Google's terms say it must not be used to give medical advice.

## What's next

- Real accounts across devices and push reminders
- A doctor summary export that clinicians have actually reviewed
- Testing the scan on a proper set of illustrated samples and publishing the accuracy

## Team

Chloë Dacey · Riley So · Zan Tian · _add the fourth member if any_

Design guardrails came from the [anti-ai-slop](https://github.com/Vinayak-Shukla-03/anti-ai-slop) skill (MIT).
