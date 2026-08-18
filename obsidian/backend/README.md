---
tags: [backend, moc]
updated: 2026-08-18
---

# Backend Overview

An immersive marketing site often needs **less backend than expected**. Work out
which of these it actually needs before building any of it:

| Need | Answer | Note |
|---|---|---|
| Call a third-party API with a key | a server endpoint | [[api-architecture]] |
| Editable content | a headless CMS — or Markdown in the repo | [[cms]] |
| Store structured, queryable data | a database | [[database]] |
| Real user accounts | auth (the `auth` skill) | rarely needed on a marketing site |
| Contact form | an endpoint forwarding to a CRM/email service | not a database |

> [!warning] Does this stack even have a server?
> `capabilities.apiRoutes` and `framework.renderModel` in [[stack-profile]]
> decide. On a `spa` or fully static build there is **no server-only side**:
> every value in the bundle is public, and there is nowhere safe for a key. Add a
> function layer, use a service designed for public clients, or drop the feature —
> but do not pretend a bundled key is hidden.

## The invariants, whatever you build

1. **The browser never holds a secret and never calls a third-party origin
   directly.** Same-origin endpoints only (ADR-0011).
2. **Env through one validated module.** Server-only values are unprefixed;
   anything behind the public prefix is published ([[environment-variables]]).
3. **Validate input, return one envelope** — `{ data }` / `{ error }`.
4. **Generated types are generated.** Never hand-write a type for CMS content or
   a database row.
5. **Content reaches views as props**, loaded at the route. Views do not fetch
   ([[data-flow]]).
6. **Authorisation lives in the data layer and the endpoint** — never in
   middleware or the UI alone.

## Related

[[api-architecture]] · [[cms]] · [[database]] · [[environment-variables]] · [[stack-profile]]
