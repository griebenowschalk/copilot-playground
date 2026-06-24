---
name: figma-to-code
description: >-
  Build or update UI from a Figma design — use when asked to implement a Figma
  frame/component/selection, "turn this design into code", match a mockup, or sync a
  component to its latest design. Pulls design context via the figma MCP server, maps it
  to existing components first, then implements following the frontend conventions.
  Requires the figma MCP server (.mcp.json / .vscode/mcp.json) and FIGMA_API_KEY.
when_to_use: >-
  "Implement this Figma frame", "build the design at <figma-url>", "match this mockup",
  "the design changed — update <Component>", design-handoff or pixel-parity work.
allowed-tools: Read, Grep, Glob
---
<!-- Task skill — auto-routes on Figma/design-to-code requests. Pairs with the figma MCP server; visible to Copilot Chat directly (no separate prompt file). For very large frames, set `context: fork` + `agent` in the frontmatter so the heavy MCP payload stays out of the main window. -->

## Gate

If the **figma MCP server is not connected** (`/mcp` shows no `figma`, or `FIGMA_API_KEY`
is unset), stop and say so — do not guess pixel values from a screenshot. Otherwise:

## Workflow

1. **Get the design context — narrowly.** Use the connected figma MCP tools to read the
   **specific node** (frame/component/selection), not the whole file. Figma payloads are
   large — request only the target node and the depth you need (layers, auto-layout, fills,
   text, spacing, the variables/tokens it references). Prefer the current Figma selection or
   a node-scoped URL over a file-wide dump.
2. **Map to what already exists — reuse before create.** Before writing anything, search the
   codebase for components, design tokens, and primitives that already cover the design:
   - `Grep`/`Glob` for component names suggested by the frame's layer names.
   - Check the design-system / UI primitives directory and the token source (theme file,
     CSS variables, Tailwind config) for existing spacing/color/typography scales.
   - Produce a short **mapping**: each Figma layer → an existing component to reuse, an
     existing one to extend, or a genuinely new component (justify why nothing fits).
3. **Implement following the codebase, not the export.** Build/extend per
   `frontend.instructions.md` and any `<framework>-best-practices` skill. Translate Figma
   values to the **codebase's tokens** (theme variable / utility class), never hard-coded
   hex/px when a token exists. Compose existing components; add new ones only per the mapping.
4. **Match, then verify.** Wire props/variants to the design's variants. Check responsive
   rules and states (hover/disabled/empty) the frame defines. Reconcile against the design;
   note any deviation you made and why.

## Hard rules

- **Reuse first.** A new component is the exception, justified in the mapping — not the default.
- **Tokens over literals.** Map Figma styles to existing theme tokens / utility classes.
- **Stay version-aware.** For framework/styling specifics, reach for `docs-explorer` /
  context7 rather than guessing.
- **Read narrowly.** Never pull an entire Figma file when one node will do.

## Output

Lead with the **layer → component mapping** (reuse / extend / new + reason), then the
implementation. Call out any pixel/token deviations and unresolved design questions.
