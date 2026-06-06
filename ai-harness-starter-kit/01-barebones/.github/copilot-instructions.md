<!-- WHAT: Copilot's always-on baseline. WHO: GitHub Copilot. WHEN: every request. -->
# Copilot Instructions

(your stack). See AGENTS.md for commands. Detailed rules live in
`.github/instructions/*.instructions.md` and load automatically by each file's
`applyTo` glob. Manual workflows are in `.github/prompts/` (incl. `/graphify`).
MCP servers (incl. Figma) are in `.vscode/mcp.json`.

## Always-on essentials
- Named exports only. Validate all input. Mirror the linter.
- Architecture questions: use `/graphify` or read `graphify-out/GRAPH_REPORT.md`
  before grepping multiple files.
