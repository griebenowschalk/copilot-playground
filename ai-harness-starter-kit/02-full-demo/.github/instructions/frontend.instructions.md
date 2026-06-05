---
applyTo: "src/components/**/*.tsx,src/app/**/*.tsx"
---
# Frontend Rules
- Server Components by default. Add "use client" only for state, effects, or
  browser APIs.
- Styling: Tailwind utility classes only. No inline styles, no CSS modules.
- Every component exports a typed `Props` interface (no `any`).
- Named exports; file name matches the component in PascalCase.
- Co-locate tests as `ComponentName.test.tsx`.
- Fetch data in Server Components/services; Client Components call `/api/*`.
