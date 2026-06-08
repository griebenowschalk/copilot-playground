# AI Harness Setup Guide

A step-by-step guide for setting up a shared AI layer for GitHub Copilot and Claude Code in any codebase.

**This file is the hub.** All harness setup docs live in **this folder** — one file per phase. See **`README.md`** for the full index.

---

## How to follow this guide

| Mode | Who drives | Best for |
|------|------------|----------|
| **Manual** | You read each step file and create/edit files yourself | Learning the harness, small tweaks, full control |
| **AI-DLC** | An AI facilitator runs the phases; you answer policy questions and approve drafts | Rolling out the harness with a senior or team lead in the loop |

**Manual:** read `00-how-files-relate.md`, then `step-1-claude.md` through `step-6-skills.md` (including `step-2.5-instructions.md`). Optionally run `step-0.5-graphify.md` first. Each step produces both the Claude artifact and its GitHub Copilot counterpart (entry file, scoped instructions, chat modes, `.vscode/mcp.json`, prompts) — see the parity table in `00-how-files-relate.md`.

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
3. **Single discovery** — one repo scan, then reuse that output. **With Graphify:** Phase 0.5; Phases 1–4 use graph output. **Without Graphify:** Phase 1 (`/init`); later phases reuse `CLAUDE.md` and init output.
4. **Phase gate** — show draft → get approval → write → tick the phase in `guide/.harness-progress.md` (one checkbox + the `Next:` line — a few tokens) → summarize → proceed.
5. **Ask on policy**; **infer on facts** already captured in Phase 1.
6. **Escape hatch** at every policy checkpoint: *"Specify now, or I'll infer and show a draft to approve."*
7. **Never copy guide examples verbatim** unless they match this project — including non-negotiables: use the stack, tools, and patterns Phase 1 actually found.
8. **Stop** at the last documented step — do not implement scoped instructions or Copilot skill parity until a new `step-*.md` exists in this folder.
9. **Graphify is optional and non-blocking** — see `step-0.5-graphify.md`. Never halt the harness waiting on Graphify.
10. **Stay in scope** — read only from this `guide/` folder and the target repo. Copyable templates (e.g. `agents/docs-explorer.md`, `chatmodes/docs-explorer.chatmode.md`, `skills/graphify/`) live inside `guide/`; never read or reference sibling demo/example projects (such as `ai-harness-starter-kit/*`) for instructions or templates — they are illustrative outputs, not sources of truth.
11. **Keep the facilitator's context bounded** (extends rule 2) — never preload later steps or `GRAPHIFY_GUIDE.md` (on-demand reference). Run discovery and any multi-file "where is X" search in a **subagent** (`Explore` / `general-purpose`, or Graphify) so raw file dumps stay out of the main window — only the distilled draft returns. On a large repo, **bound discovery scope**: exclude vendored/generated/build dirs, start from the active subtree, and sample rather than read exhaustively. This is what keeps a large-codebase run from hitting the context limit. For large repos and monorepos, also **split the run across fresh sessions at phase gates** — see `large-codebases.md`.
12. **Track resume state cheaply** — keep a small `guide/.harness-progress.md` ledger (next phase, phase checkboxes, artifacts, deferred decisions). Create it at Phase 0–1, update it at each gate (rule 4 — a checkbox + the `Next:` line, nothing more), and **delete it once Phase 6 is approved**. It is gitignored (`guide/.gitignore`) and stays tiny, so it costs almost nothing yet lets the rollout stop and restart in any later session. To resume: open a new conversation and read it. Full mechanics in `large-codebases.md`.

### Phase flow

One row per phase: what to load, whether it scans, what to ask, and what to do if the human defers. Every phase follows the gate in Operating rule 4 (draft → approve → write → summarize).

