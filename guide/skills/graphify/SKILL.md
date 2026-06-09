---
name: graphify
description: >-
  Query the codebase knowledge graph before reading multiple files — use for
  architecture, cross-layer flows (API/service/repo), refactors spanning modules,
  onboarding, and "who calls what" debugging. Requires graphify-out/ from
  graphify extract. Do not use for single-file edits when scoped rules already apply.
when_to_use: >-
  Cross-layer questions, harness discovery, multi-module refactors, dependency
  tracing, or when the PreToolUse hook suggests consulting the graph.
allowed-tools: Bash, Read, Grep
---
<!-- Reference skill — auto-routes on architecture/cross-file tasks. Pair with graphify claude install PreToolUse hook. Copilot: /graphify prompt. -->
## Graph-first gate

**If `graphify-out/GRAPH_REPORT.md` exists:**

1. Run `graphify query "<question>"` (or read `GRAPH_REPORT.md` for broad orientation)
2. Use `graphify path` / `graphify explain` for precise hops
3. **Read source only for gaps** — exact lines, implementation detail the graph lacks

**If no graph:** run `graphify extract .` or fall back to normal Read/Grep. Do not block the task.

Full when-to-use / when-not: [when-to-use.md](when-to-use.md)

## Build or refresh

```bash
ls graphify-out/graph.json      # confirm the graph exists before big architecture questions
graphify extract .              # once at setup (or --force if graph is broken)
graphify hook install           # recommended — AST rebuild on commit
graphify update .               # after git pull if hooks off, or graph may be stale
```

Default: hooks keep the graph fresh — do not re-extract every session. See [when-to-use.md](when-to-use.md) § Keep the graph fresh.

## Query commands

```bash
graphify query "how does <RouteHandler> reach the database?"   # name a real symbol, e.g. POST()
graphify query "what calls <FunctionName>?"
graphify path "SymbolA" "SymbolB"
graphify explain "SymbolName"
```

**Phrase around concrete symbols that exist as graph nodes** (a route handler, function, or class name from `GRAPH_REPORT.md`), not abstract architecture terms (`"layer dependencies"`, `"architecture boundaries"`). Matching is keyword/BFS-based, not semantic — abstract phrasings often return "No matching nodes" or hit unrelated config strings (e.g. `"dependencies"` matching `package.json`), wasting a round-trip. If a query misses, look up a real symbol name and reformulate around it rather than retrying synonyms.
</content>
