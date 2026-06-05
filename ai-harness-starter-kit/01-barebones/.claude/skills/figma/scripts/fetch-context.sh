#!/usr/bin/env bash
# Demonstrates a skill-bundled script that injects context: reads the API key
# from env and fetches design data from the Figma REST API.
# Usage: fetch-context.sh <FILE_KEY> [NODE_ID]
set -euo pipefail
: "${FIGMA_API_KEY:?Set FIGMA_API_KEY in your environment}"
FILE_KEY="${1:?Provide a Figma file key}"; NODE_ID="${2:-}"
URL="https://api.figma.com/v1/files/$FILE_KEY"; [ -n "$NODE_ID" ] && URL+="/nodes?ids=$NODE_ID"
curl -sS -H "X-Figma-Token: $FIGMA_API_KEY" "$URL"
