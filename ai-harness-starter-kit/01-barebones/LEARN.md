# The harness, annotated — read this while demoing

This folder has the COMPLETE harness structure (every piece the full demo has)
but no application code. Each config file is trimmed to its essence with a
one-line `<!-- ... -->` note at the top saying what it is, when it loads, and
which tool reads it. Use this file as the map.

## The one concept everything serves
Scoped rules live ONCE in `.github/instructions/*.instructions.md`.
- **Copilot** auto-loads a rule file when the file you're editing matches its
  `applyTo` glob.  → loads by FILE PATH.
- **Claude Code** loads the same file on demand via the routing table in
  `CLAUDE.md`.  → loads by TASK INTENT.
That's the whole trick: one source of truth, two loading mechanisms. Claude's
intent-based loading is the thing Copilot can't do alone.

## Annotated file map
```
AGENTS.md                         shared baseline — BOTH tools, every request. Keep short.
CLAUDE.md                         Claude memory + the on-demand ROUTING TABLE.
.mcp.json                         Claude's MCP servers (GitHub, Figma). Key from env.
.env.example                      template for secrets (FIGMA_API_KEY). Copy to .env.

.github/
  copilot-instructions.md         Copilot baseline — every request. Keep short.
  instructions/                   ⭐ THE SOURCE OF TRUTH (scoped rules)
    security.instructions.md        applyTo "**"  → loads everywhere
    frontend.instructions.md        applyTo src/components/** → UI work
    database.instructions.md        applyTo prisma/**, src/db/**
    api.instructions.md             applyTo src/app/api/**
    testing.instructions.md         applyTo **/*.test.*
  prompts/                        Copilot manual commands (type /name in chat)
    review.prompt.md                /review
    scaffold-component.prompt.md    /scaffold-component
    figma.prompt.md                 /figma  (uses Figma MCP)

.vscode/
  mcp.json                        Copilot's MCP servers. NOTE: key is "servers"
                                  (not "mcpServers"); secret via ${input:figma-key}.
  settings.json                   turns on instruction + prompt files, AGENTS.md.
  extensions.json                 recommends the Copilot extensions.

.claude/
  settings.json                   hooks (lint after edits) + permissions (deny .env, rm -rf)
  settings.local.json             personal overrides (gitignored)
  commands/ship.md                legacy command (still works) — /ship
  skills/                         skills = richer commands (can bundle scripts)
    figma/SKILL.md                  /figma
    figma/scripts/fetch-context.sh  ← script the skill runs; reads FIGMA_API_KEY
    review/SKILL.md                 /review  (mirrors the Copilot prompt)
    scaffold-component/SKILL.md     /scaffold-component
  agents/                         subagents — own prompt + restricted tools
    code-reviewer.md                read-only reviewer
    test-runner.md                  can run bash to fix tests
```

## How to read the table when demoing
- "Both tools" files (green idea): `AGENTS.md`, the `instructions/*` files.
- "Claude only": `CLAUDE.md`, everything under `.claude/`, `.mcp.json`.
- "Copilot only": `.github/copilot-instructions.md`, `.github/prompts/*`, `.vscode/*`.

## The four loading modes (Cursor parity)
| Mode | Claude | Copilot |
|---|---|---|
| Always-on | AGENTS.md + CLAUDE.md | copilot-instructions.md + AGENTS.md |
| By file path (glob) | router can use it | instructions/* applyTo |
| By task intent | CLAUDE.md routing table | — (Copilot can't) |
| Manual command | skills/ + commands/ | prompts/ |

## Secrets: where API keys live
NOT in commands/skills. In the MCP layer: `${FIGMA_API_KEY}` from env (Claude)
or `${input:figma-key}` (Copilot). That's why the Figma workflow is portable —
the same `/figma` works in both because auth isn't baked into the command.

## The maintenance rule (say this to your team lead)
To add a rule area: add `.github/instructions/<area>.instructions.md` with an
`applyTo`, and add one row to the `CLAUDE.md` routing table. One edit → both
tools updated. No duplication, ever.

## Next: ../02-full-demo
Same structure, plus a runnable app the rules govern and an interactive
dashboard (`docs/harness-explorer.html`) that visualizes all of the above live.
