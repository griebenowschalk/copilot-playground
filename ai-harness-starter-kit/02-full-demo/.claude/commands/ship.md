---
description: Pre-commit gate — lint, typecheck, test, then summarize the change
---
Run `pnpm lint`, `pnpm typecheck`, and `pnpm test`. If all pass, summarize the
staged change in 2-3 bullets and propose a conventional-commit message. If
anything fails, stop and report what to fix. Do not commit automatically.
