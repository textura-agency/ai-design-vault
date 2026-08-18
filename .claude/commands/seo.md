---
description: Run an SEO and AEO audit, then apply the fixes
argument-hint: [url-or-path?]
---

Audit search and answer-engine visibility for: **$ARGUMENTS**

Delegate to the `seo-auditor` agent, or run the skills directly if the scope is
small: `seo-audit` → `schema-markup` → `aeo-visibility`.

Start with `framework.renderModel` in `.claude/stack.json`. On a `spa` render
model, "crawlers see an empty page" is the finding — everything else is noise
until content is server-rendered or prerendered.

Then, in priority order: indexability (robots, sitemap coverage vs actual routes,
canonicals, the site URL variable) → metadata completeness → content structure
and heading outline → structured data → measured Core Web Vitals → AEO (llms.txt,
crawler policy, entity consistency).

Ask before changing AI-crawler policy — "be cited by AI" and "don't train on my
content" are different goals with different bots.

Deliver a ranked findings table, apply the code fixes, and state clearly what
needs the user (Search Console access, a live URL, a correctly sized OG image).
