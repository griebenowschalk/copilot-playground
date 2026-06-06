<!-- WHAT: shared baseline. WHO: both Claude Code + Copilot. WHEN: every request. Keep it short. -->
# Project: My App

Stack, commands, and hard rules that both tools need on every request.
Replace the placeholders below with your real project.

## Stack
- (e.g. Next.js + TypeScript + Postgres + Tailwind + Vitest)

## Commands
- `npm run dev` · `npm test` · `npm run lint`

## Non-negotiables
- Named exports only. Validate all input. Mirror the linter.

## Code graph (Graphify)
For architecture or cross-file questions, read `graphify-out/GRAPH_REPORT.md` or run
`graphify query "..."` before opening multiple source files. Rebuild after structural
changes: `graphify update .`. Copilot: type `/graphify` in chat.
