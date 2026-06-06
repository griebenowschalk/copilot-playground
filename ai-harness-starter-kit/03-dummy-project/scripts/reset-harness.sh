#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

remove() {
  if [[ -e "$1" || -L "$1" ]]; then
    rm -rf "$1"
    echo "removed $1"
  fi
}

# Root — see ../01-barebones/LEARN.md file map
remove AGENTS.md
remove CLAUDE.md
remove .mcp.json
remove DEMO.md
remove LEARN.md

# .github/ — instructions, prompts, copilot-instructions.md
remove .github

# .vscode/ — Copilot MCP, settings, extensions (not in bare project)
remove .vscode

# .claude/ — settings, hooks, commands, skills, agents
remove .claude

# docs/ — context docs, harness-explorer, ARCHITECTURE.md
remove docs

# Restore app files harness may have modified (e.g. FIGMA_API_KEY in .env.example)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git checkout -- .env.example .gitignore 2>/dev/null || true
  echo "restored .env.example and .gitignore from git (if changed)"
fi

echo "Harness reset complete — app code untouched."
