<!-- WHAT: Claude's memory + the on-demand rule router. WHO: Claude Code. WHEN: every session. -->
# Claude Code — Memory & Rule Router

Read AGENTS.md first. The routing table is the key idea: rather than load every
rule, Claude READS the matching rule file on demand based on the task. These are
the SAME files Copilot loads via `applyTo` globs — one source of truth.

## Rule Routing Table (READ ON DEMAND)
| If the task involves...          | Read this file                                |
|----------------------------------|-----------------------------------------------|
| Architecture, codebase structure | graphify-out/GRAPH_REPORT.md or `/graphify query` |
| React components / UI            | .github/instructions/frontend.instructions.md |
| Schema, migrations, repositories | .github/instructions/database.instructions.md |
| API route handlers               | .github/instructions/api.instructions.md      |
| Writing or modifying tests       | .github/instructions/testing.instructions.md  |
| Anything touching input/secrets  | .github/instructions/security.instructions.md |

Security applies to everything; read every file a task touches.

## Where the rest lives
- Code graph: `graphify-out/GRAPH_REPORT.md` — build with `/graphify .` or `graphify extract .`
- Skills: `.claude/skills/<name>/SKILL.md`  (e.g. /graphify, /figma, /review)
- Legacy commands: `.claude/commands/*.md`  (e.g. /ship)
- Subagents: `.claude/agents/*.md`
- Hooks + permissions: `.claude/settings.json`
- MCP servers: `.mcp.json`
