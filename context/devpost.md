# Plop

**Tagline:** Everyone does it. A private gut diary that says so.

**Try it out:** Live app https://plop-beryl.vercel.app (add `?mode=cached` for the offline demo scan) · GitHub https://github.com/chlooood/hackcamp · Figma https://www.figma.com/design/n6vlmh5saWGs1k7fOicHJ0

## Inspiration

Everyone poops. Somehow, talking about it is still awkward.

We track our steps, sleep and workouts, but when a doctor asks about our bowel habits, we often have to piece together weeks of symptoms from memory. We wanted to make keeping that record easier, and make people actually want to return to it.

So we built **Plop**, a gut diary with quick check-ins, optional social features and Ploopy, a little mascot who is excited that you showed up.

Our mission: **"I plopped" should sound as normal as "I ran 5K."**

## What it does

Plop makes an everyday bathroom visit a quick check-in.

Users can log manually using the Bristol Stool Scale or scan a photo with Gemini to get suggested fields, then review and confirm their entry. Their history helps them keep track of changes over time instead of relying entirely on memory.

Streaks, daily quests and our in-app currency, **Deuces**, add encouragement. Ploopy supplies the enthusiasm.

For people who enjoy a little friendly motivation, optional buddy features share activity such as check-ins and streaks. **Friends do not see the photo, stool type or colour.** People who prefer to keep things private can use the diary on their own.

Plop is a tracking tool, not a diagnostic tool. Scan results acknowledge uncertainty rather than presenting a photo as proof that everything is fine.

## How we built it

We built the app with **HTML, CSS and JavaScript**, deployed on **Vercel**, with **Auth0** for authentication and **Tiger Data** (Tiger Cloud, Postgres with TimescaleDB) for the database.

We integrated **Gemini** to turn a photo into structured entry suggestions, including shape and colour. The server writes the safety wording, not the model. We designed the flow around user review: the scan suggests an entry, and the user confirms or edits it.

We used **Figma** to develop the screens, teal visual identity and Ploopy's character. We also built an interactive HTML pitch with an embedded app, animated storytelling and a cached scan demonstration so our presentation would not depend on venue Wi-Fi. Our stage samples use Play-Doh and illustrations.

## How we used Tiger Data

Every poop is a point in time, so Plop's data is a time series, and Tiger Data is built for that.

- **Hypertables.** Every log and every Deuces change is stored in a hypertable split by week.
- **Continuous aggregate.** Tiger keeps a running weekly total of Deuces for every player and keeps it up to date. That powers our global leaderboard without recalculating it on every load. Two more aggregates track daily check-ins and daily logins.
- **Compression.** Logs older than 90 days compress automatically.
- **Retention.** Login records delete themselves after 180 days, so we keep less about people by default.

An honest note: our demo has a handful of accounts plus 240 seeded players, so it shows the design and not scale.

## Privacy, in plain terms

- **The photo's path:** your phone, then our server, then Gemini to be scored. It is held in memory for that one request. Our code never saves it to disk, logs it or puts it in the database.
- **What we keep:** the structured result only (score, stool type, colour, a possible-blood flag and your tags), never the photo.
- **Gemini's terms:** we use Gemini's paid tier, where Google's terms say inputs are not used to train its models. Google may keep them briefly for abuse monitoring.
- **Daily-task photos** never leave your phone.

> **[VERIFY BEFORE SUBMITTING, then delete this line]** Confirm the Vercel `GEMINI_API_KEY` belongs to a billed project and re-read Google's current paid-tier terms. If either fails, replace the "Gemini's terms" bullet with: "The photo is sent to Google's Gemini to be read."

## Challenges we ran into

### Making it playful while respecting the topic

A poop app practically invites jokes, but someone tracking digestive symptoms also needs a useful record. Finding that balance shaped our mascot, interface and writing. We wanted the humour to make logging easier without making someone's concerns feel trivial.

### Explaining privacy precisely

We learned quickly that reassuring language can overpromise. "Plop does not save your photo" and "nobody ever sees your photo" mean different things when an external AI service processes the scan. We revised our wording to explain that distinction.

### Handling uncertainty

Getting a consistent AI response was only part of the challenge. We also had to decide how to display uncertainty. We worked on structured fields and cautious wording, including "possible blood" or "can't tell from a photo", rather than claiming a scan could rule something out.

### Making social features optional for a reason

Some people welcomed buddy streaks. Others wanted absolutely no updates about their friends' bathroom habits. That feedback reminded us that the private diary needs to be useful on its own.

### Fitting a time-series database to a small app

