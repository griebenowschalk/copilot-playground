# Harness setup guide

All harness rollout documentation lives in this folder. Copy the whole **`guide/`** directory into a target repo (or reference it from copilot-playground) when running manual setup or AI-DLC.

| File | Purpose |
|------|---------|
| **`HARNESS_SETUP_GUIDE.md`** | **Start here** — hub, AI-DLC runbook, example prompt |
| `GRAPHIFY_GUIDE.md` | Graphify daily reference (optional) |
| `large-codebases.md` | Large repos / monorepos + pause-and-resume across sessions via the `guide/.harness-progress.md` ledger (optional, on demand) |
| `README.md` | This index |
| `00-how-files-relate.md` | AGENTS.md vs CLAUDE.md vs `.github/copilot-instructions.md` + Claude↔Copilot parity table |
| `step-0.5-graphify.md` | Optional Graphify harness integration |
| `step-1-claude.md` | Initialize `CLAUDE.md` + `.github/copilot-instructions.md` |
| `step-2-agents.md` | Set up `AGENTS.md` |
| `step-2.5-instructions.md` | Author scoped `.github/instructions/*.instructions.md` (shared by both tools) |
| `step-3-claude-folder.md` | `.claude/` hooks, permissions, subagents (§3.3) + Copilot chat modes |
| `agents/docs-explorer.md` | Copyable subagent template referenced from §3.3 — install in `.claude/agents/` |
| `chatmodes/docs-explorer.chatmode.md` | Copyable Copilot chat-mode template referenced from §3.3 — install in `.github/chatmodes/` |
| `skills/graphify/` | Copyable Graphify skill template (`SKILL.md` + `when-to-use.md`) referenced from Step 0.5 §0.5.3 and §6.4 — install in `.claude/skills/graphify/` |
| `step-4-context-docs.md` | `docs/context/` reference docs |
| `step-5-mcp.md` | MCP servers (`.mcp.json` + `.vscode/mcp.json`) |
| `step-6-skills.md` | Project skills (`.claude/skills/<name>/SKILL.md`) + Copilot prompts (`.github/prompts/`) |

## Step order

| Order | Phase | Step file | Creates / updates |
|-------|-------|-----------|-------------------|
| — | Background | `00-how-files-relate.md` | *(read first — no files)* |
| 0.5 *(optional)* | Graph | `step-0.5-graphify.md` | `.graphifyignore`, graph outputs, Graphify harness files |
| 1 | Init | `step-1-claude.md` | `CLAUDE.md` + `.github/copilot-instructions.md` |
| 2 | Baseline | `step-2-agents.md` | `AGENTS.md` |
| 2.5 | Instructions | `step-2.5-instructions.md` | `.github/instructions/*.instructions.md` (shared scoped rules) |
| 3 | Guardrails | `step-3-claude-folder.md` | `.claude/settings.json`, hook scripts, `.claude/agents/*.md` + `.github/chatmodes/*.chatmode.md` |
| 4 | Context | `step-4-context-docs.md` | `docs/context/*.md`, routing rows |
| 5 | MCP | `step-5-mcp.md` | `.mcp.json` + `.vscode/mcp.json`, `.env.example` (if Figma), `CLAUDE.md` MCP section |
| 6 | Skills | `step-6-skills.md` | `.claude/skills/<name>/SKILL.md` (staple + codebase-specific) + `.github/prompts/*.prompt.md` |

**AI-DLC:** load `HARNESS_SETUP_GUIDE.md` plus **only the current step file** for the active phase. On a **large repo or monorepo**, also read `large-codebases.md` — it covers per-package scoping and splitting the run across fresh context windows at phase gates.
