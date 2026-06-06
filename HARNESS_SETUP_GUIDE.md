# AI Harness Setup Guide

A step-by-step guide for setting up a shared AI layer for GitHub Copilot and Claude Code in any codebase.

> **Reference examples:** See [`ai-harness-starter-kit/01-barebones/`](ai-harness-starter-kit/01-barebones/) for a minimal harness with every file trimmed to its essence. Start with [`LEARN.md`](ai-harness-starter-kit/01-barebones/LEARN.md) for an annotated walkthrough of the full structure.

---

## AI-DLC: Implement this harness

This guide is an **implementation runbook**, not just reference material. When a senior or team lead asks an AI to roll out the harness, work **phase by phase** — the human provides policy, the AI structures the work, shows drafts, and writes only after approval.

**Scope:** implement only the steps documented below. Stop at the end of Step 4 until this guide is extended.

### Roles

| Role | Responsibility |
|------|----------------|
| **Human** (senior / team lead) | Answers policy questions, approves drafts |
| **AI** | Runs `/init` or equivalent once, asks checkpoint prompts, infers when human defers, writes after approval |

### Operating rules

1. **One phase at a time** — map 1:1 to guide steps below.
2. **Single discovery** — Phase 1 (`/init` or equivalent) is the only full repo scan. Later phases reuse `CLAUDE.md` and init output; do not re-discover stack or structure.
3. **Phase gate** — show draft → get approval → write → summarize → proceed.
4. **Ask on policy**; **infer on facts** already captured in Phase 1.
5. **Escape hatch** at every policy checkpoint: *"Specify now, or I'll infer and show a draft to approve."*
6. **Never copy guide examples verbatim** unless they match this project.
7. **Stop** at the last documented step — do not implement skills, MCP, or scoped instructions until those sections exist in this guide.

### Phase flow

| Phase | Guide step | Discovery? | Policy checkpoint? |
|-------|------------|------------|-------------------|
| 0 — Kickoff | (preface) | No | Confirm repo root only |
| 1 — Init | Step 1: `CLAUDE.md` | **Yes — `/init` once** | Light — `/init` vs agent-generate; routing rows |
| 2 — Baseline | Step 2: `AGENTS.md` | Reuse Phase 1 | **Yes — non-negotiables** |
| 3 — Guardrails | Step 3.1: hooks | Reuse (scripts from manifest) | **Yes — hooks & permissions** |
| 4 — Context docs | Step 4 | Targeted read of domains only | **Yes — which domains** |

**Phase 0 — Kickoff:** Confirm workspace root. Open with: *"We'll run `/init` first so Claude scans the repo once. Then we'll distill AGENTS.md from that — no second discovery pass."*

**Phase 1 — Step 1:** Run `/init` in Claude Code, or perform an equivalent single scan and write `CLAUDE.md`. Gate: approve `CLAUDE.md` before Step 2. Do not write `AGENTS.md` yet.

**Phase 2 — Step 2:** Distill stack, commands, and architecture from `CLAUDE.md` / init output — not a fresh scan. Ask for 3–6 non-negotiables (or infer from conventions init surfaced). Gate: approve `AGENTS.md` before Step 3.

**Phase 3 — Step 3.1:** Infer package manager and lint scripts from init context. Ask about PostToolUse lint, Stop test gate, permission denies. If deferred: PostToolUse lint (`|| true`) + standard denies; omit Stop hook.

**Phase 4 — Step 4:** Ask which code areas need context docs (or infer from repo tree). Generate using the documentation rules in Step 4. Gate: approve file list + one sample doc. Update `CLAUDE.md` routing rows.

### Checkpoint quick-reference

| Checkpoint | Source of facts | Ask human | Infer if deferred |
|------------|-----------------|-----------|-------------------|
| `CLAUDE.md` | `/init` scan | `/init` vs generate; routing rows | Agent-generate from one scan |
| Non-negotiables | Init + policy | 3–6 universal rules | Propose from init conventions |
| Hooks | Manifest from init | PostToolUse / Stop / denies | Minimal lint + default denies |
| Context docs | Domain folders | Which domains | Doc list from tree |

### Extension pattern

When this guide gains new steps, add the next phase using this shape — do not implement undocumented steps:

```markdown
#### Phase N — <Title> (Step N: …)
**Maps to:** Step N in this guide
**Scan:** …
**Ask:** …
**Infer if deferred:** …
**Draft:** …
**Gate:** …
```

Each new step also gets an inline blockquote:

```markdown
> **AI-DLC checkpoint — Phase N**
> …
```

