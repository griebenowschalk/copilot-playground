# AI Harness Starter Kit — Copilot + Claude Code

A three-level learning path for setting up a repo so **GitHub Copilot** and
**Claude Code** share one set of rules, commands, skills, and MCP — the Cursor
pattern, rebuilt portably.

```
01-barebones/     ← the COMPLETE harness structure, no app. Learn what each piece is.
02-full-demo/     ← the same harness on a runnable app, plus an interactive dashboard.
03-dummy-project/ ← harness-free app for testing HARNESS_SETUP_GUIDE.md AI-DLC.
```

## Level 1 — `01-barebones/`
Every harness file the demo has (MCP, skills, commands, subagents, hooks,
prompts, instructions, VS Code config) — but **no application code**, and each
file trimmed to its essence with a one-line note saying what it is, when it
loads, and which tool reads it.

Start with **`01-barebones/LEARN.md`**: it's an annotated map of the whole tree
plus the talking points for a demo. This is the "understand what I'm looking at"
layer — no noise.

## Level 2 — `02-full-demo/`
The identical harness, now governing a real, runnable codebase
(Next.js + TypeScript + Prisma/SQLite + Tailwind + Vitest), so you can watch the
rules actually fire:
```bash
cd 02-full-demo
pnpm install && pnpm setup && pnpm dev    # http://localhost:3000
```
Includes the working `/figma` skill (with its script), seeded data, and an
interactive demo dashboard at `02-full-demo/docs/harness-explorer.html`
(open in a browser, no setup). See its `README.md` and `DEMO.md`.

## Level 3 — `03-dummy-project/`
A **harness-free** mini tasks app (same stack as `02-full-demo`) for repeatedly
testing [HARNESS_SETUP_GUIDE.md](../HARNESS_SETUP_GUIDE.md) in AI-DLC mode. Open
**copilot-playground** as workspace, run the scoped AI-DLC prompt from
`03-dummy-project/README.md`, then reset with:

```bash
cd 03-dummy-project
./scripts/reset-harness.sh   # strips full LEARN.md harness tree; restores bare app
```

Use this when you want to practice rolling out the harness from scratch without
copying `01-barebones/` or `02-full-demo/` first.

## Suggested path
1. Read `01-barebones/LEARN.md` end to end (5 min) — you now know the structure.
2. Skim each file in `01-barebones/`; the top-line note tells you its job.
3. Move to `02-full-demo/`, run it, and use `harness-explorer.html` + `DEMO.md`
   to demo it to your team lead.
4. Use `03-dummy-project/` to test the setup guide's AI-DLC flow, reset, repeat.

## How to use a level
Each level is self-contained. Either **open that one folder as your VS Code /
Claude Code workspace root**, or **copy its contents into your repo's root**
(`.github/`, `.claude/`, `.vscode/`, `AGENTS.md`, `CLAUDE.md`, `.mcp.json` must
sit at the repo root for the tools to find them). Work inside one level at a
time — don't open the kit's parent folder as the workspace.

## The whole idea in one sentence
Put scoped rules in `.github/instructions/*.instructions.md` once; Copilot reads
them by `applyTo` glob, Claude reads them on demand via the `CLAUDE.md` routing
table — single source of truth, plus Cursor-style intent-based loading that
Copilot can't do alone.

## Graphify — optional code discovery layer
Graphify is **optional** at harness setup (Phase 0.5 asks yes/no; requires Python
3.10+ — skip if unavailable). When enabled, both tools share one codebase graph (`graphify-out/`): Claude uses `/graphify query`
and a PreToolUse hook; Copilot uses the `/graphify` prompt. The `01-barebones/` and
`02-full-demo/` templates include Graphify files for reference; skip them if you
decline at Phase 0.5. Daily usage: [GRAPHIFY_GUIDE.md](../GRAPHIFY_GUIDE.md).
