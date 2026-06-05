---
name: figma
description: Build or update a component from a selected Figma frame using the Figma MCP and this repo's frontend conventions. Use when turning a design into code.
allowed-tools: Read, Edit, Write, Bash
---
# /figma — design-to-code

Goal: turn a Figma frame into a component that follows our conventions.

## Steps
1. Read `.github/instructions/frontend.instructions.md` (component rules) and
   `.github/instructions/security.instructions.md`.
2. If a Figma URL/key is provided, run the bundled context script to pull design
   data (it reads `FIGMA_API_KEY` from the environment):
   `bash .claude/skills/figma/scripts/fetch-context.sh "$FILE_KEY" "$NODE_ID"`
   Otherwise use the Figma MCP tools directly on the current selection.
3. Generate a component under `src/components/`:
   - Server Component unless interactivity is required ("use client").
   - Tailwind utility classes only; map Figma variables to Tailwind tokens.
   - Named export, explicit `Props` interface, co-located `*.test.tsx`.
4. Run `pnpm lint` and `pnpm test`.

## Notes
This skill is portable: auth lives in MCP/env, not in the skill. The Copilot
equivalent is `.github/prompts/figma.prompt.md`.
