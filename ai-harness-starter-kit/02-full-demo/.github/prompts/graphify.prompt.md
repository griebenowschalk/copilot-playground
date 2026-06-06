---
mode: agent
description: Query the codebase knowledge graph for architecture and flow questions
---
<!-- Copilot manual command. Run with /graphify in Copilot Chat. -->
For architecture, data flow, or "how does X connect to Y" questions:

1. If `graphify-out/GRAPH_REPORT.md` exists, read it first for orientation.
2. Run targeted queries via terminal: `graphify query "<question>"`
3. Use `graphify path "SymbolA" "SymbolB"` or `graphify explain "SymbolName"` for precise hops.

Do NOT read or paste multiple source files when the graph can answer. Read individual
files only for gaps the query missed.

If no graph exists yet, tell the user to run `graphify extract .` from the project root.
