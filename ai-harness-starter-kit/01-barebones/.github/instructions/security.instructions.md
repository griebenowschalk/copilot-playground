---
applyTo: "**"
---
<!-- Loads EVERYWHERE (glob **). Copilot: always. Claude: when a task touches input/secrets. -->
# Security Rules
- Validate all external input before use. Never log secrets/PII. Read secrets from env.
