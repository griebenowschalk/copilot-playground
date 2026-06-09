# Step 2.5: Author scoped instruction files

**Phase 2.5 · AI-DLC checkpoint below**

`AGENTS.md` (Step 2) holds only the rules that apply **everywhere**. Everything that
applies to a specific layer — React components, the database, API handlers, tests —
lives in **scoped instruction files** at `.github/instructions/*.instructions.md`. This
step authors them.

These files are the **shared backbone of both harnesses** — not a Copilot-only artifact:

| Tool | How it loads them |
|------|-------------------|
| **GitHub Copilot** | Auto-loads a file when the file you're editing matches its `applyTo` glob — no manual step |
| **Claude Code** | Reads them on demand via the `CLAUDE.md` routing table (Step 1) |

One source of truth, two load mechanisms. The `CLAUDE.md` routing rows from Step 1 point
at exactly the files you create here, so author them before relying on those rows.

---

## 2.5.1 Anatomy of an instruction file

```markdown
---
applyTo: "src/components/**/*.tsx,src/app/**/*.tsx"
---
# Frontend Rules
- Server Components by default; "use client" only for state, effects, browser APIs.
- Named exports; file name matches the component in PascalCase.
- …
```

| Part | Notes |
|------|-------|
| `applyTo` | Comma-separated globs (relative to repo root). Copilot loads the file when the edited file matches. Use `"**"` for repo-wide rules (e.g. security). |
| Body | Short, imperative, scoped rules — the same discipline as `AGENTS.md`, but for one layer only. |

---

## 2.5.2 Which domains to create

Derive the list from **Phase 1 discovery** — one file per layer that has rules distinct
from the universal ones in `AGENTS.md`. Don't pre-create files for layers that don't
exist in the repo. Common domains (the `applyTo` globs are **shape examples** — replace
with this repo's real paths):

| Domain | Typical `applyTo` | Create when discovery found… |
|--------|-------------------|------------------------------|
| Frontend / UI | `src/components/**,src/app/**/*.tsx` | A component layer or UI framework |
| Database / ORM | `prisma/**,src/db/**` | A schema, ORM, or repository layer |
| API / handlers | `src/app/api/**` | HTTP route handlers or controllers |
| Testing | `**/*.test.ts,**/*.spec.ts` | A test framework and convention |
| Security | `**` | Always — invariants that apply to every file |

`security.instructions.md` is the one staple: it uses `applyTo: "**"` so it loads on
every edit, mirroring the "security applies to everything" rule of thumb in `CLAUDE.md`.

**In a monorepo**, scope `applyTo` to the active package's subtree and create instruction
files for that package only — don't author the full set for every package up front (see
`large-codebases.md`).

---

## 2.5.3 Content rules (apply to every generated file)

Same discipline as context docs (Step 4) and skills (§6.5):

| Rule | Requirement |
|------|-------------|
| **Length** | Short — a handful of bullets per layer. If it grows past a screen, the rules are too broad for one `applyTo`. |
| **Scope** | Only rules that apply to files matching `applyTo`. Universal rules belong in `AGENTS.md`. |
| **No duplication** | Never restate `AGENTS.md` non-negotiables or another instruction file — the globs should not overlap into the same rule. Link instead. |
| **Voice** | Imperative, present tense — "Validate the body with Zod," not "You should validate." |
| **Accuracy** | Reflect what the codebase does **today**. Mark uncertainty `(verify)`. |
| **No secrets** | Never embed credentials — that's MCP/env territory (Step 5). |

**Generation checklist** (run before presenting drafts):

- [ ] One file per distinct layer found in Phase 1 — no speculative domains
- [ ] Each `applyTo` glob matches real paths in the repo
- [ ] `security.instructions.md` present with `applyTo: "**"`
- [ ] No rule duplicated across files or with `AGENTS.md`
- [ ] `CLAUDE.md` routing rows (Step 1) point at the files actually created

---

> **AI-DLC checkpoint — Phase 2.5**
> Stop. Propose the instruction-file list inferred from Phase 1 discovery (one per layer
> with distinct rules, plus `security`). Ask the human to confirm, trim, or add. If they
> defer, generate from the repo tree — only domains with evidence in the codebase. Show
> **exactly one** sample instruction file for approval before writing the set — do **not**
> paste all of them into chat (that duplicates every file in the transcript). Then reconcile the
> `CLAUDE.md` routing rows (Step 1) so every row points at a file that now exists.

---

## Wire into the harness

- **Claude:** confirm each `CLAUDE.md` routing row points at a real instruction file.
- **Copilot:** nothing to wire — `applyTo` auto-loading is automatic once the files exist.
  `.github/copilot-instructions.md` (Step 1) already tells Copilot that scoped rules live
  here and load by glob.

**Next:** `step-3-claude-folder.md`
