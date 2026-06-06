# Project: AI Harness Demo

Baseline context shared by ALL AI tools (Claude Code, GitHub Copilot, and any
agent that reads AGENTS.md). Keep this SHORT — it loads on every request.
Detailed, scoped rules live in `.github/instructions/*.instructions.md`.

## Stack
- Next.js 15 (App Router), TypeScript (strict), React 19
- SQLite via Prisma (zero-infra for the demo)
- Tailwind CSS v4
- Vitest + Testing Library
- pnpm

## Commands
- `pnpm setup`     — copy env, push schema, seed data (run once)
- `pnpm dev`       — start dev server (http://localhost:3000)
- `pnpm test`      — run tests
- `pnpm lint`      — next lint
- `pnpm typecheck` — tsc --noEmit

## Architecture (one direction of dependency)
UI (components/pages) → services → repositories (`src/db/repos`) → Prisma
- Components and route handlers NEVER import Prisma directly.
- Route handlers validate input, then delegate to a service.

## Non-negotiables
- Server Components by default; "use client" only when interactive.
- Named exports only. No default exports (except Next-required files).
- All external input validated with Zod (`src/lib/validation.ts`).
- Soft-delete with `deletedAt`; never hard-delete.
- Mirror the linter — never generate code that fails `pnpm lint`.

## Code graph (Graphify)
For architecture or cross-file questions, read `graphify-out/GRAPH_REPORT.md` or run
`graphify query "..."` before opening multiple source files. Rebuild after structural
changes: `graphify update .`. Copilot: type `/graphify` in chat.
