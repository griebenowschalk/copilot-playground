# AI Harness Demo — Copilot + Claude Code

A small, runnable Next.js app whose coding conventions are enforced by a shared
AI harness. It's a working reference for setting up a repo so **GitHub Copilot**
and **Claude Code** behave consistently — mirroring (and extending) what Cursor
offers with rules, commands, skills, and MCP.

## The big idea
`.github/instructions/*.instructions.md` is the **single source of truth** for
scoped rules.
- **Copilot** auto-loads each file by its `applyTo` glob (Cursor "auto-attached").
- **Claude Code** loads them on demand via the routing table in `CLAUDE.md`
  (Cursor "agent-requested" — the part Copilot can't do natively).

No rule is duplicated. Edit a rule once; both tools pick it up.

## Quickstart
```bash
pnpm install
pnpm setup     # copies .env, pushes the SQLite schema, seeds tasks
pnpm dev       # http://localhost:3000
pnpm test      # run the test suite
```

## Walk a team lead through it
Open **`docs/harness-explorer.html`** in any browser (no setup) for an
interactive tour, then follow **`DEMO.md`** for hands-on prompts to run live in
Copilot and Claude Code.

## What's in the harness
| Path | Tool | Role | Cursor equivalent |
|---|---|---|---|
| `AGENTS.md` | both | shared baseline | always-apply |
| `CLAUDE.md` | Claude | memory + on-demand rule router | always-apply + agent-requested |
| `.github/copilot-instructions.md` | Copilot | baseline | always-apply |
| `.github/instructions/*.instructions.md` | both | scoped rules (glob/router) | auto-attached |
| `.github/prompts/*.prompt.md` | Copilot | manual commands | manual `@rule` |
| `.claude/skills/*/SKILL.md` | Claude | skills (can bundle scripts) | skills |
| `.claude/commands/*.md` | Claude | legacy commands (still work) | manual `@rule` |
| `.claude/agents/*.md` | Claude | subagents | subagents |
| `.claude/settings.json` | Claude | hooks + permissions | hooks |
| `.mcp.json` / `.vscode/mcp.json` | Claude / Copilot | MCP servers (GitHub, Figma) | MCP |

## The app (so the rules have real code to govern)
A tasks app exercising every rule area:
- `src/components/TaskList.tsx` — client component → frontend rules
- `src/app/api/tasks/route.ts` — route handler → api + security rules
- `src/db/repos/tasks.ts` — repository layer → database rules
- `src/lib/validation.ts` — Zod schemas → security rules
- `src/components/TaskList.test.tsx` — Vitest → testing rules

## Maintenance rule
When you add a rule area, do two things: add
`.github/instructions/<area>.instructions.md` with an `applyTo`, and add one row
to the routing table in `CLAUDE.md`. That keeps both tools in sync from one edit.
