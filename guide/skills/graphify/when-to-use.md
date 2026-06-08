# Graphify — when to query vs when to read source

Use this with the PreToolUse hook (`graphify claude install`) and the `graphify` skill.
The hook nudges toward the graph; this file is the decision detail.

## Graph-first (query before Glob/Grep/Read)

| Situation | Why |
|-----------|-----|
| Cross-layer flows (API → service → repo → DB) | Graph returns the chain in one query |
| Onboarding to an unfamiliar area | `GRAPH_REPORT.md` + targeted queries replace repo scans |
| Refactors touching many modules | Find dependents and boundaries without opening every file |
| "Who calls what" / dependency debugging | `graphify path` and `graphify explain` |
| Architecture or codebase-structure questions | God nodes and communities in `GRAPH_REPORT.md` |

**Gate:** If `graphify-out/GRAPH_REPORT.md` exists:

1. Read `GRAPH_REPORT.md` for orientation **or** run `graphify query "<question>"`
2. Read source files **only** for gaps the query did not cover (exact lines, implementation detail)

## Do not force graph-first

| Situation | Why |
|-----------|-----|
| Editing one file with scoped instructions already loaded | Instructions + that file are enough |
| `graphify-out/` missing or `graphify stats` fails | No graph — use normal discovery; offer `graphify extract .` |
| Graph likely stale (large refactor since last extract) | Run `graphify update .` first, or read source if urgent |
| Need exact line-level text | Graph shows relationships, not full source |
| Tiny change in a known file | One `Read` is cheaper than query + follow-up reads |

## Keep the graph fresh

Recommended setup: `graphify hook install` once — AST-only rebuild on commit (no API cost).

| Situation | Action |
|-----------|--------|
| Hooks active, normal edits | Nothing — hook rebuilds on commit |
| `git pull`, hooks active | Usually nothing; `graphify update .` only if you need graph before next commit |
| `git pull`, no hooks | `graphify update .` |
| Graph stale / wrong (`graphify stats`) | `graphify update .` → then `graphify extract . --force` if still off |
| Huge refactor | `graphify extract . --force` |
</content>
