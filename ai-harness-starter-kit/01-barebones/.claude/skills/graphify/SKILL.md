---
name: graphify
description: Build or query a codebase knowledge graph for architecture questions without reading every file.
allowed-tools: Bash, Read
---
<!-- Claude skill. Invoke with /graphify. Copilot mirror: /graphify prompt in .github/prompts/. -->
Build or refresh the project knowledge graph, then answer codebase questions via
targeted queries instead of grepping or pasting full files.

## Build or refresh

```bash
graphify extract .              # full build (code-only, offline for TS/JS)
graphify update .               # incremental after edits
graphify stats                  # verify graph exists
```

Outputs land in `graphify-out/`:
- `GRAPH_REPORT.md` — one-page summary (god nodes, communities, suggested questions)
- `graph.json` — full graph for CLI queries

## Query before reading source

Prefer these over Glob/Grep/Read when exploring architecture:

```bash
graphify query "layer dependencies"
graphify query "what connects the API to the database?"
graphify path "SymbolA" "SymbolB"
graphify explain "SymbolName"
```

Read `graphify-out/GRAPH_REPORT.md` for broad orientation; use `graphify query`
for precise, hop-by-hop detail.

## When to rebuild

- After structural changes (new modules, moved files, renamed layers)
- After `git pull` with significant diffs — run `graphify update .`
- Optional: `graphify hook install` auto-rebuilds on commit (AST-only, no API cost)

See `GRAPHIFY_GUIDE.md` at the monorepo root for daily usage beyond harness setup.