| Phase | Step file | Discovery | Checkpoint — ask human | Infer if deferred |
|-------|-----------|-----------|------------------------|-------------------|
| 0 — Kickoff | *(this hub)* | No | Confirm repo root only | — |
| 0.5 — Graph *(optional)* | `step-0.5-graphify.md` | Yes — if opted in | Enable Graphify? yes/no | Skip if declined |
| 1 — Init | `step-1-claude.md` | Subagent scan / `/init` — reused after | Routing rows | Agent-generate from discovery |
| 2 — Baseline | `step-2-agents.md` | Reuse Phase 1 | 3–6 non-negotiables | Propose from conventions; skip inapplicable categories |
| 2.5 — Instructions | `step-2.5-instructions.md` | Reuse Phase 1 | Which scoped domains | One file per layer found + `security` (`applyTo: "**"`) |
| 3 — Guardrails | `step-3-claude-folder.md` | Reuse Phase 1 | Hooks/permissions (§3.1) + subagents/chat modes (§3.3) | Minimal lint + denies; install `docs-explorer` agent + chat mode only |
| 4 — Context docs | `step-4-context-docs.md` | Targeted reads only | Which domains | Doc list from tree or graph |
| 5 — MCP | `step-5-mcp.md` | No | Figma for frontend? yes/no | Baseline only (filesystem, memory, git, context7) |
| 6 — Skills | `step-6-skills.md` | Reuse Phase 1 | Staple + codebase-specific list | Staples (§6.2) + one per major framework/runtime found |

**Phase notes** (only the non-obvious handling — the rest is in each step file):

- **Phase 0:** Confirm workspace root. Open with: *"At Phase 0.5 I'll ask whether you want Graphify. Either way, we do one discovery pass — graph or `/init` — then reuse it for the rest."* On a **large repo or monorepo**, read `large-codebases.md` first — it covers per-package scoping and splitting the run across fresh context windows at phase gates.
- **Phase 0.5 / 1:** If Graphify is declined or install fails, fall through to `/init` discovery in Phase 1.
- **Phase 1:** Also write the Copilot entry file `.github/copilot-instructions.md` from the same discovery (no routing table — Copilot uses `applyTo` auto-load).
- **Phase 2.5:** Author `.github/instructions/*.instructions.md` — the **shared** scoped rules both tools consume (Copilot via `applyTo`, Claude via the routing table). Reconcile the Step 1 routing rows against the files actually created.
- **Phase 3:** Merge Graphify PreToolUse if Step 0.5 ran (§3.2). Default subagent is `docs-explorer` (template at `agents/docs-explorer.md`) when the human names nothing else; mirror it with the `docs-explorer` Copilot **chat mode** (`chatmodes/docs-explorer.chatmode.md`). Hooks/permissions are Claude-only — Copilot has no equivalent.
- **Phase 5:** Mirror `.mcp.json` with `.vscode/mcp.json` for Copilot (§5.4 — `servers`/`inputs` schema, hosted `github` server).
- **Phase 6:** Staples are security, primary-language conventions, and testing (§6.2), plus codebase-specific skills from Phase 1 discovery. Convert **task/workflow** skills to `.github/prompts/*.prompt.md` (§6.5); reference skills are already covered by Phase 2.5 instruction files.

### Extension pattern

When adding a new harness step:

1. Create `step-N-<name>.md` in this folder with content + **AI-DLC checkpoint** blockquote. To **insert** a phase between existing ones, use decimal naming (`step-N.5-<name>.md`, as with `step-0.5-graphify.md` and `step-2.5-instructions.md`) rather than renumbering later steps.
2. Add a row to **`README.md`** index and the **Phase flow** table above.
3. Add a **Phase note** under the table only if the phase needs non-obvious handling.
4. If the step has a GitHub Copilot counterpart, document it as a "Copilot parity" subsection in the same step file and update the parity table in `00-how-files-relate.md`.

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

See **`README.md`** for the full file index and step-order tables — not repeated here to keep this hub (loaded on every phase) lean. More steps are added as new files in this folder using the extension pattern above.
