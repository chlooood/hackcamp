# Team guide: stay in sync with Claude Code and Entire

Send this to the team. Setup takes about 10 minutes on Windows.

## What keeps everyone updated (read this first)
1. **The `context/` folder in the repo is the shared brain.** `CLAUDE.md` tells Claude Code to read every file in `context/` before it starts, and to update `status.md` and `decisions.md` when it finishes. If everyone pulls before and pushes after, everyone's Claude knows what everyone else did. This works with no extra tools.
2. **Entire records the sessions** (every prompt, reply and file change) on top of that. It is a bonus for seeing how something was built, and it is what the Entire prize looks at. It does NOT share anything on its own. By default your sessions stay on your laptop.

## One-time setup
1. Clone the repo (skip if you have it):
   ```powershell
   cd $HOME\Documents
   git clone https://github.com/chlooood/hackcamp.git
   cd hackcamp
   ```
2. Install Scoop, then open a NEW PowerShell window:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
   ```
3. Install Entire (the package is `entire/entire`, not `entire/cli`):
   ```powershell
   scoop bucket add entire https://github.com/entireio/scoop-bucket.git
   scoop install entire/entire
   entire version
   ```
4. Turn it on in the repo, with pushing OFF:
   ```powershell
   git pull
   entire enable --agent claude-code --skip-push-sessions
   entire status
   ```
   You should see "Enabled" and "push_sessions=false". LF/CRLF warnings are harmless.

## Every work session
1. `git pull` first.
2. Open your terminal in the repo and start Claude Code. Paste this as your first prompt:
   > Read every file in context/ first. Then do: <what you want>. When you finish, update context/status.md (done, in progress, next, blockers), append one line to context/decisions.md for any choice we made, then commit and push.
3. Before you stop, check `git status` is clean and `git push` worked.

## Rules that stop conflicts
- `decisions.md` is append only. Never rewrite old lines. If git reports a conflict there, keep both sides.
- `status.md` is overwritten each session. If two people overwrite it, pull, merge by hand, keep both people's "done" items.
- One owner per file where possible: design lead owns the mascot, screens and copy; backend owns the API and database; research and pitch own slides and sources.
- Never commit a key. Gemini and Auth0 keys go in a local `.env` file that is gitignored.
- Do not paste personal health details, emails or keys into prompts while Entire is recording.

## Sharing sessions between teammates (optional, one person sets it up)
Entire can send checkpoints to a SEPARATE private repo instead of the public one. Facts below are from docs.entire.io; the reading step is untested.
1. Create an EMPTY private repo under the SAME GitHub account as the code repo, for example `chlooood/hackcamp-sessions`. Add the teammates as collaborators. A different owner does not work: Entire skips the private repo and falls back to the pusher's own origin.
2. Run `entire configure --checkpoint-remote github:chlooood/hackcamp-sessions`.
3. Open `.entire/settings.json` and change `"push_sessions": false` to `true`. While it is false, Entire pushes nothing to any remote, including the private repo. It should end up like this:
   ```json
   {
     "enabled": true,
     "strategy_options": {
       "push_sessions": true,
       "checkpoint_remote": { "provider": "github", "repo": "chlooood/hackcamp-sessions" }
     },
     "checkpoints": { "primary": { "type": "git-refs" } }
   }
   ```
4. BEFORE the first push, read what is stored: `entire checkpoint explain`. Secret redaction is best effort. The first push sends all earlier checkpoints.
5. Commit and push `.entire/settings.json`. Teammates `git pull`.
6. Everyone pushes straight to `chlooood/hackcamp` as a collaborator. Never push from a fork.
7. Check on GitHub: the private repo has an `entire/checkpoints/v1` branch and the public repo does not. If a teammate wants their sessions kept private, they put `"push_sessions": false` in `.entire/settings.local.json` (gitignored).

Not yet tested by us: how a teammate reads someone else's session. The documented commands are `entire session resume <branch>` and `entire checkpoint explain`. Try it with one small commit before relying on it. The `context/` files already cover day-to-day updates either way.

## Gemini key
Get a free key at Google AI Studio. Save it in a local `.env` file as `GEMINI_API_KEY=...`. Never commit it.
