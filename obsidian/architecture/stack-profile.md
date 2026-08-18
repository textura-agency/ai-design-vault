---
tags: [architecture, stable, decision]
updated: 2026-08-18
---

# The Stack Profile

`.claude/stack.json` is **this project's shape**, in machine-readable form. It is
the single source of truth for paths, packages and commands, and it is what makes
one kit work in any framework. ADR: [[decisions-log]] ADR-0007.

> [!important] The habit that matters
> **Resolve every path and package name from `stack.json`.** The vault's examples
> are illustrations — `src/app/page.tsx` in a note does not mean this project has
> one. Reading a path out of documentation is the single most common way an agent
> writes a file into the wrong place here.

## What reads it

| Reader | Uses |
|---|---|
| `.claude/scripts/verify.sh` | every path, extension, binding, capability and convention — it decides which checks run |
| `.claude/scripts/hooks/*` | `adapted`, `framework.name` — the session-start guidance |
| Skills | `commands.*`, `paths.*`, `bindings.*` instead of naming a framework |
| Rules | their `paths:` frontmatter is retargeted from it by `/adapt` |
| You | before writing any file |

## The field groups

Full schema with descriptions: `.claude/stack.schema.json`.

| Group | What it answers |
|---|---|
| `framework` | which framework, which version, **which render model** |
| `language`, `packageManager` | is `any` checkable; which command prefix |
| `paths` | where routes, views, components, styles, assets, server code, env and protected zones live |
| `extensions` | which file types are source (`.tsx`, `.vue`, `.svelte`, `.astro`…) |
| `bindings` | the concrete package or API for motion, text motion, scroll, styling, image, link, router, metadata, validation, and the public env prefix |
| `capabilities` | what the framework can do — SSR, server components, file routing, API routes, image optimisation, islands |
| `conventions` | which kit conventions are on; switching one off needs an ADR |
| `commands` | verbatim shell commands, package manager included |
| `notes` | anything the fields cannot express |

### `renderModel` deserves attention

It changes what is true about the project more than the framework name does:

| Value | Consequences |
|---|---|
| `server-components` / `ssr` | secrets are safe server-side; content reaches crawlers; server-first rule applies |
| `ssg` | same crawlability, no runtime server — data is fetched at build time |
| `islands` | content is server-rendered, but each interactive island is a separate hydration root — motion state does not cross them for free |
| `spa` | **no server, no secrets, no crawlable content without prerendering.** Half the SEO skill's findings collapse into this one |

## Keeping it true

A profile that lies is worse than no profile: `verify.sh` skips checks silently
and agents write files into paths that no longer exist. So:

- Moved a directory, added a package, renamed a script → **update the profile in
  the same turn.** The `Stop` hook asks; the `vault-librarian` agent can do it.
- After a framework upgrade or migration → **re-run `/adapt`.** Majors rename
  APIs (a middleware file, a metadata export, an env prefix); the profile is
  where that gets corrected once.
- `verify.sh` prints its profile header on every run — if that header surprises
  you, fix the profile before trusting the result.

## Resolved profile

> [!todo] Filled in by `/adapt`
> Until then this project has `"adapted": false` and only the universal checks
> run. Replace this block with the real values.

**Framework:** _(id, name, version, render model)_
**Language / package manager:** _(ts | js, npm | yarn | pnpm | bun)_

| Path | Value |
|---|---|
| source | |
| routes | |
| views | |
| components | |
| styles | |
| assets / static root | |
| server | |
| env | |
| protected | |

| Binding | Value |
|---|---|
| styling | |
| motion | |
| text motion | |
| smooth scroll | |
| image / link / router | |
| metadata | |
| validation | |
| public env prefix | |

**Commands:** install · dev · build · start · lint · typecheck · test

**Conventions switched off:** _(none, or which and why — link the ADR)_

**Judgement calls made during adaptation:** _(what was ambiguous, what was chosen,
what was created — e.g. a `views/` directory that did not exist)_

## Related

[[adapt-stack]] · [[folder-structure]] · [[tech-stack]] · [[system-overview]]
