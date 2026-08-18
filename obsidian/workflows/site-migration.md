---
tags: [workflow, seo, stable]
updated: 2026-08-18
---

# Workflow — Site Migration

Protecting search rankings when this project replaces an existing live site.
Skill: `site-migration`. Command: `/migrate-site`.

> [!warning] Raise this at the **start** of the project
> Traffic collapse after a relaunch is almost always the same cause: URLs changed
> and nothing told search engines where they went. Done before the rebuild, this
> is cheap insurance. Done after launch, it is damage control.

## The four artefacts

| File | Holds | Captured |
|---|---|---|
| `MIGRATION-URL-INVENTORY.md` | every indexed URL of the live site | before anything changes |
| `MIGRATION-RANKINGS-SNAPSHOT.md` | top pages, top queries, positions 1–10 | before anything changes |
| `MIGRATION-REDIRECT-MAP.md` | old → new, 301, one hop | during the rebuild, complete before launch |
| the launch checklist | in [[ship]] | at launch |

Inventory from several sources — sitemap, Search Console, a crawl, the CMS's page
list. Each misses different things, and what they miss (old landing pages, PDFs,
paginated archives) is exactly what quietly carries links.

## Redirect map rules

- **Every** old URL gets a destination. `[TBD]` at launch is a 404.
- Closest equivalent page — **never** a blanket redirect to the homepage, which
  search engines treat as a soft 404 and the equity is lost.
- **301**, one hop. If the old site already redirects, map to the final
  destination.
- Preserve or deliberately normalise trailing-slash and query-parameter behaviour.

**Where redirects run depends on the stack** — framework config, a platform file,
or the CDN. Keep them in code so they are reviewable, and confirm the mechanism
actually runs in production, not just in dev.

## Carry over what is already trusted

Keep URL structure unless there is a strong reason to change it ("the new IA is
nicer" rarely qualifies on a ranking page). Preserve titles and H1s on pages that
rank. Carry the content over — a rebuilt page with a third of the copy usually
drops. Re-add structured data.

## After launch

Watch weekly for the first month: coverage errors, 404s in logs, and the ranking
snapshot. Some fluctuation for 2–4 weeks is normal; a sustained drop on one page
means its redirect or its content is wrong.

## Related

[[seo-aeo]] · [[ship]] · [[seo-metadata]]
