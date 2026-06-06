# AI Harness Setup Guide

A step-by-step guide for setting up a shared AI layer for GitHub Copilot and Claude Code in any codebase.

> **Reference examples:** See [`ai-harness-starter-kit/01-barebones/`](ai-harness-starter-kit/01-barebones/) for a minimal harness with every file trimmed to its essence. Start with [`LEARN.md`](ai-harness-starter-kit/01-barebones/LEARN.md) for an annotated walkthrough of the full structure.

---

## How the two files relate

| File | Who reads it | When |
|------|-------------|------|
| `AGENTS.md` | All AI tools (Copilot, Claude, any agent) | Every request — keep it short |
| `CLAUDE.md` | Claude Code only | Every session — Claude-specific memory & rule routing |

`AGENTS.md` is the shared baseline: stack, commands, architecture, and hard rules every tool needs on every request. `CLAUDE.md` builds on top of it with Claude-specific behavior — primarily a routing table that tells Claude which scoped rule file to read on demand based on the task.

---

## Step 1: Set up AGENTS.md

Create `AGENTS.md` at your repo root. This file is read by every AI tool on every request, so keep it short.

At minimum it should contain:

```markdown
# Project: <Your App Name>

## Stack
- (e.g. Next.js + TypeScript + Postgres + Tailwind + Vitest)

## Commands
- `npm run dev` · `npm test` · `npm run lint`

## Non-negotiables
- Named exports only. No default exports (except framework-required files).
- All external input validated with Zod before use.
- Server Components by default; "use client" only when interactive.
- Soft-delete with `deletedAt`; never hard-delete records.
- Mirror the linter — never generate code that fails `npm run lint`.
```

### What belongs in Non-negotiables

These are rules that apply **everywhere**, regardless of what file or feature is being worked on. A good test: if breaking the rule in any file would be wrong, it belongs here. Examples:

- Export style (`named exports only`)
- Input validation approach (`validate all external input with Zod`)
- Delete strategy (`soft-delete only`)
- A linter/formatter constraint the AI keeps violating (`always run lint before declaring done`)
- A security invariant (`never log sensitive fields`)

Aim for 3–6 rules. If you're writing more than that, ask whether the rule only applies in specific contexts — those belong in a scoped instructions file instead.

### Where to stop

`AGENTS.md` loads on **every** request. Every line here costs tokens on every interaction, so treat it like a header file — only what's truly universal. Move anything more specific to `.github/instructions/*.instructions.md`:

| Belongs in `AGENTS.md` | Move to a scoped instructions file |
|------------------------|-------------------------------------|
| Stack & run commands | How to structure a React component |
| Universal hard rules | Database query patterns |
| Repo-wide constraints | API route conventions |
| | Test setup and patterns |
| | Security rules for specific layers |

A good signal that something has drifted too far: if a rule only matters when touching a specific folder, feature type, or file pattern — it belongs in a scoped file with a matching `applyTo` glob, not here.

---

## Step 2: Initialize CLAUDE.md

With `AGENTS.md` in place, run the `/init` command in Claude Code to generate a `CLAUDE.md` tailored to your project:

```
/init
```

This will:
- Scan your codebase structure and existing conventions
- Create a `CLAUDE.md` at your repo root
- Set up a rule routing table so Claude reads scoped instruction files on demand (the same `.github/instructions/*.instructions.md` files Copilot loads via `applyTo` globs)
- Reference any skills, commands, subagents, hooks, and MCP servers you have configured

Review and customize the generated file — in particular, update the routing table to match the instruction files you actually have.

---

_More steps coming as the harness is built out._
