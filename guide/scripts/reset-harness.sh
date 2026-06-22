#!/usr/bin/env bash
# Reset the AI harness in a target repo: removes or restores harness artifacts and
# leaves application code untouched. Run it from anywhere — pass the target dir.
#
# For each harness artifact:
#   • git-tracked path  → restore to HEAD (removes harness additions, keeps original content)
#   • untracked path    → delete (it was new — the harness created it)
# Falls back to delete-only when the target is not a git work tree.
#
# Usage:   reset-harness.sh <target-dir> [--dry-run] [-y|--yes]
# Example: ./guide/scripts/reset-harness.sh ai-harness-starter-kit/03-dummy-project
#
# --dry-run  list what would be removed/restored, change nothing
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

# Detect git work tree once — used by smart_remove to choose restore vs delete
IN_GIT=0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && IN_GIT=1

echo "Harness reset target: $ROOT"
[[ $DRY_RUN == 1 ]] && echo "(dry run — nothing will be changed)"
if [[ $ASSUME_YES == 0 && $DRY_RUN == 0 ]]; then
  read -r -p "Reset harness artifacts in this folder? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "aborted."; exit 0; }
fi

# smart_remove <path>
#   git-tracked → rm -rf then git checkout -- (restores pre-harness content, drops additions)
#   untracked   → rm -rf (it was created by the harness)
#   missing     → no-op
smart_remove() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0  # nothing to do

  if [[ $IN_GIT == 1 ]]; then
    local tracked
    tracked=$(git ls-files -- "$path" 2>/dev/null | head -1)
    if [[ -n "$tracked" ]]; then
      if [[ $DRY_RUN == 1 ]]; then
        echo "would restore  $path  (git-tracked — revert to HEAD)"
      else
        rm -rf "$path"
        git checkout -- "$path" 2>/dev/null || true
        echo "restored  $path  (HEAD)"
      fi
      return 0
    fi
  fi

  # Not git-tracked (or not in a git repo) — the harness created this; delete it
  if [[ $DRY_RUN == 1 ]]; then
    echo "would remove   $path  (new — not in git)"
  else
    rm -rf "$path"
    echo "removed   $path"
  fi
}

# strip_readme_graphify <readme>
#   Removes the "## Codebase graph (Graphify — optional)" section (heading through
#   the line before the next ## / # heading, or EOF) from an app-owned README.
#   The file is edited in place — never deleted or reverted wholesale.
strip_readme_graphify() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  grep -qE '^## Codebase graph \(Graphify' "$f" || return 0
  if [[ $DRY_RUN == 1 ]]; then
    echo "would edit     $f  (remove Graphify section)"
    return 0
  fi
  local tmp; tmp="$(mktemp)"
  awk '
    /^## Codebase graph \(Graphify/ { skip=1; next }
    skip && /^#{1,2} /            { skip=0 }
    !skip                         { print }
  ' "$f" > "$tmp" && mv "$tmp" "$f"
  echo "edited    $f  (removed Graphify section)"
}

# strip_pkg_script <script-name>
#   Removes a single entry from package.json "scripts". package.json is app-owned,
#   so it is edited in place (not deleted/reverted). Uses node for correct JSON
#   handling — warns to remove manually if node is unavailable.
strip_pkg_script() {
  local name="$1" f="package.json"
  [[ -f "$f" ]] || return 0
  grep -q "\"$name\"" "$f" || return 0
  if [[ $DRY_RUN == 1 ]]; then
    echo "would edit     $f  (remove scripts.$name)"
    return 0
  fi
  if command -v node >/dev/null 2>&1; then
    node -e '
      const fs=require("fs"), p="package.json", n=process.argv[1];
      const j=JSON.parse(fs.readFileSync(p,"utf8"));
      if (j.scripts && n in j.scripts) {
        delete j.scripts[n];
        fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
      }
    ' "$name"
    echo "edited    $f  (removed scripts.$name)"
  else
    echo "WARNING: node not found — remove the \"$name\" entry from $f manually."
  fi
}

# Root — entry files (Steps 1–2)
smart_remove AGENTS.md
smart_remove CLAUDE.md
smart_remove DEMO.md
smart_remove LEARN.md

# Step 5 MCP
smart_remove .mcp.json

# App files the harness may have modified — restore if tracked, skip if unchanged
smart_remove .gitignore

# .github/ — copilot-instructions.md, instructions/, chatmodes/, prompts/
smart_remove .github

# .vscode/ — mcp.json, settings.json
smart_remove .vscode

# .claude/ — settings.json, hooks/, commands/, skills/, agents/
smart_remove .claude/memory.jsonl   # gitignored; delete before the dir sweep below
smart_remove .claude

# docs/ — context docs (Step 4)
smart_remove docs

# Graphify — graph output and ignore file (Step 0.5)
smart_remove graphify-out
smart_remove .graphifyignore
smart_remove .copilotignore

# Graphify — per-clone setup script (Step 0.5 §0.5.4). Single new file added by
# the harness; scripts/ itself is app code and is left alone.
smart_remove scripts/graphify-setup.sh

# Graphify — partial edits to app-owned files. README.md and package.json are NOT
# harness-owned, so the harness additions are stripped in place, not removed.
strip_readme_graphify README.md
strip_pkg_script graphify:setup

# Per-run ledger — gitignored under guide/ inside the target
smart_remove guide/.harness-progress.md

echo "Harness reset complete — app code untouched."
