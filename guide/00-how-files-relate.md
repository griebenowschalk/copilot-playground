# How the two files relate

| File | Who reads it | When |
|------|-------------|------|
| `AGENTS.md` | All AI tools (Copilot, Claude, any agent) | Every request — keep it short |
| `CLAUDE.md` | Claude Code only | Every session — Claude-specific memory & rule routing |

`AGENTS.md` is the shared baseline: stack, commands, architecture, and hard rules every tool needs on every request. `CLAUDE.md` builds on top of it with Claude-specific behavior — primarily a routing table that tells Claude which scoped rule file to read on demand based on the task.

**Creation order (setup):** optionally build the graph (`step-0.5-graphify.md`), then create `CLAUDE.md` from that output or from `/init`, then `AGENTS.md` distilled from Phase 1 plus team policy.

**Load order (runtime):** unchanged — Copilot reads `AGENTS.md` every request; Claude reads `AGENTS.md` first, then uses `CLAUDE.md` routing.
