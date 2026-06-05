---
name: review
description: Review changed code for bugs, security issues, typing, and missing tests before committing.
allowed-tools: Read, Grep, Bash
---
# /review
1. Read the security and testing instruction files for the areas the diff touches.
2. Run `git diff` to see changed files.
3. For each issue, cite file:line and a concrete fix. Check input validation,
   secret handling, typed errors, repository-layer usage, and test coverage.
4. Run `pnpm lint` and `pnpm test`.
5. End with a PASS / CHANGES-NEEDED verdict.
