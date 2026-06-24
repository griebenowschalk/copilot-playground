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

## Team setup (per-dev, local-only)

`graphify-out/` is gitignored — every dev builds and maintains their own graph
locally; only this skill and `.graphifyignore` are shared via the repo. Setup is
opt-in and runs **once**; nothing reinstalls graphify on every dev run.

**One-time per clone:** install the CLI (`uv tool install graphifyy`), install
the git hooks (`graphify hook install` — `.git/hooks/` isn't versioned, so this
is per clone, not shared), then `graphify extract .` for the initial build. A
small setup script wired to a package command (e.g. `npm run graphify:setup`)
makes this one command for teammates.

**Automatic updates afterwards** — all incremental + AST-only (no LLM/API cost),
so the local graph is never stale when you query it:

| When | Mechanism |
|------|-----------|
| Editing during dev | Dev-server file watcher (Vite/webpack/nodemon) → debounced `graphify update .` — closes the uncommitted-edit staleness gap |
| `git commit` | post-commit hook (background) |
| `git checkout` / `git pull` (branch switch) | post-checkout hook (background) |

Guard the watcher (`[ -d graphify-out ] && command -v graphify …`) so it's a
silent no-op for devs who never ran setup — graphify stays fully opt-in.

## Query commands

```bash
graphify query "how does <RouteHandler> reach the database?"   # name a real symbol, e.g. POST()
graphify query "what calls <FunctionName>?"
graphify path "SymbolA" "SymbolB"
graphify explain "SymbolName"
```

**Phrase around concrete symbols that exist as graph nodes** (a route handler, function, or class name from `GRAPH_REPORT.md`), not abstract architecture terms (`"layer dependencies"`, `"architecture boundaries"`). Matching is keyword/BFS-based, not semantic — abstract phrasings often return "No matching nodes" or hit unrelated config strings (e.g. `"dependencies"` matching `package.json`), wasting a round-trip. If a query misses, look up a real symbol name and reformulate around it rather than retrying synonyms.

## Reference docs (`references/`)

Deeper, load-on-demand docs for specific graphify operations (installed alongside this skill). Read the relevant one **only** when its task comes up — they are not loaded by default:

| File | Read when… |
|------|------------|
| `references/query.md` | Running `query` / `path` / `explain` — the full traversal flow |
| `references/update.md` | Incremental `--update` or `--cluster-only` rebuilds |
| `references/hooks.md` | Installing the post-commit hook or wiring graphify into `CLAUDE.md` |
| `references/add-watch.md` | `add <url>` or `--watch` a folder |
| `references/exports.md` | Export flags (`--wiki`, `--neo4j`, `--svg`, `--graphml`, `--mcp`, …) or the token-reduction benchmark |
| `references/extraction-spec.md` | Semantic extraction of doc / paper / image inputs |
| `references/github-and-merge.md` | Cloning GitHub URLs or merging multiple repos/folders into one graph |
| `references/transcribe.md` | Transcribing video / audio inputs |
