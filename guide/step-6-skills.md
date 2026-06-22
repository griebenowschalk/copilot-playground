# Step 6: Set up codebase skills

**Phase 6 · AI-DLC checkpoint below**

Skills are on-demand procedures and reference material that load only when relevant — unlike `AGENTS.md`/`CLAUDE.md` (loaded every request) or context docs (loaded per domain). Create one when you keep re-explaining the same convention, checklist, or multi-step workflow, or when a section of `AGENTS.md` has grown into a *procedure* rather than a *fact*.

| Layer | Loads | Content |
|-------|-------|---------|
| `AGENTS.md` / `CLAUDE.md` | Every request | Stack, commands, non-negotiables — short |
| `docs/context/*.md` | On demand (domain match) | How the system works |
| **Skills** `.claude/skills/<name>/SKILL.md` | On demand (description match, or `/name`) | Conventions, style guides, step-by-step procedures |

They live at `.claude/skills/<name>/SKILL.md` — the directory name becomes the `/name` command. Project skills are committed and shared with the team; this step covers project skills only (not personal `~/.claude/skills/`).

**In a monorepo**, scope skills to the **active package** and use the `paths:` frontmatter (§6.1) so a skill only loads when working in its package — don't generate the full skill set for every package up front (see `large-codebases.md`).

---

## 6.1 Anatomy of a skill file

```markdown
---
name: kebab-case-name
description: What it does AND when to use it — Claude matches this to auto-route.
  Lead with the use case; combined description + when_to_use caps at 1,536 chars.
when_to_use: Trigger phrases or example requests (optional — appended to description)
allowed-tools: Read Grep            # tools pre-approved while this skill is active
disable-model-invocation: true      # only /name invokes — for side-effecting workflows
paths: "src/api/**"                 # auto-load only when working in matching paths
---

Body: conventions to apply inline, or step-by-step instructions to follow.
Keep it under 500 lines — move large reference material to supporting files.
```

