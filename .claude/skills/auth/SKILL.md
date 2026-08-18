---
name: auth
description: Add authentication to this project — deciding whether it is needed at all, choosing a provider that fits the render model, session handling across server and client, the verification mistakes that create silent security holes, and protecting routes correctly. Use when the user says "add login", "we need accounts", "protect this route", "set up Clerk/Supabase Auth/Auth.js", or asks about sessions, JWTs or middleware auth.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch
---

# Authentication

## 1. Does this project need real accounts?

An immersive marketing site almost never does. A CMS's own admin login is not
site auth. A gated download can be a signed link. Add auth only for genuine user
accounts with per-user data — and say so when the answer is no, because auth is
the single heaviest thing you can bolt onto a static-ish site.

## 2. Fit it to the render model

- **SSR / server components / server routes** — sessions in httpOnly cookies,
  verified server-side on every request. This is the good case.
- **Islands / mostly-static** — auth state cannot be prerendered. Either render
  the authed area dynamically or fetch state client-side after hydration and
  accept the flash. Decide deliberately; do not let it emerge.
- **Pure SPA with no server** — the browser cannot hold a secret. Use a provider
  with a public client flow (PKCE) and enforce every rule server-side, in the API
  the SPA talks to. There is no client-side authorisation, only client-side UI.

## 3. Non-negotiables

- **Verify, don't trust.** A session object read from a cookie is unverified
  input until the token's signature has been checked against the provider. Any
  API that only *reads* a session without validating it is a bypass — use the
  provider's verifying call in server code, every time.
- **Middleware/edge is for routing, not authorisation.** Redirecting an
  unauthenticated visitor is fine; deciding who may read what belongs in the data
  layer (row-level security) or the endpoint. Middleware can be bypassed by
  anything that reaches the route directly.
- **Do not run code between creating the server client and refreshing the
  session** in a middleware/hook — several SDKs document this exactly, and the
  symptom is users being randomly logged out.
- **Return the response object the SDK gave you**, unmodified, when it manages
  cookie refresh.
- Use the SDK's current server package; the older "auth helpers" generations are
  deprecated across most vendors.
- Secrets stay server-only. Public keys are public by design — the security comes
  from RLS and endpoint checks, not from hiding them.

## 4. Route protection, in layers

1. **Data layer** — RLS or per-query ownership checks. The only layer that cannot
   be skipped.
2. **Endpoint** — verify the session, authorise the action, then act.
3. **Route/UI** — redirect and hide. Cosmetic; assume it can be bypassed.

Build them in that order. A project that only has layer 3 has none.

## 5. Prove it

Log in, reload (session survives), hit a protected API with no session (401), hit
another user's record (denied by RLS, not by the UI), log out (cookie cleared,
protected route redirects).

## 6. Record it

`obsidian/backend/database.md` or a dedicated auth note, `environment-variables.md`,
`tech-stack.md`, the changelog, and an ADR for the provider choice.
