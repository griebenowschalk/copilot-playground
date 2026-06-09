#!/usr/bin/env bash
# Reset the AI harness in a target repo: removes generated harness artifacts and
# leaves application code untouched. Run it from anywhere — pass the target dir.
#
# Usage:   reset-harness.sh <target-dir> [--dry-run] [-y|--yes]
# Example: ./guide/scripts/reset-harness.sh ai-harness-starter-kit/03-dummy-project
#
# --dry-run  list what would be removed, delete nothing
# -y|--yes   skip the confirmation prompt (for scripted use)
set -euo pipefail

usage() { echo "usage: reset-harness.sh <target-dir> [--dry-run] [-y|--yes]"; }

DRY_RUN=0
ASSUME_YES=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -y|--yes)  ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
    *)         TARGET="$arg" ;;
  esac
done

[[ -n "$TARGET" ]] || { echo "error: no target directory given" >&2; usage >&2; exit 2; }
[[ -d "$TARGET" ]] || { echo "error: not a directory: $TARGET" >&2; exit 1; }
ROOT="$(cd "$TARGET" && pwd)"
cd "$ROOT"

echo "Harness reset target: $ROOT"
[[ $DRY_RUN == 1 ]] && echo "(dry run — nothing will be deleted)"
if [[ $ASSUME_YES == 0 && $DRY_RUN == 0 ]]; then
  read -r -p "Remove harness artifacts from this folder? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "aborted."; exit 0; }
fi

remove() {
  if [[ -e "$1" || -L "$1" ]]; then
    if [[ $DRY_RUN == 1 ]]; then
      echo "would remove $1"
    else
      rm -rf "$1"
      echo "removed $1"
    fi
  fi
}

# Root — entry files + learn/demo docs (Steps 1–2)
remove AGENTS.md
remove CLAUDE.md
remove DEMO.md
remove LEARN.md

# Step 5 MCP — Claude servers (guide/step-5-mcp.md)
remove .mcp.json
remove .env   # may contain FIGMA_API_KEY; run `pnpm setup` to restore app .env

# .github/ — instructions, prompts, copilot-instructions.md, chatmodes
remove .github

# .vscode/ — Copilot MCP, settings, extensions
remove .vscode

# .claude/ — settings, hooks, commands, skills, agents, memory.jsonl (memory MCP)
remove .claude/memory.jsonl
remove .claude

# docs/ — context docs (Step 4)
remove docs

# Graphify — knowledge graph output and ignore file (Step 0.5)
remove graphify-out
remove .graphifyignore

# Per-run ledger (large-codebases.md) — gitignored, lives under guide/ inside the target
remove guide/.harness-progress.md

# Restore app files the harness may have modified (e.g. FIGMA_API_KEY in .env.example,
# memory.jsonl in .gitignore) — only when the target is a git work tree.
if [[ $DRY_RUN == 0 ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git checkout -- .env.example .gitignore 2>/dev/null || true
  echo "restored .env.example and .gitignore from git (if changed)"
fi

echo "Harness reset complete — app code untouched."
echo "If you removed .env, run: pnpm setup"
