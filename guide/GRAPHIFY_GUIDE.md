# Graphify — Daily Reference

Short guide for using Graphify with the AI harness in this repo. Graphify is
**optional** during harness setup — Phase 0.5 asks whether you want it. If you
skipped it, you can add Graphify later using [`step-0.5-graphify.md`](step-0.5-graphify.md).

## What it is

Graphify builds a **queryable knowledge graph** of your codebase — symbols,
relationships, and architecture — so Claude Code and GitHub Copilot can answer
cross-file questions without reading or pasting entire files.

## Where it sits in the harness

```
AGENTS.md (always-on, short)
    ↓
Graphify — GRAPH_REPORT.md + graphify query (on demand, code relationships)
    ↓
CLAUDE.md routing / .github/instructions/* / docs/context/* (on demand, rules & domains)
    ↓
Read/Grep raw files (last resort)
```

Query the graph first (~30–150 tokens). Read source files only when the graph
lacks detail.

## Harness layers (when Graphify is enabled)

| Layer | What it does |
|-------|----------------|
| **PreToolUse hook** | `graphify claude install --project` — nudges before Glob/Grep/Read storms |
| **`graphify` skill** | Graph-first gate + query commands; auto-routes on architecture/cross-file tasks |
| **`when-to-use.md`** | When to query vs read source — linked from skill, not in `AGENTS.md` |
| **`AGENTS.md` one-liner** | Short reminder only — do not paste full workflow here |
| **Copilot `/graphify` prompt** | Manual graph-first for VS Code Copilot (no hook) |

See [`skills/graphify/when-to-use.md`](skills/graphify/when-to-use.md) in this guide folder for the full decision table — it's the template copied to `.claude/skills/graphify/when-to-use.md` in the target repo.

## One-time install (per machine)

**Requires Python 3.10+.** Check first:

```bash
python3 --version    # must be 3.10.0 or higher — not macOS system 3.9.x
```

If below 3.10, install a newer Python before Graphify (see below). **If you cannot upgrade, skip Graphify** — the harness works without it ([`step-0.5-graphify.md`](step-0.5-graphify.md)).

```bash
uv tool install graphifyy   # recommended — PyPI: graphifyy (double-y); CLI: graphify
graphify --version
```

Alternatives: `pipx install graphifyy` or `python3.12 -m pip install graphifyy --user`.

### macOS: system Python is often 3.9.x

Graphify will not install on Python 3.9. Upgrade first:

```bash
brew install python@3.12 uv
uv tool install graphifyy
graphify --version
```

