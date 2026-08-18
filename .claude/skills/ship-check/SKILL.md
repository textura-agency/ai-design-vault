---
name: ship-check
description: Pre-launch gate — build, mechanical rule checks, SEO and metadata completeness, performance budget, accessibility, env and secret hygiene, and the deploy steps for whatever host this project targets. Use when the user says "ready to ship", "deploy this", "launch checklist", "is this production ready", or before handing a site to a client.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch
---

# Ship check

Run in order. Anything unchecked is stated as unchecked in the summary — never
assume a pass. Every command comes from `.claude/stack.json → commands`.

## 1. It builds and it obeys the rules

```bash
.claude/scripts/verify.sh        # zero FAILs
node -e 'const c=require("./.claude/stack.json").commands;console.log([c.lint,c.typecheck,c.build].filter(Boolean).join("\n"))'
```

Run each printed command. The build must pass with no warnings you cannot explain.

## 2. It is correct

Run the `qa-verify` skill across the site — every route, every breakpoint. Then
click through the **production build**, not the dev server (`commands.build` then
`commands.start`, or a preview deploy). Dev servers hide hydration errors,
prerender gaps and asset-path mistakes.

## 3. It can be found

Run the `seo-audit` skill. Non-negotiable before launch:

- the render model actually delivers content to crawlers (view-source, not devtools)
- every public route is in the sitemap
- robots allows crawling; no staging `noindex` survives
- the site URL variable is set in the production environment
- unique title + description per route; OG image resolves absolutely
- `Organization` + `WebSite` JSON-LD renders and validates
- if this replaces an existing site → the `site-migration` redirect map is live
  and verified

## 4. It is fast

Measure, do not guess — Lighthouse on the deployed URL, mobile profile.

- LCP ≤ 2.5s, CLS ≤ 0.1, INP ≤ 200ms
- Hero image priority-loaded; every image sized; fonts self-hosted or preloaded
- Client JS per route is justified — nothing hydrating that did not need to
- If a WebGL/three.js scene exists → the `optimize-3d-scene` skill first
- Motion holds 60fps on a mid-range phone, not just a laptop

## 5. It is usable by everyone

- Keyboard-only pass through every interactive element; focus always visible
- `prefers-reduced-motion` honoured — content readable with motion off
- Contrast AA; alt text everywhere; landmarks named
- 44px touch targets; no horizontal scroll at 320px

## 6. Nothing leaks

```bash
grep -rniE "sb_secret|service_role|sk_live|BEGIN (RSA|PRIVATE)" "$(node -p 'require("./.claude/stack.json").paths.source')" .env.example
git log --oneline -20            # no secrets in history
```

- Every secret is server-only and read through the validated env module; nothing
  sensitive carries `bindings.envPublicPrefix`
- On an SPA/static stack there is **no server** — every value in the bundle is
  public. If a "secret" exists in this repo, it is already leaked; move the call
  behind a serverless function or a proxy before launch.
- `.env` is gitignored; `.env.example` documents every key with placeholder values
- Every production env var is actually set on the host — a missing one should
  fail the validated parse at boot, which is the intended behaviour, so check
  before launch rather than after

## 7. Deploy

Use whatever the project already targets — check for a platform config file
(`vercel.json`/`vercel.ts`, `netlify.toml`, `wrangler.toml`, a Dockerfile, a CI
workflow) before proposing a host. Confirm after deploying:

- production env vars set for the Production environment, not just Preview
- custom domain + HTTPS resolving, `www`/apex normalised one way
- if a CMS or database is installed: migrations have run against the production
  database, and destructive auto-sync (`push`) is off in production
- a real page loads, a form submits, an image from storage renders

## 8. Hand over

Summarise: what was checked and passed, what failed and was fixed, what could not
be verified and why, plus the measured performance numbers. Update
`obsidian/meta/changelog.md` with the launch.
