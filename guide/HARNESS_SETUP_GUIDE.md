# AI Harness Setup Guide

A step-by-step guide for setting up a shared AI layer for GitHub Copilot and Claude Code in any codebase.

**This file is the hub.** All harness setup docs live in **this folder** — one file per phase. See **`README.md`** for the full index.

---

## How to follow this guide

| Mode | Who drives | Best for |
|------|------------|----------|
| **Manual** | You read each step file and create/edit files yourself | Learning the harness, small tweaks, full control |
| **AI-DLC** | An AI facilitator runs the phases; you answer policy questions and approve drafts | Rolling out the harness with a senior or team lead in the loop |

**Manual:** read `00-how-files-relate.md`, then `step-1-claude.md` through `step-5-mcp.md`. Optionally run `step-0.5-graphify.md` first.

**AI-DLC:** open this hub plus the **current phase step file** in your agent. Pause at every **AI-DLC checkpoint** in that step file.

**Example prompt:**

```
Implement the AI harness in this repo using HARNESS_SETUP_GUIDE.md (hub) and
the other files in the same folder. Load the hub for AI-DLC rules; load only the
step file for the current phase (see README.md).

Work one phase at a time. Pause at every AI-DLC checkpoint — ask me policy
questions (non-negotiables evidenced in discovery, hooks, context doc domains) or
offer to infer from the codebase and show a draft for approval. Do not skip phases
or implement steps not yet documented.

Start with Phase 0 kickoff. At Phase 0.5, ask whether to enable Graphify — if yes,
follow step-0.5-graphify.md; only skip if install fails or I decline.
Stop at step-6-skills.md. Do not write AGENTS.md until CLAUDE.md is approved.
```

---

## AI-DLC: Implement this harness

When a senior or team lead uses AI-DLC mode, work **phase by phase** — the human provides policy, the AI structures the work, shows drafts, and writes only after approval.

**Scope:** implement only steps documented in this folder. Stop at Step 6 until new step files are added.

### Roles

| Role | Responsibility |
|------|----------------|
| **Human** (senior / team lead) | Answers policy questions, approves drafts |
| **AI** | Runs `/init` or equivalent once, asks checkpoint prompts, infers when human defers, writes after approval |

### Operating rules

1. **One phase at a time** — map 1:1 to `step-*.md` files in this folder.
2. **Load the current step only** — this hub for rules; step file for instructions and checkpoint.
3. **Single discovery** — one full repo scan, then reuse that output. **With Graphify:** Phase 0.5; Phases 1–4 use graph output. **Without Graphify:** Phase 1 (`/init`); later phases reuse `CLAUDE.md` and init output.
4. **Phase gate** — show draft → get approval → write → summarize → proceed.
5. **Ask on policy**; **infer on facts** already captured in Phase 1.
6. **Escape hatch** at every policy checkpoint: *"Specify now, or I'll infer and show a draft to approve."*
7. **Never copy guide examples verbatim** unless they match this project — including non-negotiables: use the stack, tools, and patterns Phase 1 actually found.
8. **Stop** at the last documented step — do not implement scoped instructions or Copilot skill parity until a new `step-*.md` exists in this folder.
9. **Graphify is optional and non-blocking** — see `step-0.5-graphify.md`. Never halt the harness waiting on Graphify.

### Phase flow

| Phase | Step file | Discovery? | Policy checkpoint? |
|-------|-----------|------------|-------------------|
| 0 — Kickoff | *(this hub)* | No | Confirm repo root only |
| 0.5 — Graph *(optional)* | `step-0.5-graphify.md` | **Yes — if opted in** | **Ask: enable Graphify?** |
| 1 — Init | `step-1-claude.md` | Reuse Phase 0.5 or `/init` | Light — routing rows |
| 2 — Baseline | `step-2-agents.md` | Reuse Phase 1 | **Yes — non-negotiables** |
| 3 — Guardrails | `step-3-claude-folder.md` | Reuse Phase 1 | **Yes — hooks, permissions & subagents** |
| 4 — Context docs | `step-4-context-docs.md` | Targeted reads only | **Yes — which domains** |
| 5 — MCP | `step-5-mcp.md` | No | **Yes — Figma for frontend?** |
| 6 — Skills | `step-6-skills.md` | Reuse Phase 1 | **Yes — staple + codebase-specific list** |

