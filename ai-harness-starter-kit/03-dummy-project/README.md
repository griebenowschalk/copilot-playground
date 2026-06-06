# 03-dummy-project — AI-DLC harness test fixture

A **harness-free** mini tasks app for repeatedly testing
[HARNESS_SETUP_GUIDE.md](../../HARNESS_SETUP_GUIDE.md) in AI-DLC mode. Same stack as
`02-full-demo` (Next.js + TypeScript + Prisma/SQLite + Tailwind + Vitest), but with
no `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.github/`, `.vscode/`, or `docs/`.

When the harness is fully built (including later guide steps), the tree should match
the file map in [01-barebones/LEARN.md](../01-barebones/LEARN.md).

## Quick start

```bash
pnpm install && pnpm setup && pnpm dev   # http://localhost:3000
pnpm test && pnpm lint && pnpm typecheck
```

## AI-DLC loop

1. Open **copilot-playground** as your workspace (the guide lives at repo root).
2. Paste this prompt (note the scoped path — harness files go under `03-dummy-project/`,
   not the monorepo root):

```
Implement the AI harness in ai-harness-starter-kit/03-dummy-project/
by following HARNESS_SETUP_GUIDE.md using the AI-DLC section.

All harness files must live under 03-dummy-project/, not the monorepo root.
Work one phase at a time. Pause at every AI-DLC checkpoint.
Start with Phase 0 kickoff. Do not write AGENTS.md until CLAUDE.md is approved.
Stop at end of Step 4.
```

3. Work through checkpoints; approve drafts before the agent writes files.

## Reset and re-run

After a partial or **full** harness build:

```bash
./scripts/reset-harness.sh
```

This removes everything in the [01-barebones/LEARN.md](../01-barebones/LEARN.md) file map
(`AGENTS.md`, `CLAUDE.md`, `.mcp.json`, `.github/`, `.vscode/`, `.claude/`, `docs/`, etc.)
and restores `.env.example` / `.gitignore` from git if the harness modified them.
App code under `src/` and `prisma/` is untouched.

Those same paths are listed in `.gitignore`, so harness output from AI-DLC testing
never enters version control — only reset (or delete locally) is needed between runs.

Then re-run the AI-DLC prompt above.

## Expected end state

**After AI-DLC Phases 0–4 (current guide scope):**

- `CLAUDE.md` — router + routing table
- `AGENTS.md` — stack, commands, non-negotiables
- `.claude/settings.json` — hooks + permissions (optional `hooks/*.sh`)
- `docs/context/*.md` — domain context docs + index

**After full harness (guide extensions + manual steps):**

Compare against the annotated map in [01-barebones/LEARN.md](../01-barebones/LEARN.md):

- `.github/instructions/*.instructions.md` + `prompts/`
- `.vscode/` — Copilot MCP + settings
- `.claude/skills/`, `commands/`, `agents/`
- `.mcp.json`

## Architecture (for context-doc discovery)

Layered dependency: UI → services → repositories → Prisma.

| Area | Paths |
|------|-------|
| Frontend | `src/components/`, `src/app/page.tsx` |
| API | `src/app/api/tasks/route.ts` |
| Services | `src/services/` |
| Data | `prisma/`, `src/db/repos/` |

No auth layer — Phase 4 should infer ~4 domains (architecture, api, data, frontend).
