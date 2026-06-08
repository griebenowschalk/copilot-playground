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

Each Claude harness artifact has a Copilot counterpart (or an explicit "no equivalent"):

| Concern | Claude | Copilot |
|---------|--------|---------|
| Always-on entry | `CLAUDE.md` (manual routing table) | `.github/copilot-instructions.md` (`applyTo` auto-load) |
| Shared baseline | `AGENTS.md` | `AGENTS.md` *(same file)* |
| Scoped rules | files the routing table points at | `.github/instructions/*.instructions.md` *(same files — Step 2.5)* |
| Specialist agents | `.claude/agents/*.md` subagents | `.github/chatmodes/*.chatmode.md` chat modes |
| Reusable procedures | `.claude/skills/`, `.claude/commands/` | `.github/prompts/*.prompt.md` |
| External tools (MCP) | `.mcp.json` (`mcpServers`, `${VAR}`) | `.vscode/mcp.json` (`servers`, `${input:…}`) |
| Hooks / permissions | `.claude/settings.json` | *no equivalent — Copilot relies on instruction files* |

The scoped rule files are **one source of truth**: Copilot loads them automatically by
`applyTo` glob, Claude loads the same files on demand via its routing table.

**Creation order (setup):** optionally build the graph (`step-0.5-graphify.md`), then
create `CLAUDE.md` **and** `.github/copilot-instructions.md` from the same discovery
(Step 1), `AGENTS.md` next (Step 2), then the shared scoped instruction files (Step 2.5).

**Load order (runtime):**
- **Copilot:** `AGENTS.md` → `.github/copilot-instructions.md` → `applyTo` scoped rules (by edited file).
- **Claude:** `AGENTS.md` → `CLAUDE.md` → routed scoped rules (on demand).