---

## How the two files relate

| File | Who reads it | When |
|------|-------------|------|
| `AGENTS.md` | All AI tools (Copilot, Claude, any agent) | Every request — keep it short |
| `CLAUDE.md` | Claude Code only | Every session — Claude-specific memory & rule routing |

`AGENTS.md` is the shared baseline: stack, commands, architecture, and hard rules every tool needs on every request. `CLAUDE.md` builds on top of it with Claude-specific behavior — primarily a routing table that tells Claude which scoped rule file to read on demand based on the task.

**Creation order (setup):** create `CLAUDE.md` first — `/init` scans the repo once. Then create `AGENTS.md`, distilled from init context plus team policy. **Load order (runtime):** unchanged — Copilot reads `AGENTS.md` every request; Claude reads `AGENTS.md` first, then uses `CLAUDE.md` routing.

---

## Step 1: Initialize CLAUDE.md

Run `/init` **first**. It scans your codebase once and generates `CLAUDE.md` — stack, structure, conventions, routing table, and references to existing harness files. This discovery pass feeds everything that follows; don't scan the repo again for Step 2.

In Claude Code:

```
/init
```

This will:
- Scan your codebase structure and existing conventions
- Create a `CLAUDE.md` at your repo root
- Set up a rule routing table so Claude reads scoped instruction files on demand (the same `.github/instructions/*.instructions.md` files Copilot loads via `applyTo` globs)
- Reference any skills, commands, subagents, hooks, and MCP servers you have configured

If you're not in Claude Code, perform an equivalent single scan and generate `CLAUDE.md` using the structure in [`ai-harness-starter-kit/01-barebones/CLAUDE.md`](ai-harness-starter-kit/01-barebones/CLAUDE.md).

Review and customize the generated file — in particular, update the routing table to match the instruction files you actually have.

> **AI-DLC checkpoint — Phase 1**
> Stop after `/init` (or equivalent scan). Review and approve `CLAUDE.md` before Step 2. This is the only full repo discovery pass — do not re-scan for AGENTS.md.

---

## Step 2: Set up AGENTS.md

With `CLAUDE.md` in place, create `AGENTS.md` as the **shared baseline** Copilot and all agents load on every request. Pull stack and commands from what `/init` found; add non-negotiables from the team.

This file is read on every request, so keep it short. At minimum it should contain:

```markdown
# Project: <Your App Name>

## Stack
- (e.g. Next.js + TypeScript + Postgres + Tailwind + Vitest)

## Commands
- `npm run dev` · `npm test` · `npm run lint`

## Non-negotiables
- Named exports only. No default exports (except framework-required files).
- All external input validated with Zod before use.
- Server Components by default; "use client" only when interactive.
- Soft-delete with `deletedAt`; never hard-delete records.
- Mirror the linter — never generate code that fails `npm run lint`.
```

### What belongs in Non-negotiables

These are rules that apply **everywhere**, regardless of what file or feature is being worked on. A good test: if breaking the rule in any file would be wrong, it belongs here. Examples:

- Export style (`named exports only`)
- Input validation approach (`validate all external input with Zod`)
- Delete strategy (`soft-delete only`)
- A linter/formatter constraint the AI keeps violating (`always run lint before declaring done`)
- A security invariant (`never log sensitive fields`)

Aim for 3–6 rules. If you're writing more than that, ask whether the rule only applies in specific contexts — those belong in a scoped instructions file instead.

> **AI-DLC checkpoint — Phase 2**
> Stop. Distill stack and commands from `CLAUDE.md` / init output. Ask for 3–6 non-negotiables (or infer from conventions init found). Show draft `AGENTS.md` for approval before writing.

### Where to stop

`AGENTS.md` loads on **every** request. Every line here costs tokens on every interaction, so treat it like a header file — only what's truly universal. Move anything more specific to `.github/instructions/*.instructions.md`:

| Belongs in `AGENTS.md` | Move to a scoped instructions file |
|------------------------|-------------------------------------|
| Stack & run commands | How to structure a React component |
| Universal hard rules | Database query patterns |
| Repo-wide constraints | API route conventions |
| | Test setup and patterns |
| | Security rules for specific layers |

A good signal that something has drifted too far: if a rule only matters when touching a specific folder, feature type, or file pattern — it belongs in a scoped file with a matching `applyTo` glob, not here.

---

## Step 3: Set up the `.claude` folder

Create a `.claude/` directory at your repo root for Claude Code–specific configuration. Commit `.claude/settings.json` so the team shares the same guardrails; keep personal overrides in `.claude/settings.local.json` (gitignored).

