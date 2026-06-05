# Harness Architecture

## Layers
1. **Baseline (always loaded):** `AGENTS.md` (shared), `CLAUDE.md`,
   `.github/copilot-instructions.md`. Keep these short — they cost tokens on
   every request.
2. **Scoped rules (conditional):** `.github/instructions/*.instructions.md`.
   One copy, two consumers:
   - Copilot includes a file when the edited file matches its `applyTo` glob.
   - Claude reads a file when its routing table maps the task to it.
3. **Manual workflows:** Copilot prompt files / Claude skills + commands.
4. **Tools:** MCP servers (`.mcp.json`, `.vscode/mcp.json`).
5. **Automation/guardrails:** Claude hooks + permissions in
   `.claude/settings.json`.

## Why split this way
- Copilot's instruction loading is **static** (file path only). It cannot decide
  what to load from the prompt's intent.
- Claude Code is an **agent**: it can Read any file mid-task, so a routing table
  in `CLAUDE.md` gives it intent-based loading equivalent to Cursor's
  agent-requested rules.
- Keeping rules in `.github/instructions/` means the same files serve both, so
  there is exactly one place to edit a convention.

## Auth & secrets
Secrets never live in commands or skills. They are resolved by the MCP layer:
`${FIGMA_API_KEY}` from env (Claude) or `${input:figma-key}` (Copilot). This is
what makes a tool like the `/figma` workflow portable.
