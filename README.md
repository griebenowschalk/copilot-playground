# Copilot Playground

A monorepo for experimenting with GitHub Copilot and Claude Code settings, configurations, and AI development harnesses.

## What's here

| Path | Purpose |
|------|---------|
| [`ai-harness-starter-kit/`](ai-harness-starter-kit/) | Three-level learning path for building a shared AI layer (rules, skills, MCP, hooks) that Copilot and Claude Code both read |
| [`HARNESS_SETUP_GUIDE.md`](HARNESS_SETUP_GUIDE.md) | Step-by-step guide for rolling out that harness in any repo — manual or AI-DLC mode |

The starter kit lives under `ai-harness-starter-kit/` in three folders. Each level is self-contained: open **that folder** as your workspace root (or copy its harness files to your repo root). Don't open the kit parent folder as the workspace — the tools won't find `.github/`, `.claude/`, etc.

## The three levels

### `01-barebones/` — learn the structure

**Start here if you've never seen an AI harness.**

The complete harness file tree — MCP, skills, commands, subagents, hooks, prompts, instructions, VS Code config — with **no application code**. Every file is trimmed to its essence with a one-line note explaining what it is, when it loads, and which tool reads it.

- Read [`01-barebones/LEARN.md`](ai-harness-starter-kit/01-barebones/LEARN.md) first — annotated map of the whole tree and demo talking points.
- Skim individual files; the top-line comment on each tells you its job.
- Use this to understand *what you're looking at* before touching a real app.

### `02-full-demo/` — see it working

**The reference implementation.**

The same harness as `01-barebones`, now governing a runnable Next.js + TypeScript + Prisma/SQLite app. Watch rules fire against real code, demo it to a team, or copy patterns into your own repo.

```bash
cd ai-harness-starter-kit/02-full-demo
pnpm install && pnpm setup && pnpm dev   # http://localhost:3000
```

Also includes a working `/figma` skill, seeded data, and an interactive [`harness-explorer.html`](ai-harness-starter-kit/02-full-demo/docs/harness-explorer.html) dashboard. See [`02-full-demo/README.md`](ai-harness-starter-kit/02-full-demo/README.md) and [`DEMO.md`](ai-harness-starter-kit/02-full-demo/DEMO.md).

### `03-dummy-project/` — test the setup guide

**A sandbox for practicing harness rollout.**

A harness-free mini tasks app (same stack as `02-full-demo`) used to repeatedly test [`HARNESS_SETUP_GUIDE.md`](HARNESS_SETUP_GUIDE.md) in AI-DLC mode. Open **this repo** as the workspace, run the scoped AI-DLC prompt from [`03-dummy-project/README.md`](ai-harness-starter-kit/03-dummy-project/README.md), then reset and try again:

```bash
cd ai-harness-starter-kit/03-dummy-project
./scripts/reset-harness.sh   # strips harness; restores bare app
```

Use this when you want to practice rolling out the harness from scratch without copying `01-barebones/` or `02-full-demo/` first.

## Suggested path

1. **`01-barebones/`** — read `LEARN.md`, skim the files (~5 min). You now know the structure.
2. **`02-full-demo/`** — run the app, open `harness-explorer.html`, walk through `DEMO.md`.
3. **`03-dummy-project/`** — follow `HARNESS_SETUP_GUIDE.md` via AI-DLC, reset, repeat until the flow is muscle memory.

More detail: [`ai-harness-starter-kit/README.md`](ai-harness-starter-kit/README.md).
