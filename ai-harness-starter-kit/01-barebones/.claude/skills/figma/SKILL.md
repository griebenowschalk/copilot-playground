---
name: figma
description: Build a component from a Figma frame using the Figma MCP and our frontend conventions.
allowed-tools: Read, Edit, Write, Bash
---
<!-- Claude skill. Invoke with /figma. Skills can bundle scripts (see scripts/). -->
1. Read frontend.instructions.md.
2. Pull design context: `bash .claude/skills/figma/scripts/fetch-context.sh "$FILE_KEY" "$NODE_ID"`
   (the script reads FIGMA_API_KEY from env), or use the Figma MCP directly.
3. Build the component per frontend rules; map Figma variables to Tailwind tokens.
