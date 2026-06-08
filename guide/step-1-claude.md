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

**Large repos — protect the context window.** `/init` (or an equivalent scan) on a big monorepo can consume the window before any harness work starts. Keep discovery bounded and out of the main context:

- **Delegate the scan to a subagent** (`Explore` / `general-purpose`) that returns only the distilled draft — raw file dumps never enter the facilitator's window.
- **Bound the scope:** exclude vendored, generated, and build dirs (`node_modules/`, `dist/`, `.next/`, `src/generated/`); start from the active subtree; sample representative files rather than reading exhaustively.
- This is the single biggest lever against hitting the context limit on a large codebase — Graphify (Path A) avoids it structurally by querying the graph instead of reading source.

---

## CLAUDE.md template (both paths)

At minimum include a routing table and pointers to harness paths. **Include Graphify rows only if Step 0.5 was completed:**

```markdown
# Claude Code — Memory & Rule Router

Read AGENTS.md first. Load detailed rules on demand via the routing table below.

## Rule Routing Table (READ ON DEMAND)
| If the task involves...          | Read this file                                |
|----------------------------------|-----------------------------------------------|
| Architecture, cross-layer flows, refactors, "who calls what" *(Graphify only)* | `.claude/skills/graphify/SKILL.md` or `/graphify` |
| React components / UI            | .github/instructions/frontend.instructions.md |
| Schema, migrations, repositories | .github/instructions/database.instructions.md |
| API route handlers               | .github/instructions/api.instructions.md      |
| Writing or modifying tests       | .github/instructions/testing.instructions.md  |
| Anything touching input/secrets  | .github/instructions/security.instructions.md |

## Where the rest lives
- Code graph *(Graphify only)*: `.claude/skills/graphify/` — query before multi-file reads; PreToolUse hook from `graphify claude install`
- Skills: `.claude/skills/<name>/SKILL.md`
- Legacy commands: `.claude/commands/*.md`
- Subagents: `.claude/agents/*.md`
- Hooks + permissions: `.claude/settings.json`
- MCP servers: `.mcp.json`
```

Adjust routing rows to match the instruction and context files you actually have.

> The routing rows above point at `.github/instructions/*.instructions.md` files that are
> **authored in Step 2.5** — a forward reference. Draft the rows now from the domains you
> expect; reconcile them against the files that actually exist at the Step 2.5 checkpoint.

**Keep `CLAUDE.md` a lean index, not content.** Like `AGENTS.md`, this file loads **every session** — and on a large codebase it grows one routing row per domain plus the MCP and Subagents sections, so the always-loaded set creeps up. Budget it:

- **≤100 lines.** If it's longer, the routing table is carrying content it should only be pointing at.
- The routing table is a **pointer index** — `If task → read this file`. Never inline the rules or context themselves; that's what the scoped instruction files, context docs, and skills are for (they load on demand).
- One row per file, not per topic. Collapse near-duplicate rows; if two domains always load together, give them one shared doc and one row.

---

## Copilot parity — `.github/copilot-instructions.md`

`CLAUDE.md` is Claude's always-on entry file. **GitHub Copilot's equivalent is
`.github/copilot-instructions.md`** — Copilot loads it on every request the same way
Claude loads `CLAUDE.md`. Author it from the **same discovery pass**, in the same phase,
so the two entry files never drift.

The key difference is how each finds scoped rules:

| | Claude (`CLAUDE.md`) | Copilot (`.github/copilot-instructions.md`) |
|--|----------------------|---------------------------------------------|
| Scoped rules | **Manual routing table** — Claude reads the matching file on demand | **`applyTo` auto-load** — Copilot loads the matching file automatically; no table needed |

So `copilot-instructions.md` carries **no routing table** — it just tells Copilot that
scoped rules live in `.github/instructions/` and load by glob, then restates the
always-on essentials.

```markdown
# Copilot Instructions

<one-line stack summary>. See `AGENTS.md` for commands and architecture.

## How rules are organized
Detailed, scoped rules live in `.github/instructions/*.instructions.md` and load
automatically based on the file you are editing (each file's `applyTo` glob).

## Always-on essentials
- <the same non-negotiables as AGENTS.md — a short reminder, not a copy>

Reusable workflows live in `.github/prompts/` (e.g. `/review`, `/figma`).
MCP servers are configured in `.vscode/mcp.json`.
```

- **Always-on essentials** mirror the `AGENTS.md` non-negotiables (Step 2) — a brief
  reminder for the model, not a second copy to maintain.
- The `.github/instructions/`, `.github/prompts/`, and `.vscode/mcp.json` pointers refer
  to files created in later steps (2.5, 6, 5) — fine to name now.
- Keep it short for the same reason as `CLAUDE.md`: it loads on every request.

---

> **AI-DLC checkpoint — Phase 1**
> Stop after drafting **both entry files** — `CLAUDE.md` and `.github/copilot-instructions.md`
> — from the one discovery pass. Review and approve before Step 2. This is the only full
> discovery pass — do not re-scan for AGENTS.md.

**Next:** `step-2-agents.md`
