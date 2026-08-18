---
tags: [workflow, launch, stable]
updated: 2026-08-18
---

# Workflow — Ship

The pre-launch gate. Skill: `ship-check`. Command: `/ship`.

Nothing here is optional, and **anything unchecked is reported as unchecked** —
never assumed to pass.

## The gates, in order

| # | Gate | Passes when |
|---|---|---|
| 1 | **It builds and obeys the rules** | `verify.sh` zero FAILs; lint, typecheck and build clean |
| 2 | **It is correct** | `qa-verify` across every route and breakpoint, clicked through on the **production build** |
| 3 | **It can be found** | `seo-audit`: content in the server HTML, every route in the sitemap, robots open, site URL set, unique metadata, JSON-LD validating |
| 4 | **It is fast** | measured Lighthouse (mobile): LCP ≤ 2.5s, CLS ≤ 0.1, INP ≤ 200ms; 60fps motion on a mid-range phone |
| 5 | **It is usable by everyone** | keyboard pass, visible focus, reduced-motion honoured, AA contrast, 44px targets, no 320px overflow |
| 6 | **Nothing leaks** | secrets server-only, `.env` ignored, `.env.example` complete, production vars actually set |
| 7 | **It deploys** | production env vars, domain + HTTPS, migrations run, a real page/form/image verified live |

## The ones that actually fail

- **Dev-server-only checks.** Dev hides hydration errors, prerender gaps and
  asset-path mistakes. Gate 2 is not done until the production build has been
  clicked through.
- **A missing sitemap entry.** Routes get added; the sitemap does not. Cross-check
  the route files against it every time.
- **The site URL unset in production.** Every canonical and OG URL silently
  resolves to localhost.
- **Staging `noindex` or a `disallow: /` surviving launch.** Check twice; it is
  the most expensive one-line mistake in this list.
- **A secret on a stack with no server.** Everything in the bundle is public —
  if there is a key in the repo, it is already leaked.
- **A site replacing a live one, with an incomplete redirect map.** Stop and
  finish it ([[site-migration]]).

## Reporting

Each gate as **passed** / **failed-and-fixed** / **not-verified-because**, plus
the measured performance numbers. Then a [[changelog]] entry for the launch.

## Related

[[qa-verification]] · [[seo-aeo]] · [[site-migration]] · [[optimize-3d-scene]]
