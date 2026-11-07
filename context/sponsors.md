# Sponsor APIs and docs

One section per sponsor we plan to use. Paste the key doc links and any API quirks we hit.

## Entire
- Prize / what they want to see: "Best Use of Entire" (mini portable projector), per rules.md. Their product pages list Sessions, Graph, Brain and Trails, and talk about token savings. Not yet an opt-in (see decisions.md).
- What it is (from entire.com and github.com/entireio/cli, read 2026-11-07):
  - Sessions: the CLI hooks into git and your coding agent and records prompts, tool calls and file changes as checkpoints. Data goes on a separate branch, `entire/checkpoints/v1`, never on your working branch. Secrets are redacted on a best-effort basis.
  - Graph (`entire-graph`): a code graph agents query so they read fewer whole files. Brain (`entire-brain`): sessions plus graph facts so a new agent session starts with relevant context. Trails: a pull-request replacement that links findings back to the sessions that produced the code.
  - Token savings: the site claims "up to 71%" but does not say how it is measured; it points at benchmarks in the entire-graph repo. Do not repeat that number as ours. If we want the prize we need our own measured before/after, which we have not planned yet.
- Docs: https://docs.entire.io , repo https://github.com/entireio/cli , sign-in at entire.com/login (steps after that not read).
- Install (each teammate, on their own laptop; the user's laptop is done, v0.13.1):
  - Windows: install Scoop first (`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`, then `Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression`, then open a new PowerShell). Then `scoop bucket add entire https://github.com/entireio/scoop-bucket.git` and `scoop install entire/entire`. The package was renamed from `entire/cli`, so use `entire/entire`.
  - macOS or Linux: `brew tap entireio/tap`, `brew trust entireio/tap`, `brew install --cask entire`, or `curl -fsSL https://entire.io/install.sh | bash`
  - Then in the repo: `entire enable --agent claude-code --skip-push-sessions` (or `codex`, `gemini`), then `entire status`. Settings are already committed (`.entire/settings.json`, `.claude/settings.json`, commit 3b03f2a), so teammates just `git pull` first. Expect LF/CRLF warnings on Windows; they are harmless.
- What `entire enable` changes: creates `.entire/settings.json` (shared, normally committed), `.entire/settings.local.json` (personal, gitignored), installs git hooks, and writes agent hooks (Claude Code: `.claude/settings.json`; Codex: `.codex/hooks.json`; Gemini CLI: `.gemini/settings.json`).
- Auth / keys: `entire login` uses device auth. Never commit tokens. Headless: `ENTIRE_TOKEN_STORE=file`.
- Gotchas:
  - The repo must be public for submission. Session transcripts live in the repo, so if the checkpoint branch is pushed, anyone can read our prompts and replies. Redaction is best-effort. Run `entire enable --skip-push-sessions` (or set `push_sessions` to false) until the team decides to publish sessions on purpose, and check what a transcript contains before the first push.
  - Temporary shadow branches may hold unredacted data. Do not push them.
  - Telemetry is on by default. Turn off with `--telemetry=false` if the team wants.
  - Our product never needs Entire at runtime. It is dev tooling only.
  - Do not paste health details, emails or keys into agent prompts while recording.

## Gemini (recommended prize pick, core to the scan)
- Prize: Best Use of Gemini API (MLH swag kits).
- Docs and key: TODO. Get a key from Google AI Studio, store it in an env var, never commit it.
- Gotchas to check in the hour-1 spike: refusals on stool images, latency, JSON validity, data-retention terms for the tier we use.

## Auth0 (login, invites; current logged opt-in until the prize decision)
- Docs and keys: TODO.
