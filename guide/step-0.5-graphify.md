# Step 0.5: Build codebase graph (Graphify) — optional

**Phase 0.5 · AI-DLC checkpoint at end of this file**

Graphify is **not required** for the harness. Skip this step if you declined Graphify at Phase 0.5 **or preflight failed** — go to `step-1-claude.md` and use `/init` discovery. A failed Graphify install is not a harness failure.

For general Graphify usage (queries, skills, troubleshooting), see `GRAPHIFY_GUIDE.md` in this folder. This file covers **harness integration only**.

Run from the **project workspace root** (where harness files will live).

---

## 0.5.0 Check and install Graphify *(when opted in)*

Run these checks from the project root **before** creating `.graphifyignore` or running `graphify extract`.

### Preflight

```bash
python3 --version
command -v graphify >/dev/null && graphify --version || echo "graphify not installed"
command -v uv >/dev/null && uv --version || true
command -v pipx >/dev/null && pipx --version || true
command -v brew >/dev/null && brew --version || true
```

| Check | Pass | Fail → action |
|-------|------|----------------|
| `graphify --version` | Continue to **0.5.1** | Start **install flow** below |
| Python ≥ 3.10 | Required for install | Install Python first (2a), then graphify (2b) |

The PyPI package is **`graphifyy`** (double-y); the CLI command is `graphify`.

### Install flow *(AI-DLC: show plan, get approval, then run)*

**2a — Python < 3.10** (e.g. macOS system `3.9.6`):

```bash
brew install python@3.12 uv
```