**Phase 0 — Kickoff:** Confirm workspace root. Open with: *"At Phase 0.5 I'll ask whether you want Graphify. Either way, we do one discovery pass — graph or `/init` — then reuse it for the rest."*

**Phase 0.5:** Follow `step-0.5-graphify.md`. If declined or install fails, skip to Phase 1.

**Phase 1:** Follow `step-1-claude.md`. Gate: approve `CLAUDE.md` before Step 2.

**Phase 2:** Follow `step-2-agents.md`. Propose only non-negotiables evidenced in discovery. Gate: approve `AGENTS.md` before Step 3.

**Phase 3:** Follow `step-3-claude-folder.md`. Merge Graphify PreToolUse if Step 0.5 ran (§3.2). Set up subagents (§3.3) — default to `docs-explorer` (template at `agents/docs-explorer.md`) if the human names nothing else.

**Phase 4:** Follow `step-4-context-docs.md`. Gate: approve doc list + sample; update `CLAUDE.md` routing.

**Phase 5:** Follow `step-5-mcp.md`. Gate: approve `.mcp.json` + optional Figma; verify with `/mcp`.

**Phase 6:** Follow `step-6-skills.md`. Propose staple skills (security, primary-language conventions, testing) plus codebase-specific skills inferred from Phase 1 discovery. Gate: approve the skill list and sample `SKILL.md` drafts before writing.

### Checkpoint quick-reference

| Checkpoint | Step file | Ask human | Infer if deferred |
|------------|-----------|-----------|-------------------|
| Graphify | `step-0.5-graphify.md` | Enable Graphify? yes/no | Skip if declined |
| `CLAUDE.md` | `step-1-claude.md` | Routing rows | Agent-generate from discovery |
| Non-negotiables | `step-2-agents.md` | 3–6 universal rules | Propose from conventions; skip inapplicable categories |
| Hooks | `step-3-claude-folder.md` | PostToolUse / Stop / denies | Minimal lint + default denies |
| Subagents | `step-3-claude-folder.md` §3.3 | Which subagents to add | Install `docs-explorer` only |
| Context docs | `step-4-context-docs.md` | Which domains | Doc list from tree or graph |
| MCP | `step-5-mcp.md` | Figma for frontend? yes/no | Baseline only (filesystem, memory, git, context7) |
| Skills | `step-6-skills.md` | Which staple + codebase-specific skills | Staples (§6.2) + one skill per major framework/runtime found |

### Extension pattern

When adding a new harness step:

1. Create `step-N-<name>.md` in this folder with content + **AI-DLC checkpoint** blockquote.
2. Add a row to **`README.md`** index and the phase table above.
3. Add a **Phase N** summary line under Phase flow.

Step file template:

```markdown
# Step N: <Title>
**Phase N · AI-DLC checkpoint at …**
…content…
> **AI-DLC checkpoint — Phase N**
> …
**Next:** `step-N+1-….md`
```

---

## File index

| File | Purpose |
|------|---------|
| `README.md` | Index and navigation |
| `HARNESS_SETUP_GUIDE.md` | This hub — AI-DLC runbook, example prompt |
| `GRAPHIFY_GUIDE.md` | Graphify daily reference (optional layer) |
| `00-how-files-relate.md` | AGENTS.md vs CLAUDE.md — creation vs load order |
| `step-0.5-graphify.md` | Optional codebase graph (harness integration) |
| `step-1-claude.md` | Initialize `CLAUDE.md` |
| `step-2-agents.md` | Set up `AGENTS.md` |
| `step-3-claude-folder.md` | `.claude/` hooks, permissions, and subagents (§3.3) |
| `agents/docs-explorer.md` | Copyable subagent template referenced from §3.3 |
| `step-4-context-docs.md` | `docs/context/` reference docs |
| `step-5-mcp.md` | MCP servers (`.mcp.json`) |
| `step-6-skills.md` | Project skills (`.claude/skills/<name>/SKILL.md`) |

More steps will be added as new files in this folder using the extension pattern above.
