# Step 1: Initialize CLAUDE.md

**Phase 1 · AI-DLC checkpoint at end of this file**

---

## Path A — Graphify enabled (Step 0.5 completed)

Use the **graph as your discovery source**. Read `graphify-out/GRAPH_REPORT.md` and run targeted queries:

```bash
graphify query "layer dependencies"
graphify query "entry points and architecture"
graphify query "API to database flow"
```

Draft `CLAUDE.md` from graph communities + any existing instruction files. Do **not** Glob/Grep/Read source files unless a query returns insufficient detail. Include the Graphify routing row (see template below).

## Path B — Graphify skipped (classic discovery)

Run `/init` **once**. It scans your codebase and generates `CLAUDE.md` — stack, structure, conventions, routing table, and references to existing harness files. This discovery pass feeds everything that follows; don't scan the repo again for Step 2.

In Claude Code:

```
/init
```

If you're not in Claude Code, perform an equivalent single scan and generate `CLAUDE.md` at the repo root. Omit Graphify rows from the routing table.

---

## CLAUDE.md template (both paths)

At minimum include a routing table and pointers to harness paths. **Include Graphify rows only if Step 0.5 was completed:**

```markdown
# Claude Code — Memory & Rule Router

Read AGENTS.md first. Load detailed rules on demand via the routing table below.

## Rule Routing Table (READ ON DEMAND)
| If the task involves...          | Read this file                                |
|----------------------------------|-----------------------------------------------|
| Architecture, codebase structure *(Graphify only)* | graphify-out/GRAPH_REPORT.md or `/graphify query` |
| React components / UI            | .github/instructions/frontend.instructions.md |
| Schema, migrations, repositories | .github/instructions/database.instructions.md |
| API route handlers               | .github/instructions/api.instructions.md      |
| Writing or modifying tests       | .github/instructions/testing.instructions.md  |
| Anything touching input/secrets  | .github/instructions/security.instructions.md |

## Where the rest lives
- Code graph *(Graphify only)*: `graphify-out/GRAPH_REPORT.md`
- Skills: `.claude/skills/<name>/SKILL.md`
- Legacy commands: `.claude/commands/*.md`
- Subagents: `.claude/agents/*.md`
- Hooks + permissions: `.claude/settings.json`
- MCP servers: `.mcp.json`
```

Adjust routing rows to match the instruction and context files you actually have.

---

> **AI-DLC checkpoint — Phase 1**
> Stop after drafting `CLAUDE.md`. Review and approve before Step 2. This is the only full discovery pass — do not re-scan for AGENTS.md.

**Next:** `step-2-agents.md`
