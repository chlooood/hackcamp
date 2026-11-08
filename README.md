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
- **Screens and flow:** [Figma file](https://www.figma.com/design/n6vlmh5saWGs1k7fOicHJ0). Read "Foundations" (colour system) first, then "App screens & flow" (13 screens in three flows).
- **Live app:** https://plop-beryl.vercel.app (open it on a phone; the camera needs https). Add `?mode=cached` for the offline demo scan.

## How we built it

```
public/index.html   the phone app: plain HTML, CSS and JS, hash routing, no framework
api/scan.js         Gemini scan: score out of 100 and two ideas for the day (server-side key)
api/auth.js         Auth0 login on the server (code flow with PKCE, encrypted session cookie)
api/data.js         the only code that touches the database, always as the logged-in user
db/schema.sql       Postgres tables and buddy functions
db/tiger.sql        Tiger Data setup: hypertables, compression, continuous aggregates
db/seed.sql         fake demo data (db/seed-crowd.sql adds 240 seeded players for the board)
dev-server.js       runs the app and all three functions locally (npm run dev)
pitch/              the interactive pitch: src.html + build.py -> index.html
context/            decisions, research, status: our running project log
```

- **Gemini** reads the photo in memory on the server and returns structured fields only (usable, Bristol type, colour, possible blood, confidence, three texture ratings, short notes, two ideas). The score is fixed tables plus those ratings: shape 40 (Bristol type), colour 30, texture 30. The server filters every sentence and writes the blood wording itself, so the model can never tell someone "no blood".
- **Auth0** handles login. Phones never get a database key: only our server talks to the database.
- **Tiger Data** (Tiger Cloud, Postgres with TimescaleDB) stores the structured entry, Deuces, rank, settings and buddy links. Our data is a daily time series, so `entries`, `gp_events` and `logins` are hypertables split into weekly chunks, old chunks are compressed after 90 days, and logins are dropped after 180 days. Three continuous aggregates (`weekly_deuces`, `daily_community`, `daily_logins`) keep weekly Deuces, daily check-in totals and daily logins up to date, and the global board reads `weekly_deuces`. Buddies read activity through one function that returns only "logged today", streak, rank and cheers.
- **What Tiger does and doesn't show:** the data is tiny, a few demo accounts plus 240 seeded fake players on the board, so this shows the design and not scale. Columnstore compression can't be used with row level security, so `entries` and `gp_events` no longer have it. Only our server connects to the database, and Tiger has no public data API.
- **Cached demo mode** (`?mode=cached`) replays known-good scans so a demo never depends on venue wifi.

## Privacy, in plain terms

- **The photo's path:** your phone, then our server, then Gemini to be scored. It is held in memory for that one request. Our code never saves it to disk, logs it or puts it in the database.
- **What we keep:** the structured result only (score, stool type, colour, a possible-blood flag and your tags), never the photo.
- **Daily-task photos** (proof you did a daily task) never leave your phone.
- **Gemini's terms** are under "Being honest about it".

## Run it

```bash
# 1. Just look at it: open public/index.html, add ?mode=cached
# 2. Run everything locally: npm install, cp .env.example .env (fill it in), npm run dev
# 3. Deploy (camera needs HTTPS): import the repo on Vercel and add the variables from
#    .env.example. Database: create a Tiger Cloud service and run `TIGER_URL=... npm run db:tiger` (loads db/schema.sql, db/tiger.sql, db/seed.sql). See DEPLOY.md. Any Postgres also works, without the Tiger time-series features.
# Rebuild the pitch after changing the app:
python3 pitch/build.py
```

## Who we asked

We asked 11 fellow hackathon participants in person, one minute each, with no names and no health details recorded. It is a small convenience sample of people at a hackathon, so treat it as a pulse check and not a study.

| Question | What they said (n = 11) |
|---|---|
| A friend tells you about stomach trouble: fine (1) to awkward (10)? | 1 (x5), 3 (x2), 4 (x3), 6 (x1). Ten of eleven said 4 or lower. |
| Ever put off seeing a doctor because it felt embarrassing? | 5 yes, 6 no. Comments were general: not wanting an older male doctor, and waiting to see if it goes away. |
| How would you describe changes to a doctor today? | Of the 8 who answered: from memory (5), maybe photos (2), have a parent explain it (1). |
| Would you be OK with a friend seeing only "logged today" and your streak? | 8 yes, 1 maybe, 2 no. The two "no" answers said they don't want to hear about friends' bathroom habits. |
| A scan sends your photo to Google's Gemini and Plop doesn't save it. OK? | 8 yes, 2 don't mind, 1 no. One yes was for the health analytics. |
| What would make you trust it or stop using it? | Trust: photos deleted right away. Stop: entries or any info becoming public (3 people), ads, feeling gimmicky. Several had no privacy worries. |

What this does and doesn't show: ten of eleven were comfortable hearing about a friend's stomach trouble, and 5 of 11 had put off a doctor visit because it felt embarrassing. That is milder than the survey figures above, and eleven people can't confirm or refute them. Most relied on memory when they see a doctor. Most were fine with activity-only sharing, but two didn't want it at all, so sharing has to stay optional. The concerns they raised (leaks, ads, gimmicks) are on our list.

## Being honest about it

- **Not a medical device.** Plop logs, it never diagnoses. "Possible blood" only suggests talking to a doctor.
- **Research is desk research** from public sources. We polled 11 hackathon participants (see above) but did not run interviews or a study. Two of the surveys above were run or commissioned by companies.
- **On stage we use Play-Doh**, never real samples. Demo buddies and leaderboard players are seeded.
- **Gemini terms:** on the free tier Google may use inputs to improve its products and human reviewers may read them, so health photos should only go through a billed (paid tier) key. The API is 18+ only, and Google's terms say it must not be used to give medical advice.

## What's next

- Real accounts across devices and push reminders
- A doctor summary export that clinicians have actually reviewed
- Testing the scan on a proper set of illustrated samples and publishing the accuracy

## Team

Chloë Dacey · Riley So · Zan Tian 

