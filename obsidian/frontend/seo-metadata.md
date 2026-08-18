---
tags: [frontend, seo, stable]
updated: 2026-08-18
---

# SEO & Metadata

## Site config

One module (`<source>/lib/site.*`) is the **single source of truth** for SEO —
name, description, origin URL, OG image, social handles, theme colour. The
metadata generator, robots, sitemap and the JSON-LD builder all read from it.
Update the placeholder values per project. `#todo`

The origin URL comes from the site URL env variable (see
[[environment-variables]]), falling back to localhost in development. **It must be
set in production** or every canonical and OG URL resolves to localhost for social
scrapers.

## Metadata generator

One shared generator, used by every route through `bindings.metadata`:

- Title and description **per route** — unique and specific, never the site name
  repeated.
- Absolute URLs for canonical and OG. Relative OG images break social scrapers,
  so the generator resolves them against the origin.
- OpenGraph and Twitter card fields, icons, robots directives.
- Viewport and theme colour go wherever the framework puts them — some separate
  them from metadata; check the installed version.

Never hand-write `<meta>` or `<title>` inside a component. One route, one call.

## robots.txt & sitemap.xml

Generated from the real routes, not hand-maintained:

- **robots** — allow crawling, point at the sitemap, and make sure no staging
  block survives into production.
- **sitemap** — **every public route**. Adding a route without a sitemap entry is
  the single most common drift in any project; add it in the same change.

Whether these are route files, build-time generators or static files depends on
the framework — resolve it from [[stack-profile]].

## Structured data (JSON-LD)

One builder module produces an `Organization` + `WebSite` graph, rendered once per
page; page-specific entities extend the graph from the view. JSON-LD only, never
microdata (ADR-0014). It must land in the **server-rendered HTML** — structured
data appended by client JS is unreliable at best.

Details and per-page types: the `schema-markup` skill.

## Crawlability of an immersive site

This is where an animation-heavy site earns or loses its ranking:

- **Content must exist in the DOM regardless of motion state.** Reveals animate
  opacity and transform; they never *mount* content on scroll. A section that
  renders only after an in-view callback is invisible to crawlers.
- **Render model decides everything else.** On `spa`, crawlers get an empty root
  — prerendering or SSR is the fix, and nothing else on this page matters until
  it is done. See [[stack-profile]].
- **Avoid user-agent branching.** Serving different markup to bots costs static
  rendering (a header read forces dynamic rendering) and edges toward cloaking.
  The reduced-motion path gets the same result honestly.

## Static assets

The static root holds meta/PWA/SEO assets — favicons in several sizes, Apple and
Android icons, `manifest.json`, `browserconfig.xml`, the OG image. Site **content**
assets go under `paths.assets/<section>/` — see [[folder-structure]].

Target **1200×630** for the OG image, and keep the declared dimensions in the
metadata generator in sync with the real file.

## Related

[[routing-views]] · [[html-semantics]] · [[environment-variables]] · [[seo-aeo]]
