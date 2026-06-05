---
name: review
description: Review changed code for bugs, security issues, typing, and missing tests.
allowed-tools: Read, Grep, Bash
---
<!-- Claude skill. Invoke with /review. Mirrors .github/prompts/review.prompt.md. -->
Read security + testing rules, review the git diff, cite file:line + fixes, end PASS / CHANGES.
