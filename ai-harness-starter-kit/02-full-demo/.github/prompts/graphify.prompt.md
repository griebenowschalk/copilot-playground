---
mode: agent
description: Query the codebase knowledge graph — architecture, cross-layer flows, refactors, dependency tracing
---
<!-- Copilot manual command. Run with /graphify in Copilot Chat. -->
## Graph-first gate

**If `graphify-out/GRAPH_REPORT.md` exists:**

1. Read `GRAPH_REPORT.md` for orientation **or** run `graphify query "<question>"`
2. Use `graphify path` / `graphify explain` for precise hops
3. Read source files **only** for gaps (exact lines, implementation detail)

**If no graph:** tell the user to run `graphify extract .` — then use normal discovery.

## Use graph-first for

- Cross-layer flows (API → service → repo → DB)
- Architecture / onboarding / multi-module refactors
- "Who calls what" debugging

## Do not force for

- Single-file edits when scoped instructions already apply
- Stale/missing graph — run `graphify update .` first or read source
- Exact line-level text the graph cannot provide
- Tiny repos where one Read is cheaper

```bash
graphify query "<your question>"
graphify path "SymbolA" "SymbolB"
graphify explain "SymbolName"
```
