---
name: schema-markup
description: Generate and wire valid JSON-LD structured data — Organization, WebSite, LocalBusiness, Article, Product, FAQPage, BreadcrumbList, Service — through one shared builder rather than inline script tags scattered through components. Use when the user asks for "schema", "structured data", "JSON-LD", "rich snippets", "FAQ schema", or wants richer search/AI results.
allowed-tools: Read, Grep, Glob, Edit, Write, WebFetch
---

# Structured data (JSON-LD)

Keep structured data in **one typed builder module** (e.g.
`<paths.source>/utils/seo/structured-data.*`) that composes an entity graph, and
render it once per page. Do not scatter inline
`<script type="application/ld+json">` tags through components — that is how a
site ends up with three conflicting Organizations.

If no builder exists yet, create it; it is the first thing this skill installs.

## Rules

1. **JSON-LD only** — never microdata or RDFa (hard rule 10).
2. **Only describe what is on the page.** Schema claiming content the page does
   not contain is spam, and search engines treat it that way.
3. **Reference, don't duplicate.** Build the graph with `@id` references between
   entities so the Organization is defined once and linked from everywhere.
4. Values come from the site config module and the page's own props — never
   hardcoded a second time.
5. Validate: the JSON parses, required properties are present, URLs are absolute
   (they need the site URL variable set — see `seo-audit`).

## Types worth adding, by page kind

| Page | Type | Required-ish properties |
|------|------|------------------------|
| Home | `Organization`, `WebSite` | name, url, logo, sameAs |
| Local business | `LocalBusiness` | address, geo, openingHours, telephone |
| Blog post | `Article` / `BlogPosting` | headline, image, datePublished, dateModified, author |
| Service page | `Service` | serviceType, provider, areaServed |
| Product | `Product` + `Offer` | name, image, description, price, availability |
| FAQ block | `FAQPage` | mainEntity[] of Question/acceptedAnswer |
| Any nested page | `BreadcrumbList` | itemListElement with position |
| Team page | `Person` per member | name, jobTitle, image, worksFor |

`FAQPage` earns its place twice over: it is the format both featured snippets and
AI answer engines extract most reliably. If the page has a real FAQ section, mark
it up — but the questions must be visible on the page, not schema-only.

## Pattern

A typed builder per entity, composed into the graph, with a single render point
per page (root layout for the site-wide graph, the view for page-specific
entities). Injecting it differs per stack — a script tag in the layout, the
framework's head API, or a serialized `<script>` in an island's server-rendered
output. Whichever it is, it must land in the **server-rendered HTML**, not be
appended by client JS.

## After

Note new schema in `obsidian/frontend/seo-metadata.md`, and validate with
Google's Rich Results Test / the schema.org validator against the deployed URL.
