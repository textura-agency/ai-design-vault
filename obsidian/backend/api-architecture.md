---
tags: [backend, api, stable]
updated: 2026-08-18
---

# API Architecture

How the app talks to external services. ADR: [[decisions-log]] ADR-0011.

## The one hard line

> The **browser never calls a third-party API directly and never holds a
> secret**. Every external call runs in server code; the client only calls
> **same-origin endpoints**.

## The endpoint convention

Endpoints live in `paths.server` — whatever this framework calls them (route
handlers, `+server` files, server routes, serverless functions).

- **One resource per folder/file**, named by noun.
- **The handler owns the work.** Business logic, calling upstream services,
  transforming the result and reading secret env vars all live in the handler.
  There is no mandatory passthrough layer.
- **Secrets are safe here by construction** — server files are never bundled into
  the browser, provided nothing imports them from a component.

### Non-negotiables

1. **Validate input** with the project's schema library (body + query). Never
   trust the client. Invalid input → `400`.
2. **Consistent envelope** — success `{ data }`, failure
   `{ error: { code, message, issues? } }`, with correct status codes.
3. **Never leak** stack traces or upstream internals to the client.
4. **Standard server runtime** unless there is a specific reason otherwise —
   an edge/restricted runtime trades away Node APIs and usually buys nothing for
   a marketing site.

### The shared wrapper

One `handle()` wrapper produces the envelope and maps thrown errors to statuses
(validation error → 400, malformed JSON → 400, a typed `ApiError` → its status,
anything else → 500). Every handler is wrapped. This is what keeps error handling
consistent without each endpoint reinventing it.

```
handler = handle(async (req) => {
  const input = schema.parse(await req.json())   // → 400 on bad input
  const { UPSTREAM_URL } = getServerEnv()        // secret, server-only
  ...
  return { received: true }                      // → { data: { received: true } }
})
```

### Extract only when it pays

Keep logic in the handler by default. Lift it into a shared module only when it
is **genuinely reused** across endpoints (an upstream client, a shared schema,
auth helpers). Do not pre-build a service layer.

## Environment & secrets

The env module (`paths.env`) validates configuration with a schema and splits it:

- a **public** object (values behind `bindings.envPublicPrefix`) — safe anywhere
- a **server-only accessor** — called from server code only

Secrets are unprefixed. Optional variables must treat `""` as unset — see
[[environment-variables]] for why that specific trap costs an afternoon.

## Calling endpoints from the client

Client code fetching after mount goes through one typed helper that calls a
same-origin path and unwraps the envelope, throwing a typed error on failure.
Render-time data is loaded at the route instead — no client request at all.

## Related

[[backend/README]] · [[environment-variables]] · [[routing-views]] · [[data-flow]]