Moving to a time-series database changed our table design. A hypertable's unique keys have to include its time column, so the entries and Deuces tables couldn't keep a plain id as their primary key and now use id plus day. Compression also doesn't work on tables with row level security, so we dropped it on those two tables. That is safe for us because only our server connects to the database and Tiger has no public data API, but it was a trade-off we had to make deliberately.

## For Best Design judges: how to read our Figma

Open [our Figma file](https://www.figma.com/design/n6vlmh5saWGs1k7fOicHJ0) and go through it in this order:

1. **Foundations.** Our colour system as Figma variables, with a swatch for each colour and a rule for how it is used.
2. **App screens & flow.** All 13 screens as editable layers (Nunito, with Ploopy), laid out as three flows with arrows showing how a person moves from one screen to the next.
3. **Our thinking.** The design brief in our repo ([design/BRIEF.md](https://github.com/chlooood/hackcamp/blob/main/design/BRIEF.md)) records who we designed for, the rules we set, and what we ruled out.

What to look at in the screens:
- **The scan flow.** A scan suggests an entry, you confirm or edit it, and there is a "can't tell, you choose" path for when the scan is unsure.
- **The privacy screens.** "What buddies see" with switches, a discreet mode, and a real "Delete everything".
- **Ploopy.** One mascot whose job is to make a sensitive topic feel welcoming and to cheer you on for showing up, never for a result.

> **[VERIFY BEFORE SUBMITTING, then delete this line]** Open the Foundations page and check it shows the colours the app actually uses (the app is teal). If it still shows the earlier cobalt, paper and cocoa palette, update it or tell judges it is an earlier exploration. If you add a Figma page for design thinking, link it in item 3. Also check the wording above matches the real page names.

## Accomplishments that we're proud of
- Bringing together manual logging, AI-assisted entry suggestions and a personal history in one approachable experience.
- Creating Ploopy and a visual identity that makes a sensitive topic feel more welcoming.
- Designing buddy sharing around participation while keeping entry details private.
- Building an interactive pitch that demonstrates the app instead of relying only on screenshots.
- Asking people for feedback and letting their answers challenge our assumptions.

## What we learned

We informally polled **11 fellow hackathon participants**. It was a small convenience sample, but it helped us check our direction.

Five said they had delayed seeing a doctor because it felt embarrassing. Eight welcomed a friend seeing only a check-in and streak, one said maybe, and two said no. Those two still welcomed health analytics; they simply did not want the social updates.

That taught us to separate **interest in tracking** from **interest in sharing**.

We also learned that product copy is part of engineering. Explaining where a photo goes, what is retained and what friends can see requires the same precision as building those boundaries.

Working with Gemini taught us that structured output makes an interface more predictable, but it does not make an interpretation certain. User review and honest wording remain essential.

And we learned that even a small mascot has a big design job: Ploopy needs to make showing up feel good without making health feel like a score to win.

## Who we asked

We asked 11 fellow hackathon participants in person, one minute each, with no names or health details recorded. It is a small convenience sample, so it is a pulse check and not a study.
- Hearing about a friend's stomach trouble (1 fine to 10 awkward): ten of eleven said 4 or lower.
- Put off a doctor visit because it felt embarrassing: 5 yes, 6 no.
- Describing changes to a doctor today: from memory was the most common answer (5 of the 8 who answered).
- A friend seeing only "logged today" and a streak: 8 yes, 1 maybe, 2 no.
- Photo sent to Gemini and not saved by Plop: 8 yes, 2 did not mind, 1 no.
- Trust: they would trust it if photos are deleted right away, and stop if entries became public, if there were ads, or if it felt gimmicky.

## Community impact statement

Many people avoid talking about bowel health, and some delay seeing a doctor because it feels embarrassing. By the figures we found, more than 1 in 4 adults meet the criteria for a functional bowel disorder (Palsson et al., online survey, n = 5,931), and 25% of people have put off a doctor visit out of embarrassment (BUPA, UK, 2019, covering any embarrassing symptom). In our own small poll of 11 hackathon participants, 5 had put off a visit because it felt embarrassing, and most relied on memory to describe changes to a doctor.

Plop is a 5-second private log and a record to bring to an appointment. Buddy sharing is limited to activity and is optional. It is not a medical device and does not diagnose. We have not studied whether it helps anyone, and we make no claim about how many people it will help.

## What's next for Plop

We want to complete a concise doctor-facing export, make rewards consistently recognize participation rather than bodily outcomes, and test with people beyond the hackathon, including people who already track digestive symptoms.

We also want clinician feedback on health-related wording and a thorough review of privacy controls and accessibility.

Ultimately, we want Plop to become an easy habit: **log it, learn about your patterns, and get on with your day.**

## Built with

gemini-api, tiger-data, timescaledb, postgresql, auth0, vercel, node.js, javascript, html5, css3, web-audio-api, figma
