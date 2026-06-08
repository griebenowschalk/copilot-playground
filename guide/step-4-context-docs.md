# Step 4: Generate context docs

**Phase 4 · AI-DLC checkpoint below**

Context docs describe **how the system works** — for AI deep dives and dev onboarding. They complement the other layers:

| Layer | File(s) | Loads | Content |
|-------|---------|-------|---------|
| Baseline | `AGENTS.md` | Every request | Stack, commands, non-negotiables — **short** |
| **Code graph** *(optional)* | `graphify-out/GRAPH_REPORT.md` | On demand | Code relationships — only if Graphify enabled |
| Rules | `.github/instructions/*.instructions.md` | On scope/intent | How to **write** code |
| **Context** | `docs/context/*.md` | On demand | How the system **works** |

Instructions are prescriptive ("validate input at API boundaries"). Context docs are descriptive ("auth flow goes through middleware X → service Y"). Same discipline: short, scoped, no filler.

---

## Where they live

- `docs/context/*.md` — one file per domain (committed, versioned with code).
- `docs/context/README.md` — index listing each doc, when to read it, and a pointer to the documentation rules below.

---

## Which code sections to document

Document **boundaries and flows**, not every file. **If Graphify enabled**, run `graphify query "<domain> layer boundaries and entry points"` before reading source for that domain. **In a monorepo**, generate docs for the **active package only**, on demand — don't document every package up front (see `large-codebases.md`). One doc per area a new senior would need on day one:

| Code area | Suggested doc | What to capture |
|-----------|---------------|-----------------|
| Repo overview | `architecture.md` | Layers, dependency direction, key entry points |
| API routes | `api.md` | Route map, auth boundaries, error shape |
| DB / ORM / repos | `data.md` | Schema overview, repo pattern, migrations |
| Auth / sessions | `auth.md` | Flow in prose, where tokens live |
| UI / components | `frontend.md` | Server vs client split, shared primitives |
| Jobs / workers | `background.md` | Triggers, queues, env requirements |

---

## Doc template

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

---

## Documentation rules (required for every generated file)

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

---

## Wire into the harness

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

**Next:** `step-5-mcp.md`
