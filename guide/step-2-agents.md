# Step 2: Set up AGENTS.md

**Phase 2 · AI-DLC checkpoint below**

With `CLAUDE.md` in place, create `AGENTS.md` as the **shared baseline** Copilot and all agents load on every request. Pull stack and commands from Phase 1 output; add 3–6 non-negotiables from the team or from conventions discovery surfaced.

**If Graphify was enabled in Step 0.5**, also include:

```markdown
## Code graph (Graphify)
For cross-file architecture questions, use the graph (`/graphify` or `graphify query`) before opening multiple source files. Details in `.claude/skills/graphify/`. Rebuild: `graphify update .`.
```

Keep this **one short paragraph** — the PreToolUse hook and `graphify` skill carry the graph-first workflow; do not expand `AGENTS.md` with query gates or when-to-use tables.

And add `.github/prompts/graphify.prompt.md` for Copilot:

```markdown
---
mode: agent
---
Use the Graphify skill / MCP to query the codebase graph before reading many source files.
Prefer `graphify query "..."` for architecture and cross-file questions.
```

**If Graphify was skipped, omit these** — do not reference Graphify in `AGENTS.md` or install graphify prompt/skill files.

---

This file is read on every request, so keep it short. At minimum it should contain stack, commands, and 3–6 non-negotiables. **The block below is a shape example only** — replace every bullet with what this project actually uses:

```markdown
# Project: <Your App Name>

## Stack
- <from Phase 1 discovery>

## Commands
- <from package.json / Makefile / pyproject.toml — real script names>

## Non-negotiables
- <3–6 universal rules inferred from the codebase or confirmed by the team>
```

**Illustrative only (do not copy unless true for this repo):**

```markdown
## Non-negotiables
- Named exports only. No default exports (except framework-required files).
- All external input validated with <actual lib or pattern> before use.
- Mirror the linter — never generate code that fails `npm run lint`.
```

---

## What belongs in Non-negotiables

These are rules that apply **everywhere**, regardless of what file or feature is being worked on. A good test: if breaking the rule in any file would be wrong, it belongs here.

**Common rule types** (pick only what discovery or the team supports — not every project needs every type):

| Type | Example phrasing | Include when… |
|------|------------------|---------------|
| Export / module style | named exports only | Consistent pattern in source |
| Input validation | validate with `<lib>` at boundaries | Validation lib or handler pattern exists |
| Delete / data lifecycle | soft-delete with `deletedAt` | Repo uses that pattern |
| Lint / format | mirror `npm run lint` | Linter configured |
| Security invariant | never log sensitive fields | Team policy or repeated code pattern |
| Architecture boundary | UI → service → repo, no ORM in components | Layering is enforced in code |

You may add other universal rules (error shape, test expectations, auth invariants) if they apply repo-wide. Aim for **3–6 rules total**, not 3–6 categories.

If a rule only applies in specific folders or file types, move it to a scoped `.github/instructions/*.instructions.md` file instead.

> **AI-DLC checkpoint — Phase 2**
> Stop. Distill stack and commands from `CLAUDE.md` / Phase 1 output. Ask for 3–6 non-negotiables, or propose a draft from conventions discovery found — **only rule types with evidence in the repo**. Show draft `AGENTS.md` for approval before writing. Do not paste the illustrative examples above.

---

## Where to stop

`AGENTS.md` loads on **every** request. Every line here costs tokens on every interaction, so treat it like a header file — only what's truly universal. Move anything more specific to `.github/instructions/*.instructions.md`:

| Belongs in `AGENTS.md` | Move to a scoped instructions file |
|------------------------|-------------------------------------|
| Stack & run commands | How to structure a React component |
| Universal hard rules | Database query patterns |
| Repo-wide constraints | API route conventions |
| | Test setup and patterns |
| | Security rules for specific layers |

A good signal that something has drifted too far: if a rule only matters when touching a specific folder, feature type, or file pattern — it belongs in a scoped file with a matching `applyTo` glob, not here.

**Next:** `step-3-claude-folder.md`
