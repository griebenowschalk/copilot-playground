# How the files relate

Three files anchor the harness — one shared, one per tool:

| File | Who reads it | When |
|------|-------------|------|
| `AGENTS.md` | All AI tools (Copilot, Claude, any agent) | Every request — keep it short |
| `CLAUDE.md` | Claude Code only | Every session — Claude-specific memory & rule routing |
| `.github/copilot-instructions.md` | GitHub Copilot only | Every request — Copilot entry; points at `applyTo` scoped rules |

`AGENTS.md` is the shared baseline: stack, commands, architecture, and hard rules every
tool needs on every request. Each tool then layers its own entry file on top — same
intent, different mechanism for loading scoped rules.

## Claude ↔ Copilot parity

Each Claude harness artifact now has a Copilot counterpart — some shared (same file), some
mirrored (parallel file), one reused (VS Code Copilot reads Claude's hooks directly):

| Concern | Claude | Copilot |
|---------|--------|---------|
| Always-on entry | `CLAUDE.md` (manual routing table) | `.github/copilot-instructions.md` (`applyTo` auto-load) |
| Shared baseline | `AGENTS.md` | `AGENTS.md` *(same file)* |
| Scoped rules | files the routing table points at | `.github/instructions/*.instructions.md` *(same files — Step 2.5)* |
| Specialist agents | `.claude/agents/*.md` subagents | `.github/chatmodes/*.chatmode.md` chat modes |
| Reusable procedures | `.claude/skills/<name>/SKILL.md` | *(same files — Copilot Chat in VS Code reads `.claude/skills/` directly, no `.github/prompts/` duplicates)* |
| External tools (MCP) | `.mcp.json` (`mcpServers`, `${VAR}`) | `.vscode/mcp.json` (`servers`, `${input:…}`) |
| Hooks | `.claude/settings.json` (`hooks`) | reads the **same** `.claude/settings.json` hooks *(VS Code Preview; matchers ignored, runs on all tool calls)* — or `.github/hooks/*.json` |
| Permissions | `.claude/settings.json` (`deny`, committed) + `.claude/settings.local.json` (`allow`, gitignored) | `.vscode/settings.json` (`chat.tools.terminal.autoApprove`, `chat.tools.edits.autoApprove`, `chat.agent.networkFilter`) |

The scoped rule files are **one source of truth**: Copilot loads them automatically by
`applyTo` glob, Claude loads the same files on demand via its routing table. **Hooks are
shared too** — VS Code Copilot parses the `.claude/settings.json` `hooks` block directly,
so a single hooks definition serves both tools (see `step-3-claude-folder.md`). Only the
**permissions** mechanism differs: Claude uses the `permissions` block; Copilot uses
VS Code's `chat.tools.*` auto-approve settings in `.vscode/settings.json`.

**Creation order (setup):** optionally build the graph (`step-0.5-graphify.md`), then
create `CLAUDE.md` **and** `.github/copilot-instructions.md` from the same discovery
(Step 1), `AGENTS.md` next (Step 2), then the shared scoped instruction files (Step 2.5).

**Load order (runtime):**
- **Copilot:** `AGENTS.md` → `.github/copilot-instructions.md` → `applyTo` scoped rules (by edited file).
- **Claude:** `AGENTS.md` → `CLAUDE.md` → routed scoped rules (on demand).

## Workspace hygiene: `.copilotignore` for `guide/`

This `guide/` folder contains copyable skill templates (`skills/graphify/`,
`skills/figma-to-code/`, …) with the **same `name:`** as the installed copies under
`.claude/skills/`. Copilot Chat in VS Code scans the whole workspace for `SKILL.md` files,
so without exclusion it shows **two** entries for `/graphify` (and `/figma-to-code`) — the
real skill and the guide template. At Phase 0/1, create a `.copilotignore` at the repo root
containing `guide/` so only the installed `.claude/skills/` copies are discoverable. This
does not affect Claude, which only reads `.claude/skills/`.
