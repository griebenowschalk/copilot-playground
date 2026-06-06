# Claude Code — Project Memory & Rule Router

Read `AGENTS.md` first for stack, commands, and architecture. This file adds
Claude-specific behavior and a ROUTING TABLE so you load detailed rules ON
DEMAND — the same way Cursor's "agent-requested" rules work. Do NOT load every
rule up front; read only what the current task needs.

## Rule Routing Table (READ ON DEMAND)
Before writing or editing code, decide what the task touches, then Read the
matching file(s). These are the SAME files Copilot loads via `applyTo` globs —
one source of truth.

| If the task involves...                        | Read this file                                  |
|------------------------------------------------|-------------------------------------------------|
| Architecture, codebase structure, onboarding   | graphify-out/GRAPH_REPORT.md or `/graphify query` |
| React components, UI, client interactivity     | .github/instructions/frontend.instructions.md   |
| Prisma schema, migrations, repositories        | .github/instructions/database.instructions.md   |
| API route handlers under src/app/api           | .github/instructions/api.instructions.md        |
| Writing or modifying tests                     | .github/instructions/testing.instructions.md    |
| ANY change touching auth, input, or secrets    | .github/instructions/security.instructions.md   |

Rules of thumb: read every relevant file when a task spans areas; security
applies to everything; after reading a rule file, follow it as if it were here.

## Skills & commands
- Code graph: build with `/graphify .` or `graphify extract .`; query before grepping source.
- Skills live in `.claude/skills/<name>/SKILL.md` and can bundle scripts.
  Available: `/graphify`, `/figma`, `/review`, `/scaffold-component`.
- Legacy commands in `.claude/commands/` still work (e.g. `/ship`).

## Subagents (`.claude/agents/`)
- `code-reviewer` — read-only quality/security pass.
- `test-runner` — runs the suite and triages failures.

## MCP (`.mcp.json`)
- `github` — issues/PRs. Given an issue number, read it first.
- `figma`  — design context for the `/figma` skill (key from FIGMA_API_KEY env).

## Workflow
1. Restate the task; identify which rule files apply.
2. Read them, implement (prefer editing existing files).
3. Run `pnpm lint` and `pnpm test` before declaring done.
