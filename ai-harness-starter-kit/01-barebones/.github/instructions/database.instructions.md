---
applyTo: "prisma/**,src/db/**"
---
<!-- Scoped to the data layer. -->
# Database Rules
- All queries via repositories in src/db/repos. Soft-delete with deletedAt.
