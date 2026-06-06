# AI Harness Setup Guide

A step-by-step guide for setting up a shared AI layer for GitHub Copilot and Claude Code in any codebase. Everything you need is in this file — work through it manually or use AI-DLC mode below.

### How to follow this guide

You can work through it in either mode — same steps, same outcome:

| Mode | Who drives | Best for |
|------|------------|----------|
| **Manual** | You read each step and create/edit the files yourself | Learning the harness, small tweaks, full control |
| **AI-DLC** | An AI facilitator runs the phases below; you answer policy questions and approve drafts | Rolling out the harness in a real repo with a senior or team lead in the loop |

Manual: start at **Step 1: Initialize CLAUDE.md** below. Optionally run **Step 0.5** first if you want Graphify.

AI-DLC: open this file in your agent (Cursor Plan/Agent mode, Claude Code, etc.), paste a prompt like the one below, and let the AI pause at each **AI-DLC checkpoint** for your input.

### Optional: Graphify (Step 0.5)

Graphify is **not required** for the harness. At Phase 0.5 the facilitator asks whether you want it. If **yes**, build the codebase graph and use it for discovery in Phases 1–4 (lower token usage). If **no**, skip Step 0.5 and use the classic `/init` discovery path — the rest of the harness works the same.

**Graphify never blocks harness setup.** If Python 3.10+ or the `graphify` CLI is unavailable, skip Step 0.5 and continue with `/init` — same outcome minus the graph layer.

#### Graphify prerequisites (only if you opt in)

| Requirement | Minimum | Check |
|-------------|---------|-------|
| Python | **3.10+** | `python3 --version` |
| CLI | `graphify` on PATH | `graphify --version` |
| Installer *(pick one)* | `uv`, `pipx`, or `pip --user` | `uv --version` / `pipx --version` |

The PyPI package is **`graphifyy`** (double-y); the CLI command is `graphify`.

**Preflight** (run before Step 0.5 if you said yes to Graphify):

```bash
python3 --version          # must show 3.10 or higher
graphify --version 2>/dev/null || echo "graphify not installed"
```

If Python is below 3.10 (e.g. macOS system `3.9.6`) or `graphify` is missing, **run the install flow in Step 0.5.0** (do not skip immediately). Only skip Graphify if install fails or the human declines — then proceed to Step 1 with `/init`.

#### Installing Python 3.10+ on macOS *(when system Python is too old)*

macOS often ships Python 3.9.x only. Graphify needs 3.10+. Pick one path:

```bash
# Recommended — Homebrew Python + uv (uv manages graphify in an isolated env)
brew install python@3.12 uv
uv tool install graphifyy
graphify --version

# Alternative — Homebrew Python + pipx
brew install python@3.12 pipx
pipx install graphifyy
graphify --version

# Alternative — python.org installer
# Download Python 3.12+ from https://www.python.org/downloads/macos/
# Then: python3.12 -m pip install --user graphifyy
# Ensure ~/.local/bin is on PATH
```

After install, re-run preflight. If it still fails, **skip Graphify** — the harness is complete without it.

**Do not run `uv tool install graphifyy` manually here** — Step 0.5.0 runs check-and-install when Graphify is opted in.

**Example prompt:**

```
Implement the AI harness in this repo by following HARNESS_SETUP_GUIDE.md
using the AI-DLC section at the top.

Work one phase at a time. Pause at every AI-DLC checkpoint — ask me policy
questions (non-negotiables, hooks, context doc domains) or offer to infer
from the codebase and show a draft for approval. Do not skip phases or
implement steps not yet documented in the guide.

Start with Phase 0 kickoff. At Phase 0.5, ask whether to enable Graphify — if yes,
run Step 0.5.0 check-and-install (preflight, then install if missing); only skip
Graphify if install fails or I decline. Stop at end of Step 4.
Do not write AGENTS.md until CLAUDE.md is approved.
```

---

## AI-DLC: Implement this harness

