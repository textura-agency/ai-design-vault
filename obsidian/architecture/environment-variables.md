---
tags: [architecture, config, stable]
updated: 2026-08-18
---

# Environment Variables

## Rules

- Secrets live in a git-ignored env file locally, and in the host's environment
  settings in production. Never committed.
- **Every variable is documented in `.env.example`** (committed, placeholder
  values only).
- **Read env through one validated module** (`paths.env`), never `process.env` /
  `import.meta.env` scattered through components. One place to see what the app
  needs, and a boot-time failure instead of an undefined at runtime.
- **The public prefix is a security boundary.** `bindings.envPublicPrefix` in
  [[stack-profile]] (`NEXT_PUBLIC_`, `VITE_`, `PUBLIC_`, `NUXT_PUBLIC_`, …) means
  "this value is baked into the browser bundle". Anything without it is
  server-only. A secret behind the public prefix is a published secret.
- The env module splits accordingly: a public object safe anywhere, and a
  server-only accessor used in server code only.

> [!warning] On a stack with no server
> An SPA or fully static build has no server-only side. **Every value in the
> bundle is public**, prefix or not. If a project needs a secret, it needs a
> function layer or a proxy first — see [[api-architecture]].

## Optional variables must treat `""` as unset

`cp .env.example .env` — the documented setup step — leaves declared-but-blank
keys, which arrive as `""`, **not** `undefined`. A bare `.optional()` rejects `""`
as invalid, and the failure surfaces as a confusing error blaming the caller for a
setup problem. Preprocess `""` → `undefined` for every optional variable.

## Current variables

| Name | Scope | Purpose |
|---|---|---|
| `<PREFIX>SITE_URL` | public | Site origin, no trailing slash. Drives canonical URLs, OG tags, robots, sitemap, JSON-LD. **Must be set in production** or scrapers see `localhost` |
| | | |

## When adding one

1. Add it to `.env.example` with a comment describing it.
2. Add it to the schema in the env module — optional ones through the `""`-safe
   helper.
3. Add a row to the table above.
4. Set it on the host for every environment that needs it.
5. Add a [[changelog]] entry.

## Related

[[stack-profile]] · [[api-architecture]] · [[seo-metadata]]
