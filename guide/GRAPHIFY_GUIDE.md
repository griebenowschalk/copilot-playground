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

## Build and refresh

Run from the **project workspace root** (e.g. `02-full-demo/`), not the monorepo parent:

```bash
cd ai-harness-starter-kit/02-full-demo   # example
graphify extract .          # full build (code-only, offline for TS/Prisma)
graphify update .           # incremental after edits
graphify stats              # verify graph exists
graphify hook install       # optional: auto-rebuild on commit (AST-only)
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

- Type `/graphify .` to build or refresh the graph
- Type `/graphify query "..."` for targeted questions
- PreToolUse hook (from `graphify claude install --project`) nudges toward the graph before Glob/Grep/Read storms
- `CLAUDE.md` routing table includes architecture → `GRAPH_REPORT.md`

## In GitHub Copilot (VS Code)

- Type `/graphify` in Copilot Chat, then ask your architecture question
- Copilot runs `graphify query` via terminal instead of opening many files
- `AGENTS.md` and `copilot-instructions.md` include a short graph-first reminder
- No PreToolUse hook — guidance lives in always-on files + the `/graphify` prompt

## Daily workflow

**Morning (after pull):**
```bash
graphify update .
```

**During work:** ask architecture questions via `/graphify query` (Claude) or `/graphify` (Copilot) before pasting code snippets.

**After structural changes** (new modules, moved files, renamed layers):
```bash
graphify extract .          # or graphify update .
```

## Token tip

| Approach | Typical cost |
|----------|--------------|
| Paste 4 related files + question | ~600+ tokens |
| `GRAPH_REPORT.md` + 2 queries + question | ~150–250 tokens |
| Single `graphify query` for a focused hop | ~30–80 tokens |

Example: *"How do tasks flow from the API to the database?"* — the graph returns
route → service → repo → Prisma without reading those four files.

## When to rebuild

- After `git pull` with significant structural diffs
- After adding modules, routes, or services
- Before a large refactor or architecture review
- Use `graphify update .` for incremental; `graphify extract . --force` if graph looks stale or shrunk after a refactor

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
