---
description: Protect rankings when rebuilding an existing live site
argument-hint: <current-live-url>
---

Run the pre-migration process for: **$ARGUMENTS**

Use the `site-migration` skill. This must happen **before** the rebuild changes
anything — after launch it is damage control.

1. Inventory every indexed URL of the live site → `MIGRATION-URL-INVENTORY.md`
   (sitemap + Search Console + a crawl; each misses different pages).
2. Ask the user for a Search Console performance export (3–6 months) and snapshot
   top pages, top queries and everything in positions 1–10 →
   `MIGRATION-RANKINGS-SNAPSHOT.md`.
3. Build `MIGRATION-REDIRECT-MAP.md` — old → new, 301, one hop, closest
   equivalent page, never a blanket redirect to the homepage. Mark unknowns
   `[TBD]` and track them to zero.
4. Confirm **where redirects actually run** in this stack (framework config,
   platform file, or CDN) and that the mechanism works in production, not just
   in dev.
5. Tell the user plainly: every `[TBD]` left at launch is a 404, and the
   redirects must be live the moment the new site goes up.

Re-verify the map as part of `/ship`.
