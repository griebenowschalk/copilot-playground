# Live Demo Script (≈10 minutes)

A sequence for showing the harness to a team lead. Open
`docs/harness-explorer.html` alongside this for the visuals.

## 0. Setup (once, before the demo)
```bash
pnpm install && pnpm setup && pnpm dev
```
Open http://localhost:3000 — a tasks app. Add/toggle a few tasks.

---

## 1. Same rules, both tools (the core point)
Open `src/components/TaskList.tsx`.

**Copilot:** ask in Copilot Chat (Agent mode):
> "Add a priority field (low/med/high) to tasks."

Watch the response **References** list — it should cite
`frontend.instructions.md` (open file matched the `applyTo` glob). It will also
respect the architecture: changes flow through the repository + service layers.

**Claude Code:** in the same repo run:
> "Add a priority field (low/med/high) to tasks."

Claude reads `CLAUDE.md`, consults the routing table, and Reads
`frontend.instructions.md` + `database.instructions.md` + `api.instructions.md`
on its own — *because the task spans those areas*, not because a file is open.
That is the "agent-requested" behavior Copilot can't do.

---

## 2. Manual commands / skills
- **Copilot:** type `/review` in chat → runs `.github/prompts/review.prompt.md`.
- **Claude Code:** type `/review` → runs `.claude/skills/review/SKILL.md`.
Stage a sloppy change first (e.g. add `catch (e: any)`) and watch both flag it.

---

## 3. Skills with scripts (Claude-only superpower)
In Claude Code:
> "/figma — build a card component from frame <FILE_KEY>/<NODE_ID>"

The `/figma` skill reads frontend rules, then runs its bundled
`scripts/fetch-context.sh`, which pulls design data using `FIGMA_API_KEY` from
your env. Copilot's `/figma` prompt does the same via the Figma MCP, but cannot
run a setup script itself — auth lives in `.vscode/mcp.json` instead.

> Talking point: the API-key handling moved OUT of a bespoke command and INTO
> the MCP/env layer, so the workflow is portable across both tools.

---

## 4. Subagents & hooks (Claude)
- `code-reviewer` subagent: a read-only reviewer with restricted tools.
- The PostToolUse hook in `.claude/settings.json` auto-runs `pnpm lint --fix`
  after every edit — show an edit cleaning itself up.

---

## 4b. Graphify — query instead of paste (≈2 min)
Build the graph once: `graphify extract .` (from the project root).

**Claude Code:**
```
/graphify query "how do tasks flow from the API route to the database?"
```

**Copilot Chat:** type `/graphify`, then ask the same question. Copilot reads
`GRAPH_REPORT.md` and runs `graphify query` via terminal instead of opening four files.

Both get the layer chain (route → service → repo → Prisma) from the graph —
~80 tokens — instead of pasting or reading ~600+ tokens of source.

Compare: ask the same question **without** Graphify and watch multiple files get read.

Rebuild after structural changes: `graphify update .`. Daily reference:
[`GRAPHIFY_GUIDE.md`](../../GRAPHIFY_GUIDE.md).

---

## 5. Guardrails
Open `.claude/settings.json` (permissions deny reading `.env`, deny `rm -rf`)
and `security.instructions.md` (`applyTo: "**"` — loads everywhere).

## Cheat sheet: where each Cursor feature went
| Cursor | Here |
|---|---|
| `.cursorrules` (always) | `AGENTS.md` + `copilot-instructions.md` + `CLAUDE.md` |
| auto-attached rules (glob) | `.github/instructions/*` via `applyTo` (Copilot) / router (Claude) |
| agent-requested rules | `CLAUDE.md` routing table (Claude) |
| manual `@rule` | `.github/prompts/*` (Copilot) / `.claude/skills/*` (Claude) |
| skills + scripts | `.claude/skills/<name>/SKILL.md` (+ `scripts/`) |
| MCP + API keys | `.mcp.json` / `.vscode/mcp.json` with env/inputs |
| hooks | `.claude/settings.json` |