| Path | Purpose |
|------|---------|
| `.claude/settings.json` | Hooks, permissions, and other shared Claude settings |
| `.claude/settings.local.json` | Personal overrides (API keys, local paths) — do not commit |
| `.claude/skills/<name>/SKILL.md` | On-demand workflows (richer than legacy commands) |
| `.claude/commands/*.md` | Legacy slash commands (still work) |
| `.claude/agents/*.md` | Subagents with their own prompt and tool restrictions |
| `.claude/hooks/*` | Shell scripts invoked by hooks in `settings.json` |

See [`ai-harness-starter-kit/01-barebones/.claude/`](ai-harness-starter-kit/01-barebones/.claude/) for a minimal working tree.

### 3.1 Hooks in `.claude/settings.json`

Hooks are lifecycle callbacks — scripts or prompts that run at specific moments in a Claude Code session (before/after a tool call, when you submit a prompt, when Claude stops, etc.). Unlike instructions in `AGENTS.md`, hooks **enforce** behavior deterministically: they run every time the event fires, whether or not the model remembered the rule.

Configure them under the `hooks` key in `.claude/settings.json`. Each event (e.g. `PostToolUse`, `PreToolUse`, `Stop`) holds an array of **matcher groups**. A matcher group filters which tool calls trigger the hook; the inner `hooks` array lists one or more handlers to run.

Run `/hooks` inside Claude Code to inspect what's loaded and which settings file each hook came from.

#### What makes a good production hook

Hooks add latency on every match, so treat them like CI steps — small, fast, and scoped.

| Principle | Why it matters |
|-----------|----------------|
| **Enforce, don't suggest** | Use hooks for things the agent keeps forgetting: auto-format, lint fixes, blocking dangerous commands. Keep guidance in instruction files. |
| **Pick the right event** | `PreToolUse` — intercept or block *before* a tool runs (security guards). `PostToolUse` — react *after* success (format/lint the file just written). `Stop` — final gate before Claude declares done (run tests, typecheck). |
| **Stay fast in the hot path** | `PostToolUse` runs after every edit. Keep it to sub-second work (`eslint --fix`, `prettier --write`). Save slow suites for `Stop`. |
| **Use matchers and `if`** | Match on tool name (e.g. `Edit`, `Write`, `Bash`) and narrow further with `if` (e.g. `"Edit(*.ts)"` for TypeScript only). Unscoped hooks on every tool call get expensive fast. |
| **Scripts over one-liners** | Put non-trivial logic in `.claude/hooks/*.sh` and reference it with `${CLAUDE_PROJECT_DIR}`. Easier to test, review, and reuse than inline shell in JSON. |
| **Fail open for auto-fix, fail closed for guards** | Lint/format hooks should not brick a session on a warning — use `|| true` or exit 0 after logging. Security `PreToolUse` hooks should exit 2 or return `permissionDecision: "deny"` to block. |
| **Pair with permissions** | Hooks and the `permissions` block in the same file are defense in depth: permissions deny `.env` reads; hooks can add contextual checks scripts can't express. |

Start with one `PostToolUse` lint-after-edit hook. Add `PreToolUse` guards and a `Stop` test runner once the basics are stable.

> **AI-DLC checkpoint — Phase 3**
> Stop. Ask which hooks to enable (PostToolUse lint, Stop test gate, permission denies). If the human defers, apply minimal PostToolUse lint + standard permission denies; omit Stop unless they opt in.

#### Example

A practical starter config: deny sensitive reads and destructive shell commands via permissions, auto-fix lint after every edit, and run the test suite before Claude stops.

**`.claude/settings.json`**

