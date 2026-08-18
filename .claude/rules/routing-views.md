---
paths:
  - "src/app/**"
  - "src/pages/**"
  - "src/routes/**"
  - "src/views/**"
  - "app/routes/**"
  - "app/views/**"
  - "pages/**"
  - "routes/**"
  - "views/**"
description: Routes delegate to views; render server-first
---

# Routing & views

Full note: `obsidian/frontend/routing-views.md`. Real paths: `paths.routes` and
`paths.views` in `.claude/stack.json`.

> **This may not be the framework you know.** Routing, metadata and middleware
> APIs change between majors. Verify against the installed version's own docs
> before writing routing code — do not write it from memory.

- **Routes delegate.** A route/page file is a few lines: it imports a view and
  renders it, passing data it loaded. All UI logic lives in the view. This is
  what keeps the site portable between framework generations — when routing
  changes, the views do not.
- **Server-first.** Render on the server or at build time by default; make a
  component interactive only at the leaf that needs it. Never mark a whole
  layout, page or view client-side to dodge a boundary — split a leaf wrapper.
  On an islands stack, each island is a hydration root: one per interactive
  region, not one per section.
- **Data loads at the route** (loader / server component / endpoint), and reaches
  the view as props. Views do not fetch.
- **Navigation and images** go through `bindings.link` / `bindings.image`. Where
  those are `native`, plain `<a>` and `<img>` are correct — with explicit
  dimensions on images either way.
- **Metadata** comes from `bindings.metadata`, per route, through the shared
  generator — never hand-written `<meta>` tags inside components. Add each new
  route to the sitemap in the same change; that is the single most common drift.
- **Middleware/proxy layers stay thin** — routing, rewrites, redirects, cheap
  cookie checks. Not authorisation (see `.claude/rules/data-layer.md`), and not
  business logic. Every matched route pays its cost on every request.
