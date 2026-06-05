---
applyTo: "**"
---
# Security Rules (apply to all files)
- Never log secrets, tokens, passwords, or PII.
- Validate ALL external input with Zod (`src/lib/validation.ts`) before use.
- Use Prisma's parameterized queries only — never raw string-built SQL.
- Authorize server-side; never trust client-provided roles or IDs.
- Do not add new dependencies without flagging them for review.
- Read secrets from env (`.env`), never hardcode. `.env` is gitignored.
