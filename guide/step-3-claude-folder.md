# Step 3: Set up the `.claude` folder

**Phase 3 · AI-DLC checkpoints in §3.1 (hooks) and §3.3 (subagents)**

Create a `.claude/` directory at your repo root for Claude Code–specific configuration. Commit `.claude/settings.json` so the team shares the same guardrails; keep personal overrides in `.claude/settings.local.json` (gitignored).

> **Copilot parity note for this step.** All three concerns in this step now have a
> Copilot counterpart:
> - **Hooks** (§3.1–§3.2) — VS Code Copilot reads the **same `.claude/settings.json` `hooks`
>   block** (Preview), so one definition serves both tools. See §3.4.
> - **Permissions** (§3.1) — Copilot uses VS Code's `chat.tools.*` auto-approve settings in
>   `.vscode/settings.json` rather than Claude's `permissions` block. See §3.4.
> - **Subagents** (§3.3) — mirrored by custom **chat modes**. See §3.3.

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
> Stop. **If the Phase 0 policy questionnaire already captured hooks and permissions, apply those answers — don't re-ask.** Otherwise ask which hooks to enable (PostToolUse lint, Stop test gate, permission denies). If the human defers, apply minimal PostToolUse lint + standard permission denies; omit Stop unless they opt in.

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

Because VS Code Copilot reads the same `.claude/settings.json` `hooks` block (§3.4), it
picks up this merged PreToolUse hook too — though it **ignores the matcher** and runs the
hook on every tool call (Preview limitation). The Graphify section in `AGENTS.md` and
`copilot-instructions.md`, plus the `graphify` skill (`.claude/skills/graphify/`, available
directly as `/graphify` in Copilot Chat), remain the primary, version-agnostic nudge for
Copilot.

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

### Copilot parity — chat modes (`.github/chatmodes/`)

GitHub Copilot's equivalent of a subagent is a **custom chat mode**:
`.github/chatmodes/<name>.chatmode.md`. Like a subagent it has its own system prompt,
tool set, and (optionally) model, and the user selects it from the chat-mode picker. Mirror
each subagent with a chat mode so both tools get the same specialist:

```markdown
---
description: One line — what it does AND when to use it (shown in the mode picker).
tools: ['codebase', 'search', 'fetch']
model: GPT-4.1
---
System prompt: role, workflow, output format, and any hard "do not" rules
(e.g. "read-only — do not edit files").
```

| Field | Notes |
|-------|-------|
| `description` | Shown in the chat-mode picker — be specific about *when* to use it |
| `tools` | The tool set the mode may use — keep read-only modes free of edit/run tools |
| `model` | Optional override |

When the human opts into Copilot parity, install the **`docs-explorer` chat mode**
alongside the subagent. A ready-to-copy template lives at
[`chatmodes/docs-explorer.chatmode.md`](chatmodes/docs-explorer.chatmode.md) — copy it to
`.github/chatmodes/docs-explorer.chatmode.md`. The matching "use it instead of guessing"
rule lives in `.github/copilot-instructions.md` and `AGENTS.md`, the same way the
subagent rule lives in `CLAUDE.md`.

> **AI-DLC checkpoint — Phase 3 (subagents)**
> Stop. **If the Phase 0 questionnaire already answered the subagent set, apply it and skip ahead.** Otherwise ask: **which subagents should this repo have?** Offer any existing `.claude/agents/*.md` files as a baseline, and propose `docs-explorer` as the default if the human has no other candidates in mind. If the human defers, install `docs-explorer` only. For each subagent, also produce the matching **Copilot chat mode** (`.github/chatmodes/*.chatmode.md`) when Copilot parity is in scope. Show the draft agent file(s), chat-mode file(s), and `CLAUDE.md` Subagents section for approval before writing.

---

## 3.4 Copilot parity — permissions & hooks

Hooks and permissions used to be Claude-only. They no longer are — but the two map to
Copilot **differently**, so handle them separately. Only emit these when Copilot parity is
in scope (Phase 0 questionnaire).

### Hooks — shared, no duplication

VS Code Copilot (Preview) **parses the `.claude/settings.json` `hooks` block directly**, so
the hooks you wrote in §3.1–§3.2 already serve Copilot. Do **not** rewrite them — one
definition, both tools. Known Preview caveats to flag for the team:

| Difference | Impact |
|------------|--------|
| **Matchers are ignored** | A hook scoped to `"Edit\|Write"` runs on **every** tool call in Copilot. Keep hook scripts cheap and idempotent, or branch inside the script on the tool name from the event JSON. |
| **Property casing** | Claude uses snake_case; VS Code uses camelCase. The shared `type`/`command`/`timeout` keys work in both. |
| **Tool names differ** | If a script inspects the tool name, handle both vocabularies. |
| **Preview** | Requires a recent VS Code + Copilot. Treat as additive, not a hard guarantee. |

If you prefer to keep Copilot's hooks out of the Claude file, VS Code also auto-loads
`.github/hooks/*.json` (same JSON shape) — but that duplicates config, so default to the
shared `.claude/settings.json`.

### Permissions — `.vscode/settings.json` auto-approve

Copilot does **not** read Claude's `permissions` block. Its equivalent is VS Code's
**terminal/tool auto-approval** in `.vscode/settings.json` — a regex-keyed map where `true`
auto-approves and `false` denies (anything unmatched falls back to the normal confirmation
prompt). Mirror the same allow/deny intent as the `permissions` block in §3.1:

```jsonc
// .vscode/settings.json — commit this so the team shares the same guardrails
{
  "chat.tools.terminal.autoApprove": {
    "/^git\\s+(status|diff|log|show|add|commit)\\b/": true,
    "/^npm\\s+(test|run\\s+(lint|build))\\b/": true,
    "rm": false,
    "rmdir": false,
    "del": false,
    "/\\.env\\b/": false
  }
}
```

| VS Code setting | Mirrors Claude… | Notes |
|-----------------|-----------------|-------|
| `chat.tools.terminal.autoApprove` | `permissions.allow` / `deny` for `Bash(...)` | Regex keys in `/…/`; `true` allow, `false` deny |
| `chat.tools.edits.autoApprove` | `permissions.allow` for `Edit`/`Write` | Glob-based edit approval |
| `chat.agent.networkFilter` | *(no direct Claude analog)* | Restricts which domains agent tools may reach (often org-managed) |

`.env` protection: Claude denies the **Read tool** on `./.env*` via `permissions`; on the
Copilot side the shared `.claude/settings.json` PreToolUse hook applies, and the
`autoApprove` deny above blocks `cat .env`-style terminal reads. The file stays gitignored
regardless (Step 5).

> **AI-DLC checkpoint — Phase 3 (Copilot parity)**
> Only if Copilot parity is in scope. Confirm the `.vscode/settings.json` auto-approve map
> mirrors the same allow/deny intent as the §3.1 `permissions` block — don't invent new
> rules. State plainly that hooks are **reused** from `.claude/settings.json` (Preview,
> matchers ignored), so no second hooks file is written. Show the draft `.vscode/settings.json`
> for approval before writing.

**Next:** `step-4-context-docs.md`
