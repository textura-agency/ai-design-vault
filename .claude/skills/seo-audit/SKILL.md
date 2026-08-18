---
name: seo-audit
description: Audit a page or the whole site for technical and on-page SEO — crawlability and render mode, metadata, heading outline, structured data, internal linking, Core Web Vitals, and the animation-specific crawlability risks an immersive site carries. Produces ranked findings and fixes them in code. Use when the user asks to "audit SEO", "check my SEO", "why isn't this ranking", "fix meta tags", or before a launch.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch
---

# SEO audit

Audit the **code**, and the live URL when one exists. Rank findings by impact and
fix them; do not hand back a lecture. Resolve routes, metadata API and the site
URL variable from `.claude/stack.json`.

## 0. Establish the render model first — it changes everything

`framework.renderModel` in `stack.json`:

- **`spa`** — the single largest finding on any marketing site. Crawlers get an
  empty root element; answer engines execute even less JS than Googlebot. Nothing
  below matters until content is server-rendered or prerendered. Say so first,
  and propose the framework's prerender/SSG path rather than working around it.
- **`ssg` / `ssr` / `server-components` / `islands`** — content is in the HTML.
  Verify it, do not assume: `curl -s <url> | grep -c "<known heading text>"`, or
  view-source on the deployed page.
- **`islands`** — check that content inside a client island is present in the
  server-rendered HTML, not mounted after hydration.

## 1. Indexability — nothing else matters if this is broken

- **robots** — crawlers allowed, sitemap referenced, no accidental `disallow: /`,
  no staging block surviving into production.
- **sitemap** — **every public route is listed.** This is the one that rots.
  Cross-check the actual route files under `paths.routes` against the sitemap's
  entries; a route added without a sitemap entry is the most common miss.
- **Canonical URL** per page; no duplicate content across trailing-slash or
  parameter variants.
- **The site URL variable is set in production** (`NEXT_PUBLIC_SITE_URL`,
  `PUBLIC_SITE_URL`, `NUXT_PUBLIC_SITE_URL` — whatever this stack uses). Unset
  means canonical and OG tags resolve to `localhost` for social scrapers.
- **No route accidentally opted out of static rendering.** Anything that reads
  headers or cookies at request time — including bot detection — forces dynamic
  rendering and costs TTFB on every visit.

## 2. Metadata

Every route produces metadata through the stack's own mechanism
(`bindings.metadata`) — never hand-written `<meta>` tags scattered in components.

- Unique, specific `title` per route — not the site name repeated.
- `description` per route, written for a human, 140–160 chars.
- OG image present and correctly sized (1200×630), resolving to an **absolute**
  URL.
- Theme colour, `lang` on `<html>`, favicons and manifest present.

## 3. Content structure

- Exactly one `<h1>`, matching what the page is actually about.
- Heading outline is a real hierarchy with no skipped levels.
- `<main>` present; landmarks named; lists are lists.
- Answer-shaped content: the page states its answer near the top rather than
  building to it — this serves both featured snippets and AI extraction.
- Internal links use `bindings.link`, have descriptive anchor text (never "click
  here"), and no important page is orphaned.
- Every image has meaningful `alt`.

## 4. Structured data

Run the `schema-markup` skill. At minimum `Organization` + `WebSite`; add
per-page types where they apply. Validate the JSON-LD parses and references real
on-page content.

## 5. Performance (Core Web Vitals)

An immersive site's risks are specific:

- **LCP** — the hero image is priority-loaded and correctly sized; fonts load
  through the framework's font pipeline with no layout shift.
- **CLS** — every image has explicit dimensions; nothing animates layout on load.
- **INP** — motion runs through the shared ticker; no per-frame work on the main
  thread that could have been GPU-side.
- **Hydration cost** — on islands/server-component stacks, measure how much JS
  each route ships. A section made client-side purely to animate is the usual
  culprit.
- If the project renders a three.js/WebGL scene, **stop and use the
  `optimize-3d-scene` skill** — it owns that order of fixes.
- Check the real numbers, not vibes: Lighthouse or PageSpeed on the deployed URL,
  mobile profile.

## 6. The animation-specific crawler risk

Content revealed by scroll animation must exist in the DOM regardless. Motion
that only touches opacity and transform is safe — crawlers see the text. Keep it
that way:

- Do **not** gate content behind an in-view callback that *mounts* it.
- Do not branch markup on user-agent — it costs static rendering and edges toward
  cloaking. Prefer the reduced-motion path, which is honest and gets the same
  result.

## 7. Output

A ranked table — issue, severity, file, fix — then apply the fixes. Re-run
`.claude/scripts/verify.sh` and the build afterwards. Note anything that needs
the user (a live URL, Search Console access, a correctly sized OG asset).
