# Step 3: Set up the `.claude` folder

**Phase 3 · AI-DLC checkpoint in §3.1**

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

**Next:** `step-4-context-docs.md`