| Field | Reach for it when... |
|-------|----------------------|
| `description` | Always — the single biggest lever for auto-routing. Lead with the use case and name the concrete technologies/keywords a developer would naturally say. |
| `when_to_use` | The description alone can't capture trigger phrases (e.g. "when reviewing a PR", "before cutting a release") |
| `allowed-tools` | The skill needs specific tools pre-approved every time it runs (e.g. `Bash(npm test *)` for a test-runner skill) |
| `disable-model-invocation: true` | The action has side effects or needs human timing, not Claude's judgment (deploys, releases, commits) |
| `user-invocable: false` | Background knowledge Claude should apply, but a human would never run as a `/command` |
| `paths` | The skill only matters for part of the repo (e.g. API conventions that shouldn't load while editing the frontend) |
| `context: fork` + `agent` | The skill is a self-contained research/analysis task better isolated in a subagent |

Full reference: [Skills frontmatter](https://code.claude.com/docs/en/skills#frontmatter-reference).

### Reference vs. task content

| Type | Purpose | Typical invocation |
|------|---------|--------------------|
| **Reference** | Conventions, patterns, domain knowledge applied alongside the conversation | Auto-loaded — omit `disable-model-invocation` |
| **Task** | Step-by-step procedure for a specific action (deploy, release, scaffold) | `disable-model-invocation: true` — run deliberately with `/name` |

### Progressive disclosure

Keep `SKILL.md` itself short — once loaded, its content stays in context for the rest of the session, so every line is a recurring cost. Move large reference material into supporting files and link to them:

```text
my-skill/
├── SKILL.md          # overview + navigation (required, <500 lines)
├── reference.md      # detailed material — loaded only when SKILL.md links to it
└── scripts/
    └── helper.sh     # run via ${CLAUDE_SKILL_DIR}/scripts/helper.sh, not loaded into context
```

---

## 6.2 Staple skills (propose for every codebase)

These categories are valuable in any repo. Generate their **content** from what Phase 1 discovery actually found (stack, lint/format config, test setup, `git log` conventions) — never copy examples verbatim (Operating rule 7 in the hub).

| Skill | Why it's a staple | Derive content from |
|-------|-------------------|---------------------|
| `<domain>-security` (e.g. `web-security`, `api-security`) | Security is easy to under-specify and costly to get wrong | The actual threat surface: web app → XSS/CSP/cookie handling; API/backend → injection, authz, secrets; CLI/library → input validation, supply chain |
| `clean-<primary-language>` (e.g. `clean-typescript`, `clean-python`) | Encodes the type/style discipline a senior would enforce in review | Existing lint/format config (`tsconfig.json`, `.eslintrc*`, `ruff.toml`, …) and patterns already dominant in the codebase |
| `testing-conventions` | Keeps generated tests consistent with how the team actually tests | Test framework, fixture/mocking patterns, and coverage expectations found under `test/`, `__tests__/`, `spec/` |

> Don't propose a custom `code-review` skill — `/code-review` ships bundled with Claude Code. If repo-specific review standards exist beyond what `/code-review` covers, fold them into `AGENTS.md` non-negotiables (Step 2) or a `clean-<language>` skill rather than duplicating the bundled command.

---

## 6.3 Codebase-specific skills (from discovery)

Propose one reference skill per major framework, runtime, or styling system Phase 1 discovery actually found — mirroring patterns like `modern-best-practice-nextjs`, `modern-tailwind`, or `bun-first`.

| If discovery found... | Propose |
|------------------------|---------|
| A frontend framework (Next.js, Remix, SvelteKit, …) | `<framework>-best-practices` — routing, data-fetching, and rendering conventions for the version in use |
| A component library / UI layer (React, Vue, …) | `<library>-components` — composition, state, and accessibility patterns |
| A CSS framework (Tailwind, …) | `<framework>-conventions` — utility patterns, theming, responsive rules |
| A specific runtime/package manager (Bun, Deno, pnpm, …) | `<runtime>-first` — preferred APIs/commands over Node/npm defaults |
| Recurring multi-step team procedures (release, migration, scaffolding) | Task skills — `disable-model-invocation: true`, step-by-step body |

These are **reference content** skills — write them like the team's style guide for that technology, not a tutorial. Note in the body that the library changes frequently and to reach for `docs-explorer` / context7 (Step 3 §3.3 / Step 5) for anything version-specific — the same way `modern-best-practice-nextjs` should.

---

## 6.4 Graphify skill *(only if Step 0.5 completed)*

**Skip this section** if Graphify was declined or install failed.

Do not add a second graphify skill — one reference skill is enough. Copy the template at [`skills/graphify/`](skills/graphify/) in this guide folder to `.claude/skills/graphify/` in the target repo:

| File | Purpose |
|------|---------|
| `SKILL.md` | Graph-first gate, query commands, `description` for auto-routing on architecture/cross-file work |
| `when-to-use.md` | When to query vs read source — linked from SKILL.md, not duplicated in `AGENTS.md` |

The skill complements the **PreToolUse hook** from `graphify claude install --project` (Step 0.5.2) — the hook enforces habit; the skill is the operator manual. At Phase 6, verify the skill exists and matches the template; do not regenerate unless the codebase needs project-specific query examples.

**At Phase 6 checkpoint:** if Graphify is on, confirm `graphify` skill is present — do not propose it again in the §6.3 shortlist.

---

## 6.5 Copilot parity — skills are shared, no prompts needed

Copilot Chat in VS Code reads `.claude/skills/<name>/SKILL.md` directly — both **reference**
skills (`clean-<lang>`, `<domain>-security`, `<framework>-best-practices`) and **task /
workflow** skills (`disable-model-invocation: true` — deploy, scaffold, review, `figma-to-code`)
are usable from either tool with no separate `.github/prompts/*.prompt.md` artifact.

So: write each skill once under `.claude/skills/`. Reference skills are *additionally*
covered by the `.github/instructions/*.instructions.md` files from Step 2.5 (Copilot's
`applyTo` auto-load), but task skills need nothing further — don't generate prompt
duplicates for them.

## 6.6 Content rules (apply to every generated skill)

| Rule | Requirement |
|------|-------------|
| **Length** | `SKILL.md` ≤500 lines; move detail to supporting files |
| **Description** | Lead with the use case; name concrete technologies/keywords a developer would say |
| **Voice** | Imperative, present tense — "Use `unknown` instead of `any`," not "You should consider…" |
| **Density** | Bullets and tables; ≤3 sentences per bullet — same discipline as context docs (Step 4) |
| **Accuracy** | Reflect what the codebase does **today**, not aspirational practice. Mark uncertainty `(verify)` |
| **No secrets** | Never embed credentials or tokens — that's MCP/env territory (Step 5) |
| **No duplication** | Don't restate `AGENTS.md` non-negotiables or context docs — link instead |

**Generation checklist** (run before presenting drafts):

- [ ] `description` leads with the use case and names concrete keywords
- [ ] ≤500 lines; large reference material split into supporting files
- [ ] No duplicate content vs `AGENTS.md`, context docs, or other skills
- [ ] `disable-model-invocation` set on any skill with side effects
- [ ] No secrets or credentials embedded

---

## 6.7 Figma design-to-code *(only if Figma was opted in)*

**Skip this section** if the Figma MCP server was not added in Step 5. When it was, install
`.claude/skills/figma-to-code/SKILL.md` — it auto-routes on Figma/design requests, pulls the
frame via the figma MCP, maps it to existing components, and builds per
`frontend.instructions.md`. It's visible to Copilot Chat directly too (§6.5), so no separate
prompt file is needed.

Copy the template at [`skills/figma-to-code/`](skills/figma-to-code/) in this guide folder
to `.claude/skills/figma-to-code/` in the target repo. It's a **task skill** (a workflow),
but left model-invocable so a request like "build this Figma frame" auto-routes to it. The
design payload from the figma MCP is large — the skill reads only the target node and notes
that very large frames can set `context: fork` + `agent` to isolate the read.

Alongside the skill, create `.claude/skills/figma-to-code/README.md` documenting
`FIGMA_API_KEY` setup: a single gitignored `.env` with the token serves **both** tools.
Both `.mcp.json` (Claude) and `.vscode/mcp.json` (Copilot) wrap the figma server in the same
`sh -c` launcher that reads **only** `FIGMA_API_KEY` from `.env` at startup — no manual
`export`, no VS Code prompt, no per-tool divergence. See Step 5 §5.2 and §5.4.

The skill must follow the **content rules in §6.6** and reuse existing components and
tokens before creating new ones — pixel-cloning a frame into bespoke markup is the failure
mode it exists to prevent.

---

> **AI-DLC checkpoint — Phase 6**
> Stop. Propose the staple skills (§6.2) plus a shortlist of codebase-specific skills (§6.3) inferred from Phase 1 discovery. **If Graphify was enabled (Step 0.5),** confirm the `graphify` skill from §6.4 — do not duplicate. **If Figma was opted in (Step 5),** install the `figma-to-code` skill + its `README.md` from §6.7. Ask the human to confirm, trim, or add to the list. If they defer, generate the staples plus one skill per major framework/runtime actually found — skip categories with no evidence in the repo. Skills are shared with Copilot Chat directly (§6.5) — no `.github/prompts/*.prompt.md` duplicates. Show draft `SKILL.md` (and `README.md` for figma-to-code) before writing; every file must follow the content rules in §6.6.

---

## Wire into the harness

Skills are auto-discovered from `.claude/skills/` — there's no routing table to update. Two things to check after writing:

1. **Restart if needed** — a brand-new `.claude/skills/` directory needs a session restart before Claude watches it; edits to existing skill files take effect live.
2. **Verify routing** — ask a question that matches each skill's `description` (e.g. "what's our approach to X?") and confirm Claude loads it, or invoke directly with `/<name>`.

**Looking for more skills?** Browse [skills.sh](https://www.skills.sh/) — a community directory of ready-made Claude Code skills you can drop into `.claude/skills/`.

**End of documented steps.** Scoped instructions (Step 2.5) and Copilot parity —
`.github/copilot-instructions.md` (Step 1), chat modes (Step 3), and `.vscode/mcp.json`
(Step 5) — are now part of the documented flow. Skills (§6.5) need no separate Copilot
artifact. Add further steps as new files in this folder — see the `HARNESS_SETUP_GUIDE.md`
extension pattern.
