# Decisions log

Append only. One line per decision. Newest at the bottom, so merges stay clean.

Format: `YYYY-MM-DD | decision | reason`

2026-11-07 | Shared context lives in `context/` as plain Markdown in the repo | Free, no install, works with any agent
2026-11-07 | Build the heat-wave buddy network (software only, no hardware) | Senate ranked it 1 of 10: best problem story, real research access, consent and roles are a real design problem
2026-11-07 | Opt in to Auth0 as our single superlative | Login and roles are load-bearing. Gemini is a tool only, not an opt-in. Confirm with organizers when the opt-in must be declared
2026-11-07 | Fallback is flood watch with Tiger Data, decided at the hour-8 gate | Public river-gauge data is live and stable
2026-11-07 | The person at risk is never enrolled by someone else | Consent is a shippable feature and answers the surveillance objection
2026-11-07 | Cut escalation and the second role until the one-role alert loop works end to end | 3 people, 24 hours, integration is the main risk
2026-11-07 | Build the person-at-risk side accessibility-first: very large text, high contrast, voice or one-tap check-in, plain and multilingual wording, passwordless login | Past HackCamp and nwHacks winners lean accessibility, and Design is a scored criterion
2026-11-07 | Coordinator view for existing check-in programs is a stretch goal after hour 8, only if interviews show such programs exist | Answers the cold-start objection but adds a second role. Coordinators can share invitations, never enrol anyone
2026-11-07 | Second hazard feed (smoke or river level) is a pitch line plus a config swap, built only if everything else works | Shows the loop is global without scope creep
2026-11-07 | SUPERSEDES the heat-wave decision: build Daily Wave as the core, with the power-out check-in as the single hazard layer. Heat is a roadmap slide only | Senate ranked it 1 of 9: best on Design, Pitch and retention; the daily habit means the safety net is already set up when needed
2026-11-07 | Auth0 stays our single opt-in. Gemini is a tool only | Login, circle invitations and per-person control are central to the product
2026-11-07 | Outage source is the BC Hydro regional/municipal RSS feed, parsed fixture-first inside a 2-hour box, plus a clearly labelled simulate switch for the demo. Do not rely on the undocumented map JSON | RSS is the only officially published feed (15 min cadence, area level)
2026-11-07 | Buddy alert has three choices: I've got this / Call them instead / Can't, pass it on. Pass-on notifies the circle and is never cut | Buddy systems fail at the buddy; an honest decline keeps people willing to serve
2026-11-07 | Pre-committed cut order: live RSS parse, then quiet-nudge, then postcard animation polish. Never cut: the wave, the circle, buddy confirm, buddy decline | Protects the demo under time pressure
2026-11-07 | Hour-8 gate is binary and tested on two real phones: Auth0 login, invite accepted, one-tap wave sent and received, postcard grows, simulated outage alert confirmed in one tap with decline present. Live RSS never blocks GO | If any fail, drop to wave + circle + simulated alert
2026-11-07 | Lock the demo script by hour 10 and build only what it touches | Scope control
2026-11-07 | Honesty rules, said aloud and on screen: desk research from public sources, seeded labelled circle, unofficial feed with last-checked time, labelled simulate switch, and a slide saying this supplements emergency services and the person's own backup power plan | Avoid overclaiming; judges will probe
