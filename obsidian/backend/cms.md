---
tags: [backend, cms, wip]
updated: 2026-08-18
---

# Headless CMS

The kit prescribes **no vendor** (ADR-0015). It prescribes how the decision is
made and how content is wired once it is. Playbook: the `headless-cms` skill,
`/cms`.

## Choosing

Constraints decide this faster than preference: does the framework have a server
at runtime, is there a database, who edits and how often, does content need
preview/drafts, and does the host support the CMS's runtime.

| Situation | Reasonable choice |
|---|---|
| Node framework with server routes and its own admin story | an **in-app CMS** — one deploy, one database, direct data access with no HTTP hop |
| Static/SSG site, or a team that wants no backend to run | a **hosted CMS** — content over an API at build time |
| Content is genuinely files, edited by developers | **Markdown/MDX in the repo**. Do not add a CMS to a five-page site nobody else edits |
| A marketing team already on a platform | whatever they already use |

**Check peer compatibility before installing.** An in-app CMS pins the framework
version range; verify the installed major is inside it rather than discovering it
mid-install.

## Modelling

Model from **what the site renders** — read the views and the mock data, name the
content types that actually exist, propose, confirm, then write config.

- One collection per real content type. A `Page` collection with a blocks field
  beats twenty near-identical page types.
- Globals for site-wide singletons (nav, footer, contact details).
- Only the fields the design uses. Every unused field is a question an editor has
  to answer forever.

## Wiring — identical regardless of vendor

- **Fetch on the server.** In-app CMS → its direct/local API in server code, no
  HTTP hop to yourself. Hosted CMS → its SDK in a loader or endpoint with a
  server-only token. Never fetch content client-side with a write-capable key.
- **Types are generated.** Regenerate after every schema change and use the
  generated types. Casting CMS data to a hand-written interface turns a schema
  change into a runtime crash.
- **The schema is the contract**: update the schema → regenerate types →
  generate a migration → use it in the view. In that order.
- **Content flows through props** to views; presentational components stay pure
  and CMS-unaware ([[component-conventions]]).
- **Media** goes to object storage, never into the repo. Serve through the
  stack's image pipeline where one exists; explicit dimensions either way.
- **Draft/preview** is a separate render path with its own cache rules. Get it
  working before handover, or the client will publish to check their work.

## Proving it

Not "the config compiles". All four: the admin loads and a user can log in; a
document with an uploaded image saves; that image renders from storage in the
browser; the content appears on a public route and updates when changed.

## This project

> [!todo] Fill in when a CMS is added
> Vendor, why it was chosen over the alternatives (link the ADR), the collection
> model, where the client lives, how types are generated, and the preview flow.

## Related

[[backend/README]] · [[database]] · [[environment-variables]] · [[tech-stack]]
