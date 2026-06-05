---
applyTo: "prisma/**,src/db/**"
---
# Database Rules
- All queries go through repositories in `src/db/repos/`. Nothing else imports
  the Prisma client.
- Every schema change pairs with `pnpm db:push` (or a migration in prod).
- Soft-delete with `deletedAt`; filter `deletedAt: null` on reads.
- Wrap multi-write operations in a transaction.
- Repositories return plain typed records, not raw Prisma models.
