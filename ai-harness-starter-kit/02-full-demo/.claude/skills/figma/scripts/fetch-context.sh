#!/usr/bin/env bash
# Demonstrates dynamic context injection: a skill-bundled script that reads the
# API key from the environment and fetches design context from the Figma REST API.
# Usage: fetch-context.sh <FILE_KEY> [NODE_ID]
set -euo pipefail

: "${FIGMA_API_KEY:?Set FIGMA_API_KEY in your environment (.env)}"
FILE_KEY="${1:?Provide a Figma file key}"
NODE_ID="${2:-}"

BASE="https://api.figma.com/v1"
if [ -n "$NODE_ID" ]; then
  URL="$BASE/files/$FILE_KEY/nodes?ids=$NODE_ID"
else
  URL="$BASE/files/$FILE_KEY"
fi

curl -sS -H "X-Figma-Token: $FIGMA_API_KEY" "$URL"
