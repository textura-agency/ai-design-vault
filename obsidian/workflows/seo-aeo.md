---
tags: [workflow, seo, stable]
updated: 2026-08-18
---

# Workflow — SEO & AEO

Search visibility and answer-engine citability, as an ongoing practice rather
than a launch task. Skills: `seo-audit` → `schema-markup` → `aeo-visibility`.
Agent: `seo-auditor`. Command: `/seo`.

## Start with the render model

`framework.renderModel` in [[stack-profile]] decides how much of the rest matters.
On a `spa`, crawlers get an empty root element and answer engines execute even
less JavaScript than Googlebot — **that is the finding**, and everything else is
noise until content is server-rendered or prerendered.

Verify rather than assume: view-source or `curl`, not devtools (which shows the
hydrated DOM).

## Priority order

1. **Indexability.** Robots, sitemap coverage against the real routes, canonicals,
   the production site URL. Nothing else matters if this is broken.
2. **Metadata completeness.** Unique title and description per route; OG image
   resolving absolutely and correctly sized.
3. **Content structure.** One `<h1>`, a real heading hierarchy, answer-first copy,
   descriptive internal links, alt text.
4. **Structured data.** `Organization` + `WebSite` minimum, page-appropriate types
   beyond that, JSON-LD in the server HTML.
5. **Performance.** Measured on mobile — including the client-JS weight per route,
   not just images.
6. **AEO.** `llms.txt`, crawler policy, entity consistency.

## The immersive-site risk

Content revealed by scroll animation **must exist in the DOM regardless**. Motion
that only touches opacity and transform is safe. Content mounted by an in-view
callback is invisible to crawlers, and user-agent branching costs static rendering
while edging toward cloaking. The reduced-motion path gets the same result
honestly ([[seo-metadata]]).

## AEO in one paragraph

Classic SEO gets you ranked; AEO gets you **quoted**. Answer engines extract
self-contained claims from crawlable text and weight consistency of facts about an
entity across the whole web. So: answer first in every section, one idea per
heading phrased as a question, concrete specifics over adjectives, real FAQs
marked up as `FAQPage`, and the same facts everywhere — site, JSON-LD, `llms.txt`,
LinkedIn, aggregator profiles. Crawler policy is a **user decision**: "be cited by
AI" and "don't train on my content" are different goals with different bots.

## Honesty rules

Technical fixes remove obstacles; they do not guarantee rankings. AEO changes take
weeks to surface and vary between runs and platforms. Third-party corroboration
outweighs anything the site says about itself. Say all of this rather than
implying a fix is a result.

## Related

[[seo-metadata]] · [[html-semantics]] · [[ship]] · [[site-migration]]
