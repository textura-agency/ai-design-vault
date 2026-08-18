---
paths:
  - "src/app/api/**"
  - "src/pages/api/**"
  - "src/routes/api/**"
  - "server/api/**"
  - "**/+server.ts"
  - "**/*.server.ts"
  - "src/env.ts"
  - "src/lib/env.ts"
  - "src/lib/api/**"
  - "src/lib/api-client.ts"
description: Server-side calls, secret handling and the response envelope
---

# API & secrets

Full note: `obsidian/backend/api-architecture.md`. This project's endpoint
directory is `paths.server` and its env module is `paths.env` in
`.claude/stack.json`.

- **The one hard line:** third-party/external calls run **server-side**. The
  browser only ever calls same-origin endpoints and never holds a secret.
- **Secrets are server-only** env vars, read through the single validated env
  module. Never behind `bindings.envPublicPrefix`, never `process.env` /
  `import.meta.env` read directly from a component.
- **If this stack has no server** (`capabilities.apiRoutes: false`), there is no
  safe place for a secret in this repo at all. Everything in the bundle is
  public. Add a function/proxy layer, or use a service designed for public
  clients — do not "hide" a key.
- **Validate input** with the project's schema library, always. Parse, don't
  trust. Invalid input → 400.
- **Return the envelope** — `{ data }` on success, `{ error: { code, message } }`
  on failure, with the right status. One shared handler wrapper maps thrown
  errors to statuses; never leak stack traces or upstream internals.
- Client calls go through the typed same-origin fetch helper, never bare `fetch`
  to an external origin.

**Optional env vars must treat `""` as unset.** Copying `.env.example` leaves
declared-but-blank keys, which arrive as `""`, not `undefined` — a bare
`.optional()` then rejects them and the failure surfaces as a confusing 400
blaming the caller. Preprocess `""` → `undefined` for every optional variable.

If a new endpoint needs a new env var: add it to the schema in the env module and
to `.env.example` in the same change.
