---
applyTo: "**/*.test.ts,**/*.test.tsx,**/*.spec.ts"
---
# Testing Rules
- Use Vitest + Testing Library. Top-level `describe` per unit.
- Test behavior and edge cases, not implementation details.
- Mock network and DB; never hit real APIs or production data.
- Cover unhappy paths: invalid input, error states, empty lists.