```json
{
  "permissions": {
    "allow": ["Bash(npm *)", "Bash(git *)", "Read(*)", "Edit(*)"],
    "deny": ["Bash(rm -rf *)", "Read(./.env)", "Read(./.env.*)"]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint --silent -- --fix || true"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/check-before-stop.sh",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

**`.claude/hooks/check-before-stop.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR}"
npm run typecheck
npm test
```

Make hook scripts executable (`chmod +x .claude/hooks/*.sh`).

The inline `PostToolUse` command is fine for a single fast fixer. Once you need branching, jq parsing, or file-type checks, move the logic into a script and keep `settings.json` as wiring only.

---

## Step 4: Generate context docs

Context docs describe **how the system works** — for AI deep dives and dev onboarding. They complement the other layers:

| Layer | File(s) | Loads | Content |
|-------|---------|-------|---------|
| Baseline | `AGENTS.md` | Every request | Stack, commands, non-negotiables — **short** |
| Rules | `.github/instructions/*.instructions.md` | On scope/intent | How to **write** code |
| **Context** | `docs/context/*.md` | On demand | How the system **works** |

Instructions are prescriptive ("validate with Zod"). Context docs are descriptive ("auth flow goes through middleware X → service Y"). Same discipline: short, scoped, no filler.

### Where they live

- `docs/context/*.md` — one file per domain (committed, versioned with code).
- `docs/context/README.md` — index listing each doc, when to read it, and a pointer to the documentation rules below.

### Which code sections to document

Document **boundaries and flows**, not every file. One doc per area a new senior would need on day one:

| Code area | Suggested doc | What to capture |
|-----------|---------------|-----------------|
| Repo overview | `architecture.md` | Layers, dependency direction, key entry points |
| API routes | `api.md` | Route map, auth boundaries, error shape |
| DB / ORM / repos | `data.md` | Schema overview, repo pattern, migrations |
| Auth / sessions | `auth.md` | Flow in prose, where tokens live |
| UI / components | `frontend.md` | Server vs client split, shared primitives |
| Jobs / workers | `background.md` | Triggers, queues, env requirements |

### Doc template

Every context file uses this structure:

```markdown
# <Domain>: <Short title>

## Purpose
One paragraph — what this area owns.

## Key paths
- `path/to/entry` — role

## How it works
Ordered steps or bullet flow (request → handler → service → repo).

## Dependencies
What this layer calls; what must not call into it.

## Gotchas
Non-obvious behavior, legacy paths, env vars (names only — no secrets).

## Related
Links to other context docs and relevant `.github/instructions/` files.
```

### Documentation rules (required for every generated file)

Treat these as hard constraints — same discipline as `.github/instructions/` rules.

**Hard limits**

| Rule | Requirement |
|------|-------------|
| **Length** | **≤150 lines** per file (including headings and blank lines). Split into a second file if needed. |
| **Headings** | `#` title + `##` sections only. No deep nesting beyond `##`. |
| **Code blocks** | Max one short snippet per doc (~10 lines). Prefer `` `path/to/file` `` references over pasted code. |
| **Duplication** | Never repeat content from another context doc or `AGENTS.md` — link instead. |

**Style**

| Rule | Requirement |
|------|-------------|
| **Opening** | First paragraph under `## Purpose` answers: *What does this area own, and why does it exist?* |
| **Voice** | Present tense, active voice. |
| **Density** | Bullets and tables over prose. Max ~3 sentences per bullet. |
| **Scope** | Behavior, boundaries, and flows — not file-by-file inventories. |
| **Accuracy** | Describe what the code **does today**. Mark uncertainty with `(verify)` — don't invent behavior. |
| **Secrets** | Env var **names** only. No values or credentials. |
| **Onboarding** | A new senior should grok the domain in **≤5 minutes** reading time. |

**Anti-patterns (never include)**

- Auto-generated directory trees listing every file.
- Copied OpenAPI schemas or full ORM models (summarize + link to source).
- Speculative architecture or tutorial-style setup steps.

**Generation checklist** (run before presenting drafts):

- [ ] ≤150 lines
- [ ] All template sections present (omit empty sections, don't pad)
- [ ] No duplicate content vs other context docs
- [ ] Key paths verified against the repo
- [ ] `docs/context/README.md` index updated

> **AI-DLC checkpoint — Phase 4**
> Stop. Ask which code areas need context docs (or infer from the repo tree). Show the proposed file list and one sample doc for approval. Every generated file must follow the documentation rules above (≤150 lines, template sections, no duplication). Update `CLAUDE.md` routing rows to match.

### Wire into the harness

Add rows to the `CLAUDE.md` routing table so Claude reads context docs on demand:

```markdown
| If the task involves...              | Read this file               |
|--------------------------------------|------------------------------|
| Overall architecture or onboarding   | docs/context/architecture.md |
| API routes or HTTP handlers          | docs/context/api.md          |
| …                                    | …                            |
```

Do **not** copy context docs into `AGENTS.md` — too long for every request.

**Optional — enforce rules on edits:** create `.github/instructions/context-docs.instructions.md` with `applyTo: "docs/context/**"` mirroring the documentation rules above, so Copilot follows the same constraints when editing context files.

---

_More harness steps (skills, subagents, MCP, scoped instructions) will be added to this guide over time — each gets a new step, AI-DLC phase, and checkpoint using the extension pattern above._
