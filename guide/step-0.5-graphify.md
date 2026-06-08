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

Exclude build artifacts **and markdown docs** from the graph. Graphify treats `.md` files as documents and runs **LLM semantic extraction** on them (requires an API key and adds harness/setup prose you usually do not want in a code graph). Prefer a **code-only** graph via tree-sitter (offline, no API key for TS/Prisma).

Example for Next.js + Prisma apps:

```
node_modules/
.next/
out/
*.db
src/generated/
graphify-out/

README.md
docs/
```

Add other root markdown as needed (`AGENTS.md`, `CLAUDE.md`, …) or use `*.md` if the repo has no source markdown you need in the graph.

---

## 0.5.2 Build and install

```bash
graphify extract .
graphify install --project
graphify claude install --project    # required — PreToolUse hook nudges graph before Glob/Grep/Read
graphify vscode install --project
graphify hook install                # recommended — AST-only rebuild on commit (no API cost)
```

Verify hooks: `graphify hook status`

**Outputs:**

- `graphify-out/GRAPH_REPORT.md` — god nodes, communities, suggested questions
- `graphify-out/graph.json` — queryable graph
- `.claude/skills/graphify/SKILL.md` + `when-to-use.md` — graph-first gate and query playbook
- `.github/prompts/graphify.prompt.md` — Copilot `/graphify` prompt (create if not auto-installed)
- CLAUDE.md graphify routing row + PreToolUse hook (via `graphify claude install --project`)
- Short Graphify line in `AGENTS.md` (via `graphify vscode install` — merge in Step 2; keep minimal)

Verify: `graphify stats`

---

## 0.5.3 Graph-first skill *(Graphify only)*

`graphify install --project` may create a minimal skill — **replace or merge** with the harness template from `01-barebones/.claude/skills/graphify/`:

| File | Role |
|------|------|
| `SKILL.md` | Graph-first gate, query commands, `description` tuned for auto-routing on architecture/cross-file tasks |
| `when-to-use.md` | When to query vs when to read source (progressive disclosure — not loaded unless linked) |

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
| Big refactor / graph looks wrong (`graphify stats`) | `graphify update .` first; then `graphify extract . --force` if still stale |
| Fast refresh, skip clustering | `graphify update . --no-cluster` |

Do **not** run `graphify extract .` every session — use `update` incrementally; full extract is the exception.

---

> **AI-DLC checkpoint — Phase 0.5**
> **Ask:** *"Enable Graphify for this project?"* If **no**, skip to Phase 1 (`step-1-claude.md`) with `/init`. If **yes**, run **0.5.0 check-and-install**: preflight → install if missing → re-verify. Only run **0.5.1–0.5.4** when `graphify --version` succeeds — include **`graphify hook install`** (recommended). If install fails or human skips, continue to Phase 1 with `/init`.

**Next:** `step-1-claude.md`
