# anti-ai-slop

A portable [Claude Code](https://claude.com/claude-code) **skill** that stops Claude's UI and
presentation output from defaulting to the recognizable "AI-generated" house style — the
purple gradients, Inter-flat type, uniform rounded cards, 3-icon feature grids, emoji icons,
kicker-on-every-slide, and benefit-speak copy that make generated work read as machine-made.

It loads automatically whenever you ask Claude to build or restyle any visual output — a
website, landing page, web app, component, dashboard, or a slide deck / pitch deck — in any
medium (HTML, React, Tailwind, slides).

## Why

An LLM emits the most probable token. For an *unconstrained* visual choice, "most probable" is
the statistical average of every tutorial it was trained on — so with no constraint it
deterministically produces the same purple-gradient, Inter-font, rounded-card page every time.
This skill forces a specific, intentional decision wherever the model would otherwise reach for
that average, and it names the second-order traps too (the "tasteful AI" monoculture of warm
cream paper + a serif display + a terracotta accent that the first fix tends to converge on).

## Install

**Per-project** — drop it into a project's skills directory:

```bash
git clone https://github.com/Vinayak-Shukla-03/anti-ai-slop.git
mkdir -p your-project/.claude/skills
cp -R anti-ai-slop your-project/.claude/skills/anti-ai-slop
```

**Global** — make it available in every project:

```bash
git clone https://github.com/Vinayak-Shukla-03/anti-ai-slop.git ~/.claude/skills/anti-ai-slop
```

That's it. The skill's `description` triggers it on any UI/deck request; no configuration
needed. (Keep the `references/` folder next to `SKILL.md` — the skill links to it by relative
path.)

## What's inside

| File | Role |
|---|---|
| `SKILL.md` | The core: 9 hard rules, a method (brief → distinctive foundation → real content → audit), a pre-ship self-audit, and a **render-it-and-look ship-blocker**. |
| `references/web-ui.md` | App / dashboard / landing-page tells + fixes, plus a reliability section (a blank page can't be un-slopped). |
| `references/presentations.md` | Deck / slide tells + fixes (kicker-every-slide, bullet-rhythm, thank-you-slide, the "deck chrome" kit). |
| `references/toolkit.md` | Concrete swap-ins: palettes, font pairings, scales — and a divergence matrix so a *set* of artifacts doesn't re-converge. |

## The nine hard rules (the short version)

1. No unbranded purple/indigo and no reflexive gradient.
2. Never the system font or Inter/Geist flat — a real display + body pairing.
3. No uniform-everything — a radius/padding hierarchy; size and space signal priority.
4. No emoji as icons — a real, consistent icon set.
5. No `transition: all` and no blanket fade-in — purposeful motion only.
6. No benefit-speak ("Elevate", "Unlock", "Seamlessly", "not X — it's Y").
7. No fabricated precision — real numbers with a source, or none.
8. Break the template skeleton — content and audience drive structure.
9. No second-order monoculture — if you make a *set*, force it to diverge (ground, display
   face, accent, stance).

Plus a ship-blocker: **render it and look** before calling any UI done — beautiful code that
doesn't mount is worth zero.

## How it was built

Empirically, not from vibes. A baseline corpus of 10 artifacts (5 apps + 5 decks) was generated
with no design guidance to capture Claude's unprompted defaults, dissected for recurring tells,
cross-checked against how designers and dev communities describe "AI slop," distilled into these
rules, then used to rebuild the same 10 — and the rebuilds were rendered and scored. A second
pass caught a *second-order* monoculture (the fix's own overused escape hatch) and hardened the
skill with the anti-monoculture + divergence rules it now carries.

## License

MIT — see [LICENSE](LICENSE).
