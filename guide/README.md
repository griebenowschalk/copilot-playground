# Harness setup guide

All harness rollout documentation lives in this folder. Copy the whole **`guide/`** directory into a target repo (or reference it from copilot-playground) when running manual setup or AI-DLC.

| File | Purpose |
|------|---------|
| **`HARNESS_SETUP_GUIDE.md`** | **Start here** — hub, AI-DLC runbook, example prompt |
| `GRAPHIFY_GUIDE.md` | Graphify daily reference (optional) |
| `README.md` | This index |
| `00-how-files-relate.md` | AGENTS.md vs CLAUDE.md |
| `step-0.5-graphify.md` | Optional Graphify harness integration |
| `step-1-claude.md` | Initialize `CLAUDE.md` |
| `step-2-agents.md` | Set up `AGENTS.md` |
| `step-3-claude-folder.md` | `.claude/` hooks and permissions |
| `step-4-context-docs.md` | `docs/context/` reference docs |

## Step order

| Order | Phase | Step file | Creates / updates |
|-------|-------|-----------|-------------------|
| — | Background | `00-how-files-relate.md` | *(read first — no files)* |
| 0.5 *(optional)* | Graph | `step-0.5-graphify.md` | `.graphifyignore`, graph outputs, Graphify harness files |
| 1 | Init | `step-1-claude.md` | `CLAUDE.md` |
| 2 | Baseline | `step-2-agents.md` | `AGENTS.md` |
| 3 | Guardrails | `step-3-claude-folder.md` | `.claude/settings.json`, hook scripts |
| 4 | Context | `step-4-context-docs.md` | `docs/context/*.md`, routing rows |

**AI-DLC:** load `HARNESS_SETUP_GUIDE.md` plus **only the current step file** for the active phase.