No Homebrew? Offer [python.org/downloads](https://www.python.org/downloads/macos/) or `pyenv`. Re-check: `python3 --version`.

**2b — Install `graphify` CLI** (pick first available):

```bash
uv tool install graphifyy          # A — recommended
pipx install graphifyy             # B
python3.12 -m pip install --user graphifyy   # C — ensure ~/.local/bin on PATH
```

**2c — Verify**

```bash
graphify --version
```

| Result | Action |
|--------|--------|
| Success | Continue to **0.5.1** |
| Still missing / install error | Ask human: **retry**, **fix manually**, or **skip Graphify** → Phase 1 `/init` |

> **AI-DLC:** Do not skip Graphify on first failed check — run the install flow first. Only skip after a failed install attempt or explicit human decline.

If the facilitator cannot run brew/uv (sandbox, permissions), print the exact commands for the human to run locally, wait for confirmation, then re-run `graphify --version`.

---

## 0.5.1 Add `.graphifyignore`

Exclude build artifacts, lock files, and all non-code files from the graph. Graphify uses **tree-sitter** for code files (offline, no API key) but falls back to **LLM semantic extraction** for anything tree-sitter can't parse — markdown, YAML, HTML, shell scripts, etc. That fallback requires an API key and burns tokens on content that adds no graph signal. The template below is the recommended default for most repos; trim or extend as needed.

```
# ── Build outputs (all major frameworks) ──────────────────────────
node_modules/
.next/
out/
dist/
build/
.svelte-kit/
.nuxt/
.output/
.turbo/
.vercel/
storybook-static/
__pycache__/
.tox/
venv/
.venv/

# ── Generated & cache ─────────────────────────────────────────────
src/generated/
graphify-out/
coverage/
.cache/
.nyc_output/
**/__snapshots__/

# ── Lock files (large, zero signal for the graph) ─────────────────
pnpm-lock.yaml
yarn.lock
package-lock.json
bun.lockb
*.lock

# ── Non-code files that trigger LLM extraction ────────────────────
# tree-sitter can't parse these — Graphify falls back to LLM,
# which requires an API key and adds no useful code-graph signal.
*.md
**/*.md
*.txt
**/*.txt
*.html
*.xml
*.yaml
*.yml
*.sh
Dockerfile
docs/
guide/
*.log
logs/

# ── Media / binary (no code signal) ───────────────────────────────
*.png
*.jpg
*.jpeg
*.gif
*.ico
*.webp
*.svg
*.mp4
*.mov
*.mp3
*.wav
*.ttf
*.woff
*.woff2
*.eot
*.otf
*.zip
*.tar.gz
*.gz
*.tgz
*.pdf

# ── Data files ────────────────────────────────────────────────────
*.db
*.sqlite
*.sqlite3
*.csv

# ── IDE / CI / test infra ─────────────────────────────────────────
.idea/
.github/
e2e/
playwright/
cypress/

# ── Env files ─────────────────────────────────────────────────────
.env
.env.*

# ── Common top-level non-code dirs (add repo-specific ones below) ──
static/
public/
icons/
```

**Repo-specific additions to consider:**

| Pattern | Add when… |
|---------|-----------|
| `*.stories.tsx` | Storybook files in `src/` |
| `prisma/migrations/` | Migration SQL files (schema is enough for the graph) |
| `scripts/` | Shell/infra scripts not part of the call graph |
| `packages/<name>/` | Monorepo packages you're not graphing this run |

After writing the file, run `graphify extract .` and verify output in `graphify-out/GRAPH_REPORT.md` — if node/community counts look unreasonably high, a non-code directory is likely still included.

---

## 0.5.2 Build and install

```bash
graphify extract .
graphify install --project
graphify claude install --project    # required — PreToolUse hook nudges graph before Glob/Grep/Read
graphify vscode install --project
graphify hook install                # commit-rebuild hook — ONLY if setup root == git root (see below)
```

Verify hooks: `graphify hook status`

> **⚠ `graphify hook install` is git-repo-scoped, not folder-scoped.** It writes `post-commit` / `post-checkout` into the repo's single `.git/hooks/`, and git runs them from the **git root** (top of the working tree) using the relative path `graphify-out`. So the rebuild always targets the **git root**, regardless of which folder you ran setup in.
>
> **Before running it, check the setup root is the git root:**
>
> ```bash
> [ "$(git rev-parse --show-toplevel)" = "$PWD" ] && echo "git root — safe to install hook" || echo "SUBDIR — skip hook install"
> ```
>
> If the harness target is a **subdirectory** of a larger repo (e.g. setting up `packages/api` or a demo project inside a monorepo), **skip `graphify hook install`** — otherwise it rebuilds (and creates a stray `graphify-out/`) at the git root on every commit. Refresh that subproject's graph manually instead with `graphify update .` (see 0.5.4). Only install the hook when the project root and the git root are the same directory.

**Keep graph output out of git.** `graphify extract` writes `graphify-out/` to the project root, but Graphify does **not** add it to `.gitignore` for you. Add it yourself so it never lands in version control (create a `.gitignore` if the repo has none):

```gitignore
graphify-out/
```

This is separate from the `.graphifyignore` entry in 0.5.1: `.graphifyignore` stops Graphify from graphing its own output; `.gitignore` stops git from tracking it. You need both. The graph is a local cache — teammates rebuild it after clone with `graphify extract .`.

> **Known quirk:** `graphify install --project` may also drop a stray `.claude/CLAUDE.md` containing just the skill-routing line (e.g. `# graphify` + a `.claude/skills/graphify/SKILL.md` pointer). Claude Code does **not** auto-load `CLAUDE.md` from inside `.claude/` — only the root `CLAUDE.md` (and any `CLAUDE.md` in the directory you're working in) — so that file would sit unused. Fold its routing line into the root `CLAUDE.md` (as a routing row, see `step-1-claude.md`), then force-delete the stray file: `rm -f .claude/CLAUDE.md`.

**Outputs:**

- `graphify-out/GRAPH_REPORT.md` — god nodes, communities, suggested questions
- `graphify-out/graph.json` — queryable graph
- `.claude/skills/graphify/SKILL.md` + `when-to-use.md` — graph-first gate and query playbook (visible to Copilot Chat directly as `/graphify`, no separate prompt file)
- CLAUDE.md graphify routing row + PreToolUse hook (via `graphify claude install --project`)
- Short Graphify line in `AGENTS.md` (via `graphify vscode install` — merge in Step 2; keep minimal)

Verify: `ls graphify-out/graph.json` (and skim `graphify-out/GRAPH_REPORT.md`)

---

## 0.5.3 Graph-first skill *(Graphify only)*

`graphify install --project` writes its own multi-hundred-line pipeline `SKILL.md` — **replace or merge** with the harness template at [`skills/graphify/`](skills/graphify/) in this guide folder (copy to `.claude/skills/graphify/` in the target repo):

| File | Role |
|------|------|
| `SKILL.md` | Graph-first gate, query commands, `description` tuned for auto-routing on architecture/cross-file tasks |
| `when-to-use.md` | When to query vs when to read source (progressive disclosure — not loaded unless linked) |

> **AI-DLC — don't read the auto-installed `SKILL.md` to overwrite it.** It is the full graphify pipeline skill (~600 lines), and an agent's Write-over-existing-file requires a prior Read — so overwriting it pulls all ~600 lines into context for nothing (you discard them on write). In the default **replace** case, `rm -f .claude/skills/graphify/SKILL.md` first, then write the template as a net-new file (no Read needed). Same pattern as the stray `.claude/CLAUDE.md` deletion above. Only Read it when you genuinely need to **merge** project-specific query examples the template lacks.

**Do not** paste the full graph-first workflow into `AGENTS.md` — the hook + skill carry that behavior; `AGENTS.md` stays one short line (Step 2).

**Three layers (use all when Graphify is on):**

1. **PreToolUse hook** (`graphify claude install`) — automatic nudge before search/read storms
2. **`graphify` skill** — decision gate + query commands when architecture tasks match
3. **`AGENTS.md` one-liner** — fallback reminder for Copilot (no hook)

Update `CLAUDE.md` routing row to point at `.claude/skills/graphify/SKILL.md` (see `step-1-claude.md`).

---

## 0.5.4 Update strategy *(recommended)*

Default playbook — full detail in `GRAPHIFY_GUIDE.md` § Update strategy:

| When | Command |
|------|---------|
| First setup / no `graphify-out/` | `graphify extract .` |
| After setup | `graphify hook install` **(recommended)** — graph stays fresh on commit |
| `git pull` (hooks on) | Usually nothing — hook rebuilds on next commit; run `graphify update .` if you need the graph **before** committing |
| `git pull` (no hooks) | `graphify update .` |
| Normal day (hooks on) | Nothing — query freely |
| Big refactor / graph looks wrong (`GRAPH_REPORT.md` counts look off) | `graphify update .` first; then `graphify extract . --force` if still stale |
| Fast refresh, skip clustering | `graphify update . --no-cluster` |

Do **not** run `graphify extract .` every session — use `update` incrementally; full extract is the exception.

### Live freshness during dev *(optional — recommended for active sessions)*

The git hooks refresh the graph on commit/checkout, but **not while you edit uncommitted code** — so a mid-session architecture query can hit a stale graph. If the project has a dev-server file watcher, wire a debounced, guarded `graphify update .` into it to close that gap (AST-only, no API cost). Vite example (`vite-plugin-watch-and-run`, already common in SvelteKit/Vite repos):

```js
{
  name: 'graphify',
  watchKind: ['add', 'change', 'unlink'],
  watch: path.resolve('src/**/*.{ts,svelte}'),
  run: '[ -d graphify-out ] && command -v graphify >/dev/null 2>&1 && graphify update . || true',
  delay: 2000,
}
```

The guard makes it a **no-op** for devs without graphify or a local graph (keeps it opt-in). Same idea for webpack watch hooks, `nodemon`, or a `chokidar` script in non-JS stacks.

### Per-clone hook setup *(teams)*

`.git/hooks/` is **not versioned**, so teammates who clone don't get the commit/checkout hooks automatically. Provide a **one-time** setup script (CLI install if missing → `graphify hook install` → point at the initial `graphify extract .`) wired to a package command, e.g. `npm run graphify:setup`. Do **not** put `graphify hook install` in a per-run `predev`/dev-start step — re-running it on every dev start reads as a reinstall; the dev-server watcher above is what keeps the graph fresh day to day.

---

> **AI-DLC checkpoint — Phase 0.5**
> **Ask:** *"Enable Graphify for this project?"* — and size the recommendation to the codebase: Graphify's payoff (structured call-chain answers replacing multi-file reads) scales with codebase size and interconnectedness, while setup (extract, install × 3, hook install) and the always-on PreToolUse hook are **fixed costs** paid regardless of size. On a small or shallow codebase (rough heuristic: a couple dozen files, 1–2 hop call chains), reading the handful of relevant files directly is often just as fast — lean toward `/init` there. On larger, more interconnected codebases, lean toward enabling. If **no**, skip to Phase 1 (`step-1-claude.md`) with `/init`. If **yes**, run **0.5.0 check-and-install**: preflight → install if missing → re-verify. Only run **0.5.1–0.5.4** when `graphify --version` succeeds. **Run `graphify hook install` only if the setup root is the git root** (0.5.2) — skip it for a subdirectory/monorepo-package setup, or it rebuilds a stray `graphify-out/` at the git root on every commit. Always add `graphify-out/` to `.gitignore` (0.5.2). If install fails or human skips, continue to Phase 1 with `/init`.

**Next:** `step-1-claude.md`
