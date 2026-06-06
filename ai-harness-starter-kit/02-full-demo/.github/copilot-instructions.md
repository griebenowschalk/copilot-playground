# Copilot Instructions

Next.js 15 (App Router) + TypeScript + Prisma/SQLite + Tailwind v4 + Vitest,
pnpm. See `AGENTS.md` for commands and architecture.

## How rules are organized
Detailed, scoped rules live in `.github/instructions/*.instructions.md` and load
automatically based on the file you are editing (each file's `applyTo` glob).

## Always-on essentials
- Server Components by default; "use client" only when interactive.
- Named exports only — no default exports (except Next-required files).
- DB access only via `src/db/repos/`; route handlers delegate to services.
- All input validated with Zod; errors typed (no `catch (e: any)`).
- Mirror the linter; never produce code that fails `pnpm lint`.

Reusable workflows live in `.github/prompts/` (e.g. `/review`, `/figma`, `/graphify`).
MCP servers (incl. Figma) are configured in `.vscode/mcp.json`.

For architecture or flow questions, use `/graphify` or read `graphify-out/GRAPH_REPORT.md`
before grepping multiple files.
