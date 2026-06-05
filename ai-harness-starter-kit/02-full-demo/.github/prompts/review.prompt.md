---
mode: agent
description: Review changed code before committing
---
Review the current diff. For each issue, give file:line and a concrete fix.
Check: input validation and secrets (security.instructions.md), typed errors,
DB access only via src/db/repos, and test coverage. Would this pass `pnpm lint`?
End with PASS / CHANGES-NEEDED.
