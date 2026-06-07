# 03-dummy-project — AI-DLC harness test fixture

A **harness-free** mini tasks app for repeatedly testing
[`guide/HARNESS_SETUP_GUIDE.md`](../../guide/HARNESS_SETUP_GUIDE.md) in AI-DLC mode. Same stack as
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

1. Open **copilot-playground** as your workspace (the guide lives in **`guide/`** at repo root).
2. Paste this prompt (note the scoped path — harness files go under `03-dummy-project/`,
   not the monorepo root):

```
Implement the AI harness in ai-harness-starter-kit/03-dummy-project/
using guide/HARNESS_SETUP_GUIDE.md (hub) and the other files in guide/. All harness files must
live under 03-dummy-project/, not the monorepo root.

Load the hub for AI-DLC rules; load only the step file for the current phase
(see guide/README.md). Work one phase at a time. Pause at every AI-DLC checkpoint.
Start with Phase 0 kickoff. At Phase 0.5, ask whether to enable Graphify — if yes,
follow guide/step-0.5-graphify.md; only skip if install fails or I decline.
Do not write AGENTS.md until CLAUDE.md is approved. Stop at guide/step-4-context-docs.md.
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

**If Graphify was enabled at Phase 0.5**, also expect:

- `.graphifyignore` + `graphify-out/` — codebase graph (output gitignored)
- `.claude/skills/graphify/SKILL.md` — Claude `/graphify` skill
- `.github/prompts/graphify.prompt.md` — Copilot `/graphify` prompt
- Graphify section in `AGENTS.md` + architecture row in `CLAUDE.md`
- PreToolUse hook from Graphify merged into `.claude/settings.json`

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
