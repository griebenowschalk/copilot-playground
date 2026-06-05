---
name: scaffold-component
description: Scaffold a new React component that follows this repo's frontend conventions, with a co-located test.
allowed-tools: Read, Write, Edit, Bash
---
# /scaffold-component
1. Read `.github/instructions/frontend.instructions.md`.
2. Ask for (or infer) the component name and whether it needs interactivity.
3. Create `src/components/<Name>.tsx`: Server Component unless interactive,
   Tailwind only, named export, explicit `Props` interface.
4. Create `src/components/<Name>.test.tsx` with a render test.
5. Run `pnpm test`.