The section below is the **AI-DLC runbook** — operating rules for an AI facilitator. If you're following manually, skip ahead to **How the two files relate** below.

When a senior or team lead uses AI-DLC mode, work **phase by phase** — the human provides policy, the AI structures the work, shows drafts, and writes only after approval.

**Scope:** implement only the steps documented below. Stop at the end of Step 4 until this guide is extended.

### Roles

| Role | Responsibility |
|------|----------------|
| **Human** (senior / team lead) | Answers policy questions, approves drafts |
| **AI** | Runs `/init` or equivalent once, asks checkpoint prompts, infers when human defers, writes after approval |

### Operating rules

1. **One phase at a time** — map 1:1 to guide steps below.
2. **Single discovery** — one full repo scan, then reuse that output. **With Graphify:** Phase 0.5 (`graphify extract .`); Phases 1–4 use `GRAPH_REPORT.md` and `graphify query`. **Without Graphify:** Phase 1 (`/init` or equivalent); later phases reuse `CLAUDE.md` and init output. Do not re-discover stack or structure in either path.
3. **Phase gate** — show draft → get approval → write → summarize → proceed.
4. **Ask on policy**; **infer on facts** already captured in Phase 1.
5. **Escape hatch** at every policy checkpoint: *"Specify now, or I'll infer and show a draft to approve."*
6. **Never copy guide examples verbatim** unless they match this project.
7. **Stop** at the last documented step — do not implement skills, MCP, or scoped instructions until those sections exist in this guide.
8. **Graphify is optional and non-blocking** — if the human opts in, run Step 0.5.0 check-and-install before Step 0.5.1. If preflight fails, **attempt install** (Python upgrade + `graphifyy` CLI) with human approval — do not skip until install fails or the human declines. Then **continue to Phase 1 with `/init`**. Never halt the harness waiting on Graphify.

### Phase flow

| Phase | Guide step | Discovery? | Policy checkpoint? |
|-------|------------|------------|-------------------|
| 0 — Kickoff | (preface) | No | Confirm repo root only |
| 0.5 — Graph *(optional)* | Step 0.5: Graphify | **Yes — if opted in** | **Ask: enable Graphify?** |
| 1 — Init | Step 1: `CLAUDE.md` | Reuse Phase 0.5 or `/init` | Light — routing rows |
| 2 — Baseline | Step 2: `AGENTS.md` | Reuse Phase 1 | **Yes — non-negotiables** |
| 3 — Guardrails | Step 3.1–3.2: hooks | Reuse Phase 1 | **Yes — hooks & permissions** |
| 4 — Context docs | Step 4 | Targeted reads only | **Yes — which domains** |

**Phase 0 — Kickoff:** Confirm workspace root. Open with: *"At Phase 0.5 I'll ask whether you want Graphify for token-efficient discovery. Either way, we do one discovery pass — graph or `/init` — then reuse it for the rest."*

**Phase 0.5 — Step 0.5 *(optional)*:** **Ask the human:** *"Enable Graphify for this project?"* If **no**, skip to Phase 1 with `/init`. If **yes**, run **Step 0.5.0 check-and-install** (see below): verify `python3 --version` and `graphify --version`; if missing, propose and run the install flow with human approval; re-verify. Only proceed to 0.5.1 when `graphify --version` succeeds. If install fails or human skips install, continue to Phase 1 with `/init`.

**Phase 1 — Step 1:** **If Graphify enabled:** draft `CLAUDE.md` from `GRAPH_REPORT.md` + `graphify query` — not a blind scan. **If Graphify skipped:** run `/init` or equivalent single scan and write `CLAUDE.md`. Gate: approve `CLAUDE.md` before Step 2. Do not write `AGENTS.md` yet.

**Phase 2 — Step 2:** Distill stack, commands, and architecture from Phase 1 output — not a fresh scan. Include the Graphify section in `AGENTS.md` **only if Graphify was enabled** in Phase 0.5. Ask for 3–6 non-negotiables (or infer from conventions Phase 1 surfaced). Gate: approve `AGENTS.md` before Step 3.

