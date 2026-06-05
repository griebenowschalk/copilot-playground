---
applyTo: "src/app/api/**"
---
# API / Route Handler Rules
- Validate the body/params with Zod at the top of the handler.
- No business logic in handlers — delegate to `src/services/`.
- Return typed JSON with correct status codes (400/401/403/404/409/500).
- Error body shape: `{ error: { code: string, message: string } }`.
- Never leak internal error details or stack traces to the client.
