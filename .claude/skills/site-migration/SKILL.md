---
name: site-migration
description: Protect search rankings when rebuilding or relaunching an existing site — pre-migration crawl and inventory, rankings snapshot, redirect map, and post-launch verification. Use when the user is rebuilding a live site, replacing an existing site, changing URL structure, or says "we're relaunching", "migrating from WordPress/Webflow", or "will this hurt our rankings".
allowed-tools: Bash, Read, Write, Edit, WebFetch, WebSearch
---

# Site migration without losing rankings

Traffic collapse after a relaunch is almost always the same cause: URLs changed
and nothing told search engines where they went. The work below happens **before**
the new site goes live. After launch it is damage control.

If the user is rebuilding a live site, raise this **at the start of the project**,
not at the end. It is the cheapest insurance in the whole engagement.

## 1. Inventory the live site — before anything changes

Crawl or list every indexed URL. Record: URL, page title, H1, content type,
whether it currently ranks. Save to `MIGRATION-URL-INVENTORY.md`.

Sources, in order of reliability: the existing sitemap.xml, Search Console's Pages
report, an actual crawl, the CMS's own page list. Use several — each misses
different things, and the ones they miss (old landing pages, PDFs, paginated
archives) are exactly the ones that quietly carry links.

## 2. Snapshot what you are protecting

Ask the user for a Google Search Console performance export (last 3–6 months:
Performance → Export). From it record:

- top 20 pages by clicks
- top 30 queries by clicks and impressions
- everything ranking in positions 1–10

Save to `MIGRATION-RANKINGS-SNAPSHOT.md`. This is the baseline you will be judged
against, so capture it before the rebuild touches anything.

Also capture the most-linked pages (Ahrefs/Semrush export if they have one). A
page with backlinks must keep its equity — losing it is far more expensive than
losing an unlinked page.

## 3. Build the redirect map

`MIGRATION-REDIRECT-MAP.md`, two columns: old URL → new URL. Rules:

- **Every** old URL gets a destination. Mark unknowns `[TBD]` and resolve them all
  before launch — a `[TBD]` at launch is a 404.
- Map to the **closest equivalent page**, never blanket-redirect everything to the
  homepage. Google treats mass homepage redirects as soft 404s and the equity is lost.
- **301** (permanent), not 302, unless the change genuinely is temporary.
- One hop. Chained redirects leak and slow crawling — if the old site already
  redirects, map to the final destination.
- Preserve query-parameter and trailing-slash behaviour, or normalise it
  deliberately and consistently.

**Where redirects live depends on the stack**: the framework's own redirect config
(`next.config`, `svelte.config`/hooks, `nuxt.config`, `astro.config`), a platform
file (`vercel.json`/`vercel.ts`, `netlify.toml`, `_redirects`), or the CDN. Keep
them in code so they are reviewable, and confirm the mechanism actually runs in
production — a redirect config that only works in dev is a silent 404 farm.

## 4. Carry over what search engines already trust

- Keep URL structure identical wherever there is no strong reason to change it.
  "The new IA is nicer" is rarely worth the risk on a ranking page.
- Preserve page titles and H1s on pages that rank, unless improving them is the point.
- Carry over the content — a rebuilt page with a third of the copy usually drops.
- Keep the same canonical/`lang` conventions; re-add structured data.

## 5. Launch checklist

- [ ] Every old URL redirects, one hop, 301, to a real page
- [ ] robots allows crawling (staging blocks removed — check this twice)
- [ ] The sitemap lists every new public route, and is submitted in Search Console
- [ ] The site URL variable points at the production domain
- [ ] No `noindex` left over from staging
- [ ] Analytics and Search Console verified on the new site
- [ ] Core Web Vitals measured on the new site (`seo-audit` skill)

## 6. After launch

Watch weekly for the first month: Search Console coverage errors, 404s in logs,
and the ranking snapshot from step 2. Some fluctuation for 2–4 weeks is normal;
a sustained drop on a specific page means its redirect or its content is wrong.
