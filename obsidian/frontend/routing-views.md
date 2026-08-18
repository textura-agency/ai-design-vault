---
tags: [frontend, stable]
updated: 2026-08-18
---

# Routing & Views

The defining convention: **routes delegate to views**. ADR: [[decisions-log]] ADR-0003.

> [!warning] This may not be the framework you know
> Routing, metadata and middleware APIs change between majors — a middleware file
> renamed, a metadata export replaced, a router import moved. **Verify against the
> installed version's own docs before writing routing code.** This is the single
> most common source of confidently-wrong code in this repo.

## Route → view delegation

A route/page file contains **no UI logic**. It loads data and renders a view from
`paths.views`:

```
route file (paths.routes)          view (paths.views)
─────────────────────────          ──────────────────
load data (loader / server         all layout and UI logic
component / build-time fetch)      composes components
render <View {...data} />          receives content as props
```

Why: route files are the most framework-coupled files in the codebase. Keeping
them thin means a framework upgrade, or a move to a different framework entirely,
rewrites a handful of small files instead of the whole site. It is what makes the
UI portable at all.

`verify.sh` FAILs a route file importing anything other than a view (plus the
framework's own packages).

## Server-first rendering

Render on the server or at build time by default; make a component interactive
only at the leaf that needs it. What that means per stack:

| Render model | "Interactive at the leaf" means |
|---|---|
| `server-components` | `"use client"` only on the leaf; never on a layout, page or view to dodge a boundary |
| `ssr` | hydrate the whole page, but keep client-only work inside small components and effects |
| `islands` | **one island per interactive region.** Each island is a separate hydration root — module state does not cross them, so a shared ticker or store must live in one island or a plain script |
| `ssg` | same as `islands` if it hydrates anything; otherwise no client JS at all |
| `spa` | everything is client-side. Prerendering is the only way this gets a crawlable page — see [[seo-metadata]] |

The measurable version of this rule: **how much JavaScript does this route
ship?** A whole section made interactive to animate one heading is the regression
to watch for.

## Adding a route

1. Create the route file under `paths.routes` — thin, delegating.
2. Create the view under `paths.views`.
3. Register the route in the sitemap **in the same change**. This is the most
   common drift in every project.
4. Follow the [[new-page]] playbook.

## Layouts

- The **root layout / app shell** loads the token file and fonts, holds the
  provider tree (scroll layer → global UI → children), sets document metadata and
  renders the JSON-LD graph once.
- Reusable layout *wrappers* (not route layouts) live with the components.
- Provider order is fixed and documented in [[data-flow]] — reordering it breaks
  scroll locking in ways that look like unrelated bugs.

## Navigation

Use `bindings.link` and `bindings.router` from [[stack-profile]]. Where those are
`native`, a plain `<a>` is correct — some frameworks intercept them, and adding a
component there is cargo cult. Where they are not, a raw `<a href="/internal">`
loses client-side navigation and prefetching.

Never import a router API from a different framework generation — that is the
classic training-data error.

## Middleware / proxy layers

Keep them thin: routing, rewrites, redirects, cheap cookie presence checks. Not
authorisation (that belongs in the data layer and the endpoint — see
`.claude/rules/data-layer.md`), and not business logic. Every matched route pays
the cost on every request, so keep the matcher tight or static marketing pages
get dragged through it.

## SEO per route

Each route produces metadata through `bindings.metadata` and the shared generator
— see [[seo-metadata]]. Never hand-write `<meta>` or `<title>` inside components.

## Related

[[stack-profile]] · [[system-overview]] · [[component-conventions]] · [[new-page]] · [[seo-metadata]]