**Phase 3 — Steps 3.1–3.2:** Infer package manager and lint scripts from Phase 1 context. **If Graphify enabled:** merge its PreToolUse hook with PostToolUse lint — do not overwrite PreToolUse. **If Graphify skipped:** write Step 3.1 hooks only (no Step 3.2). Ask about PostToolUse lint, Stop test gate, permission denies. If deferred: PostToolUse lint (`|| true`) + standard denies; omit Stop hook.

**Phase 4 — Step 4:** Ask which code areas need context docs (or infer from repo tree / graph communities if Graphify enabled). **If Graphify enabled:** run `graphify query` per domain before reading source. Gate: approve file list + one sample doc. Update `CLAUDE.md` routing rows.

### Checkpoint quick-reference

| Checkpoint | Source of facts | Ask human | Infer if deferred |
|------------|-----------------|-----------|-------------------|
| Graphify (Phase 0.5) | — | **Enable Graphify? yes/no** | Skip if human defers (default: ask explicitly) |
| Graphify check | `python3 --version`, `graphify --version` | Approve install plan if missing | Run Step 0.5.0 install flow |
| Graphify install | Step 0.5.0 commands | Approve running install (brew/uv/pip) | Best available: uv → pipx → pip |
| Graphify ready | `graphify --version` after install | Confirm before 0.5.1 | Skip Graphify → `/init` if install fails |
| Graph built | `graphify extract .` | Confirm graph built | Proceed if stats OK |
| `CLAUDE.md` | Graph or `/init` | Routing rows | Agent-generate from discovery output |
| Non-negotiables | Phase 1 + policy | 3–6 universal rules | Propose from conventions found |
| Hooks | Phase 1 manifest | PostToolUse / Stop / denies | Minimal lint + default denies; merge PreToolUse only if Graphify on |
| Context docs | Domains (+ graph if enabled) | Which domains | Doc list from tree or graph |

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

**Creation order (setup):** optionally build the graph (Step 0.5), then create `CLAUDE.md` from that output or from `/init`, then `AGENTS.md` distilled from Phase 1 plus team policy. **Load order (runtime):** unchanged — Copilot reads `AGENTS.md` every request; Claude reads `AGENTS.md` first, then uses `CLAUDE.md` routing.

---

## Step 0.5: Build codebase graph (Graphify) — *optional*

**Skip this step** if you declined Graphify at Phase 0.5 **or preflight failed** — go straight to Step 1 and use `/init` discovery. A failed Graphify install is not a harness failure.

Run from the **project workspace root** (where harness files will live — not a monorepo parent folder unless the harness lives there).

### 0.5.0 Check and install Graphify *(when opted in)*

Run these checks from the project root **before** creating `.graphifyignore` or running `graphify extract`.

#### 1. Preflight

```bash
python3 --version
command -v graphify >/dev/null && graphify --version || echo "graphify not installed"
command -v uv >/dev/null && uv --version || true
command -v pipx >/dev/null && pipx --version || true
command -v brew >/dev/null && brew --version || true
```

| Check | Pass | Fail → action |
|-------|------|----------------|
| `graphify --version` | Continue to **0.5.1** | Start **install flow** (step 2) |
| Python ≥ 3.10 | Required for install | Install Python first (step 2a), then graphify (step 2b) |

#### 2. Install flow *(AI-DLC: show plan, get approval, then run)*

**2a — Python &lt; 3.10** (e.g. macOS system `3.9.6`):

```bash
# Preferred (macOS with Homebrew)
brew install python@3.12 uv
```

