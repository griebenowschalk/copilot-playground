# Step 3: Set up the `.claude` folder

**Phase 3 · AI-DLC checkpoints in §3.1 (hooks) and §3.3 (subagents)**

Create a `.claude/` directory at your repo root for Claude Code–specific configuration. Commit `.claude/settings.json` so the team shares the same guardrails; keep personal overrides in `.claude/settings.local.json` (gitignored).

| Path | Purpose |
|------|---------|
| `.claude/settings.json` | Hooks, permissions, and other shared Claude settings |
| `.claude/settings.local.json` | Personal overrides (API keys, local paths) — do not commit |
| `.claude/skills/<name>/SKILL.md` | On-demand workflows (richer than legacy commands) |
| `.claude/commands/*.md` | Legacy slash commands (still work) |
| `.claude/agents/*.md` | Subagents with their own prompt and tool restrictions |
| `.claude/hooks/*` | Shell scripts invoked by hooks in `settings.json` |

---

## 3.1 Hooks in `.claude/settings.json`

Hooks are lifecycle callbacks — scripts or prompts that run at specific moments in a Claude Code session (before/after a tool call, when you submit a prompt, when Claude stops, etc.). Unlike instructions in `AGENTS.md`, hooks **enforce** behavior deterministically: they run every time the event fires, whether or not the model remembered the rule.

Configure them under the `hooks` key in `.claude/settings.json`. Each event (e.g. `PostToolUse`, `PreToolUse`, `Stop`) holds an array of **matcher groups**. A matcher group filters which tool calls trigger the hook; the inner `hooks` array lists one or more handlers to run.

Run `/hooks` inside Claude Code to inspect what's loaded and which settings file each hook came from.

### What makes a good production hook

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

### Example

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

## 3.2 Merge Graphify + harness hooks *(Graphify only)*

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

## 3.3 Subagents (`.claude/agents/`)

Subagents are specialist Claude instances defined in `.claude/agents/<name>.md`. Each runs in its own context window with its own system prompt, tool restrictions, and (optionally) model — keeping noisy or narrow work (doc lookups, test triage, code review) out of the main session's context.

### Anatomy of a subagent file

```markdown
---
name: kebab-case-name
description: One line — what it does AND when to use it. This is what Claude
  matches against to decide whether to delegate automatically.
tools: Tool, Another, mcp__server__tool
model: sonnet
---
System prompt: role, workflow, output format, and any hard "do not" rules
(e.g. "read-only — do not edit files").
```

| Field | Notes |
|-------|-------|
| `name` | kebab-case, matches the filename (e.g. `code-reviewer.md` → `name: code-reviewer`) |
| `description` | The single biggest lever for auto-routing — be specific about *when* to use it, not just *what* it does |
| `tools` | Restrict to the minimum the role needs (e.g. read-only review agents get `Read, Grep, Glob`, not `Edit`/`Bash`) |
| `model` | Optional override — pick a smaller/faster model for narrow, high-volume tasks |

### What makes a good subagent

| Principle | Why it matters |
|-----------|----------------|
| **Narrow and named for the job** | "code-reviewer", not "helper" — the description is a routing key, not a label |
| **Tool allowlist matches the role** | A reviewer that can't `Edit` can't accidentally rewrite the thing it's grading |
| **Self-contained system prompt** | The subagent starts cold with no conversation history — spell out workflow and output format |
| **Parallel-friendly** | Good candidates are tasks you'd otherwise run sequentially and discard the noise from (doc lookups, multi-file searches, test triage) |

### Default: `docs-explorer`

If the human doesn't name specific subagents to add, install **`docs-explorer`** — a documentation lookup specialist that fetches up-to-date library/framework docs (via the `context7` MCP server from Step 5, with web search as fallback) instead of guessing from training data.

A ready-to-copy template lives at [`agents/docs-explorer.md`](agents/docs-explorer.md) in this guide folder. Copy it to `.claude/agents/docs-explorer.md` — it uses `Skill`/`MCPSearch` so it resolves whichever MCP doc servers (e.g. `context7` from Step 5) are actually connected, rather than hardcoding tool names.

Add or extend the **Subagents** section in `CLAUDE.md` so Claude knows what's available without scanning the directory — and pair the entry with a hard rule that sends Claude to it, the same way Step 5 pairs MCP servers with "when to reach for" guidance:

```markdown
## Subagents (`.claude/agents/`)
- `docs-explorer` — fetches current library/framework docs via context7 + web search.

Whenever working with any third-party library or framework, you MUST look up
the official documentation for the version in use to ensure you're working with
up-to-date and correct information — use the `docs-explorer` subagent for
efficient, parallel documentation lookup rather than guessing from training data.
```

This pairing matters more than the subagent file itself: a `docs-explorer` agent that exists but is never invoked is dead weight. The rule is what makes Claude reach for it on every "how does `<library>` do X" task instead of guessing.

> **AI-DLC checkpoint — Phase 3 (subagents)**
> Stop. Ask: **which subagents should this repo have?** Offer any existing `.claude/agents/*.md` files as a baseline, and propose `docs-explorer` as the default if the human has no other candidates in mind. If the human defers, install `docs-explorer` only. Show the draft agent file(s) and `CLAUDE.md` Subagents section for approval before writing.

**Next:** `step-4-context-docs.md`