Or: `brew install python@3.12 pipx && pipx install graphifyy`, or install from [python.org/downloads/macos](https://www.python.org/downloads/macos/).

First project setup: opt in at Phase 0.5 — follow [`step-0.5-graphify.md`](step-0.5-graphify.md) (Step 0.5.0 runs check-and-install when selected).

### Harness setup: check and install

When Graphify is enabled during harness rollout, Step 0.5.0:

1. Runs `python3 --version` and `graphify --version`
2. If missing → installs Python 3.10+ (if needed) then `graphifyy` via uv → pipx → pip
3. Re-verifies before `graphify extract .`

Skip only if install fails or you decline — harness continues with `/init`.

### Adding Graphify after harness setup

If you skipped Graphify during rollout, run [`step-0.5-graphify.md`](step-0.5-graphify.md) anytime —
then add the Graphify section to `AGENTS.md`, the routing row to `CLAUDE.md`, and
merge the PreToolUse hook per [`step-3-claude-folder.md`](step-3-claude-folder.md) §3.2.

## Key outputs (per project)

| Path | Purpose |
|------|---------|
| `graphify-out/GRAPH_REPORT.md` | One-page summary — god nodes, communities, suggested questions |
| `graphify-out/graph.json` | Full graph for CLI queries |
| `.claude/skills/graphify/SKILL.md` | Claude `/graphify` skill |
| `.github/prompts/graphify.prompt.md` | Copilot `/graphify` prompt |

`graphify-out/` is gitignored — rebuild locally after clone.

## Update strategy

Run all commands from the **project workspace root** (the target repo's root, where the harness files live), not a monorepo parent.

### Setup once

```bash
graphify extract .              # full build (code-only with .graphifyignore)
graphify hook install           # recommended — AST-only rebuild on commit, no API cost
graphify hook status            # verify hooks are active
```

### Decision tree (daily)

```
graphify-out/ missing?
  └─ yes → graphify extract .
  └─ no  → hooks installed? (graphify hook status)
            ├─ yes → normal work: do nothing (hook rebuilds on commit)
            │        git pull: usually nothing; run graphify update . only if you
            │        need accurate graph before your next commit
            └─ no  → git pull or end of day → graphify update .

graph looks wrong? (graphify stats — node count dropped, stale answers)
  └─ graphify update . first
  └─ still wrong → graphify extract . --force

big refactor / changed .graphifyignore?
  └─ graphify extract . --force
```

### Command cheat sheet

| Command | When |
|---------|------|
| `graphify extract .` | First time only (or after clone before hooks) |
| `graphify hook install` | **Recommended** at setup — best ongoing ROI |
| `graphify update .` | After `git pull` without hooks, or before architecture work if graph may be stale |
| `graphify update . --no-cluster` | Faster incremental refresh; skip community clustering |
| `graphify extract . --force` | Graph shrunk, wrong, or huge structural change |
| `graphify stats` | Sanity check before a big architecture session |

**Avoid:** `graphify extract .` every session — full re-parse is wasteful when `update` or git hooks suffice.

### Build and refresh (quick reference)

```bash
cd <target-repo-root>       # the project workspace root
graphify extract .          # once at setup
graphify hook install       # recommended
graphify update .           # incremental when hooks are off or after pull
graphify stats              # verify graph health
```

## Query commands

```bash
graphify query "how do API routes reach the database?"
graphify query "layer dependencies"
graphify path "SymbolA" "SymbolB"
graphify explain "SymbolName"
```

Read `GRAPH_REPORT.md` for broad orientation; use `graphify query` for precise hops.

## In Claude Code

- **PreToolUse hook** (`graphify claude install --project`) — primary automatic nudge before Glob/Grep/Read
- **`graphify` skill** — graph-first gate; auto-routes on architecture/cross-file tasks via `description`
- `/graphify` or `graphify query "..."` for targeted questions
- `CLAUDE.md` routing row → `.claude/skills/graphify/SKILL.md`
- Decision detail: `when-to-use.md` in the skill folder (when to query vs read source)

## In GitHub Copilot (VS Code)

- Type `/graphify` in Copilot Chat, then ask your architecture question
- Copilot runs `graphify query` via terminal instead of opening many files
- `AGENTS.md` and `copilot-instructions.md` include a short graph-first reminder
- No PreToolUse hook — guidance lives in always-on files + the `/graphify` prompt

## Daily workflow

**If `graphify hook install` is active:** commits keep the graph fresh — no manual update needed for normal edits.

**Morning (after `git pull`):**
```bash
graphify hook status        # if active, skip unless you need the graph before committing
graphify update .           # only if hooks off, or pull had big structural changes
```

**During work:** `/graphify query` (Claude) or `/graphify` (Copilot) before pasting multiple files.

**Structural changes** (new modules, moved files): hook handles on commit; if hooks off, `graphify update .`. Full `extract . --force` only if `graphify stats` looks wrong.

## Token tip

| Approach | Typical cost |
|----------|--------------|
| Paste 4 related files + question | ~600+ tokens |
| `GRAPH_REPORT.md` + 2 queries + question | ~150–250 tokens |
| Single `graphify query` for a focused hop | ~30–80 tokens |

Example: *"How do tasks flow from the API to the database?"* — the graph returns
route → service → repo → Prisma without reading those four files.

## When to rebuild

See **Update strategy** above. Short version: `update` incrementally; `extract --force` only when the graph is broken or after a major restructure; rely on **git hooks** for everything else.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Python 3.9.x / "requires Python ≥3.10" | Upgrade Python (see above) **or skip Graphify** — harness continues with `/init` |
| No `uv` / `pipx` | `brew install uv` then `uv tool install graphifyy`, or use Homebrew Python + pip |
| Empty or tiny graph | Check `.graphifyignore` isn't excluding source; run from project root |
| README.md triggers LLM extraction | Add `README.md` (and `docs/`) to `.graphifyignore` for code-only graphs — see `step-0.5-graphify.md` §0.5.1 |
| Stale answers | `graphify update .` or `graphify extract . --force` |
| `graphify: command not found` | `step-0.5-graphify.md` §0.5.0 install flow: `uv tool install graphifyy` (needs Python 3.10+) |
| Hook conflicts in Claude | See `step-3-claude-folder.md` §3.2 — merge PreToolUse, don't overwrite |
| Copilot ignores graph | Run `/graphify` prompt explicitly; verify `graphify-out/` exists |

## Further reading

- [graphify.net](https://graphify.net/) — upstream docs and command reference
- [`HARNESS_SETUP_GUIDE.md`](HARNESS_SETUP_GUIDE.md) — hub + AI-DLC runbook
- [`step-0.5-graphify.md`](step-0.5-graphify.md) — harness integration