No Homebrew? Offer [python.org/downloads](https://www.python.org/downloads/macos/) or `pyenv`. Re-check: `python3 --version`.

**2b — Install `graphify` CLI** (pick first available):

```bash
# A — uv (recommended; isolates graphify from system Python)
uv tool install graphifyy

# B — pipx
pipx install graphifyy

# C — pip (use Python 3.10+ explicitly if multiple versions exist)
python3.12 -m pip install --user graphifyy
# ensure ~/.local/bin is on PATH
```

**2c — Verify**

```bash
graphify --version
```

| Result | Action |
|--------|--------|
| Success | Continue to **0.5.1** |
| Still missing / install error | Report error; ask human: **retry**, **fix manually**, or **skip Graphify** → Phase 1 `/init` |

> **AI-DLC:** Do not skip Graphify on first failed check — run the install flow first. Only skip after a failed install attempt or explicit human decline.

#### 3. Manual path

If the facilitator cannot run brew/uv (sandbox, permissions), print the exact commands for the human to run locally, wait for confirmation, then re-run `graphify --version`.

### 0.5.1 Add `.graphifyignore`

Exclude build artifacts **and markdown docs** from the graph. Graphify treats `.md` files as documents and runs **LLM semantic extraction** on them (requires an API key and adds harness/setup prose you usually do not want in a code graph). For harness setup, prefer a **code-only** graph via tree-sitter (offline, no API key for TS/Prisma).

For Next.js + Prisma apps:

```
node_modules/
.next/
out/
*.db
src/generated/
graphify-out/

# Docs — exclude for code-only graphs (README.md is picked up as LLM doc extraction by default)
README.md
docs/
```

Add other root markdown as needed (`AGENTS.md`, `CLAUDE.md`, `LEARN.md`, …) or use `*.md` if the repo has no source markdown you need in the graph.

If Graphify still tries to LLM-extract docs, confirm `.graphifyignore` is at the **project root** where you run `graphify extract .`, then re-run extract.

### 0.5.2 Build and install

```bash
# 1. Build graph (code-only, offline — no API key for TS/Prisma)
graphify extract .

# 2. Register harness files in-repo
graphify install --project
graphify claude install --project    # Claude Code: skill + CLAUDE.md + PreToolUse hook
graphify vscode install --project    # VS Code Copilot Chat: AGENTS.md graph guidance

# 3. Optional: auto-rebuild on commit (AST-only, no API cost)
graphify hook install
```

**Outputs:**
- `graphify-out/GRAPH_REPORT.md` — god nodes, communities, suggested questions (~1 page)
- `graphify-out/graph.json` — queryable graph
- `.claude/skills/graphify/SKILL.md` — Claude `/graphify` skill
- `.github/prompts/graphify.prompt.md` — Copilot `/graphify` prompt (copy from `01-barebones/` if not auto-created)
- CLAUDE.md graphify section + PreToolUse hook (via `graphify claude install --project`)
- AGENTS.md graphify section (via `graphify vscode install --project` — merge with Step 2 draft)

Verify: `graphify stats`

> **AI-DLC checkpoint — Phase 0.5**
> **Ask:** *"Enable Graphify for this project?"* If **no**, skip to Phase 1 with `/init`. If **yes**, run **0.5.0 check-and-install**: preflight → if `graphify` missing, propose install (Python upgrade if needed, then `uv tool install graphifyy` or pipx/pip) → get approval → run install → re-verify. Only run **0.5.1–0.5.2** when `graphify --version` succeeds. If install fails or human skips, continue to Phase 1 with `/init`.

---

## Step 1: Initialize CLAUDE.md

### Path A — Graphify enabled (Step 0.5 completed)

Use the **graph as your discovery source**. Read `graphify-out/GRAPH_REPORT.md` and run targeted queries:

```bash
graphify query "layer dependencies"
graphify query "entry points and architecture"
graphify query "API to database flow"
```

Draft `CLAUDE.md` from graph communities + any existing instruction files. Do **not** Glob/Grep/Read source files unless a query returns insufficient detail. Include the Graphify routing row (see template below).

### Path B — Graphify skipped (classic discovery)

Run `/init` **once**. It scans your codebase and generates `CLAUDE.md` — stack, structure, conventions, routing table, and references to existing harness files. This discovery pass feeds everything that follows; don't scan the repo again for Step 2.

In Claude Code:

```
/init
```

If you're not in Claude Code, perform an equivalent single scan and generate `CLAUDE.md` at the repo root. Omit Graphify rows from the routing table.

### CLAUDE.md template (both paths)

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
- Code graph *(Graphify only)*: `graphify-out/GRAPH_REPORT.md` — build with `/graphify .` or `graphify extract .`
- Skills: `.claude/skills/<name>/SKILL.md`
- Legacy commands: `.claude/commands/*.md`
- Subagents: `.claude/agents/*.md`
- Hooks + permissions: `.claude/settings.json`
- MCP servers: `.mcp.json`
```

Adjust routing rows to match the instruction and context files you actually have.

Review and customize the generated file — in particular, update the routing table to match the instruction files you actually have.

> **AI-DLC checkpoint — Phase 1**
> Stop after drafting `CLAUDE.md`. Review and approve before Step 2. This is the only full discovery pass — do not re-scan for AGENTS.md.

---

## Step 2: Set up AGENTS.md

With `CLAUDE.md` in place, create `AGENTS.md` as the **shared baseline** Copilot and all agents load on every request. Pull stack and commands from Phase 1 output; add non-negotiables from the team.

**If Graphify was enabled in Step 0.5**, also include:

```markdown
## Code graph (Graphify)
For architecture or cross-file questions, read `graphify-out/GRAPH_REPORT.md` or run
`graphify query "..."` before opening multiple source files. Rebuild after structural
changes: `graphify update .`. Copilot: type `/graphify` in chat. Claude: `/graphify query`.
```

And add `.github/prompts/graphify.prompt.md` for Copilot (see `01-barebones/` template). **If Graphify was skipped, omit these** — do not reference Graphify in `AGENTS.md` or install graphify prompt/skill files.

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

### 3.2 Merge Graphify + harness hooks *(Graphify only)*

**Skip this subsection** if Graphify was not enabled in Step 0.5.

Step 0.5 runs `graphify claude install --project`, which adds a **PreToolUse** hook (nudge before Glob/Grep/Read). Step 3.1 adds **PostToolUse** lint and optional **Stop** test gate. These must coexist — **merge, do not overwrite** PreToolUse when writing harness hooks:

```json
{
  "permissions": { "...": "..." },
  "hooks": {
    "PreToolUse": [
      { "...": "graphify hook — installed by graphify claude install in Phase 0.5" }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "...": "lint hook from Step 3.1" }
    ],
    "Stop": [ "...optional..." ]
  }
}
```

**Order:** Graphify install in Phase 0.5 first; write harness hooks in Phase 3 after, preserving PreToolUse.

Copilot has no PreToolUse hook — it uses the Graphify section in `AGENTS.md`, `copilot-instructions.md`, and the `/graphify` prompt instead.

---

## Step 4: Generate context docs

Context docs describe **how the system works** — for AI deep dives and dev onboarding. They complement the other layers:

| Layer | File(s) | Loads | Content |
|-------|---------|-------|---------|
| Baseline | `AGENTS.md` | Every request | Stack, commands, non-negotiables — **short** |
| **Code graph** *(optional)* | `graphify-out/GRAPH_REPORT.md` | On demand | Code relationships — only if Graphify enabled |
| Rules | `.github/instructions/*.instructions.md` | On scope/intent | How to **write** code |
| **Context** | `docs/context/*.md` | On demand | How the system **works** |

Instructions are prescriptive ("validate with Zod"). Context docs are descriptive ("auth flow goes through middleware X → service Y"). Same discipline: short, scoped, no filler.

### Where they live

- `docs/context/*.md` — one file per domain (committed, versioned with code).
- `docs/context/README.md` — index listing each doc, when to read it, and a pointer to the documentation rules below.

### Which code sections to document

Document **boundaries and flows**, not every file. **If Graphify enabled**, run `graphify query "<domain> layer boundaries and entry points"` before reading source for that domain. One doc per area a new senior would need on day one:

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
