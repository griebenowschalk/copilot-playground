# Running the harness on large codebases, monorepos & across sessions

Optional layer — **load on demand, not every phase.** Read this for a **large repo or monorepo**, when a run's context window fills before Step 6, or any time you want to **pause the rollout and resume later**. Small/medium repos can run all phases in one session and skip this.

---

## Why a single run can still hit the context limit

Even with subagent discovery (Operating rule 11) and bounded `/init` scope (`step-1-claude.md`), a full Phase 0→6 run **accumulates** context: each phase adds a draft, a review, and an approval exchange on top of the last. On a large repo that sum can exhaust the window mid-run.

The fix is not a bigger window — it's **resetting context at phase boundaries**.

## Artifacts are the checkpoint

Every phase ends by **writing a file to disk** and stopping at an approval gate. Those files are the state:

| Phase | Artifact on disk |
|-------|------------------|
| 1 | `CLAUDE.md` |
| 2 | `AGENTS.md` |
| 3 | `.claude/settings.json`, `.claude/hooks/*`, `.claude/agents/*` |
| 4 | `docs/context/*.md` |
| 5 | `.mcp.json`, `.env.example` |
| 6 | `.claude/skills/*/SKILL.md` |

Nothing essential lives only in the conversation, so you can stop at any phase gate and resume later. A small **progress file** (below) records where you stopped; `CLAUDE.md` from Phase 1 doubles as the persisted discovery output, so a resumed session reuses it instead of re-scanning.

## Resume state: `guide/.harness-progress.md`

The whole resume mechanism is one small ledger — no hooks, nothing to install, works in any repo. The facilitator **creates it at Phase 0–1 and updates it at every gate** (Operating rule 12). It is **transient**: it stays **out of version control** (`guide/.gitignore` already ignores it) and is **deleted once Phase 6 is approved**.

```markdown
# AI harness rollout — progress (transient · gitignored · delete when complete)

Next: Phase 3 — Guardrails (guide/step-3-claude-folder.md)
Mode: AI-DLC · Graphify: enabled|skipped · Updated: <date>

## Phases
- [x] 0 Kickoff
- [x] 1 Init        → CLAUDE.md
- [x] 2 Baseline    → AGENTS.md
- [ ] 3 Guardrails  → .claude/settings.json, .claude/hooks/*, .claude/agents/*
- [ ] 4 Context     → docs/context/*.md
- [ ] 5 MCP         → .mcp.json
- [ ] 6 Skills      → .claude/skills/*/SKILL.md

## Discovery source (do NOT re-scan)
CLAUDE.md  (+ graphify-out/ if Graphify enabled)

## Deferred decisions / notes for next session
- <e.g. hooks: human to decide Stop test gate; monorepo packages pending: api, web>
```

Because the ledger is refreshed at every gate, a crash, an auto-compaction, or simply closing the session never costs more than the phase in progress — the next session picks up from the last approved gate.

## Resuming a rollout

Open a new conversation in the repo and either say *"Continue the harness rollout — read `guide/.harness-progress.md`"*, or paste:

```
Continue the AI harness rollout using guide/HARNESS_SETUP_GUIDE.md (hub) and
guide/.harness-progress.md for state. Do NOT re-run discovery — reuse CLAUDE.md and
written artifacts as the source. Load the hub + the next step file only. Resume at
the next unchecked phase; pause at its checkpoint.
```

Confirm the ledger's listed artifacts actually exist before continuing; if one is missing or unapproved, redo that phase rather than building on a gap. When Phase 6 is approved, **delete `guide/.harness-progress.md`** — the rollout is complete.

## When to split the run across sessions

| Situation | How to run |
|-----------|------------|
| Small / medium repo | One session, all phases — default |
| Large repo, or context > ~50% before Step 6 | New session per phase (or per small group), resuming at each gate |
| Monorepo | Root baseline once (Phases 1–3), then onboard packages incrementally (Phases 4 & 6 per package), each in its own session |

**Hard rule: only split at a phase gate** — artifact written *and* approved, ledger updated. Never split mid-phase; mid-phase work lives in the conversation and is lost on reset.

Heaviest phases, and so the best split points to stop after: **Phase 1** (discovery) and **Phase 4** (reads source per domain). Phases 2, 3, and 5 are light.

## Monorepo scoping

- **Layout:** root `AGENTS.md` + root `CLAUDE.md` are the shared baseline (stack-wide rules, commands). Add **per-package** `CLAUDE.md` / `AGENTS.md` / context docs only where a package genuinely diverges. Claude Code loads the root file plus the working directory's file, so per-package files layer on top of the baseline rather than replacing it.
- **Discovery is per package, never whole-tree** — onboard one package at a time, bounded (Operating rule 11). A package you never touch needs no context doc or skill.
- **Phases 4 and 6 scale worst** — context docs and skills multiply per package. Generate them for the **active** package only, on demand, not for every package up front.
- **Order:** finish the root baseline (Phases 1–3) first; then treat each package as a mini Phase 4 / Phase 6 pass in its own session.

---

**Back to:** `HARNESS_SETUP_GUIDE.md` (hub) · `step-1-claude.md` (discovery scoping)
