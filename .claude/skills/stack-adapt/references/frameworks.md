# Framework mapping reference

Starting points for `.claude/stack.json`, per stack. **Confirm every value against
the actual repo** — a project may lay itself out however it likes, and the repo
wins over this table. Versions move; where a row names an API, verify it against
the installed version before writing code.

Columns used below map 1:1 onto `stack.schema.json`.

> `paths.routeEntryGlob` tells `verify.sh` which files under `paths.routes` are
> route entries, for the route→view delegation check. Leave it empty where the
> framework has a fixed entry filename (`page.tsx`, `+page.svelte`); set it where
> **any** file in the routes directory is a route (Astro, Nuxt).

---

## Next.js — App Router (`framework.id: nextjs`)

| Field | Value |
|---|---|
| renderModel | `server-components` |
| paths.routes | `src/app` (or `app/`) |
| paths.views | `src/views` — create it; routes must stay thin |
| paths.styles | `src/app/globals.css` |
| paths.staticRoot / assets | `public` / `public/assets` |
| paths.server | `src/app/api` (`route.ts` handlers) |
| paths.env | `src/env.ts` |
| bindings.image / link / router | `next/image` / `next/link` / `next/navigation` |
| bindings.metadata | `next-metadata` (`metadata` / `generateMetadata` exports) |
| envPublicPrefix | `NEXT_PUBLIC_` |
| capabilities | ssr, serverComponents, fileRouting, apiRoutes, imageOptimization, metadataApi all true |

**Traps.** `next/router` is the Pages Router — App Router uses `next/navigation`.
Middleware was renamed in Next 16 (`middleware.ts` → `proxy.ts`, exporting
`proxy`, Node runtime) — check the installed major before writing either.
Reading `headers()`/`cookies()` opts a route out of static rendering.

## Next.js — Pages Router

As above except `paths.routes: src/pages`, `bindings.router: next/router`,
`bindings.metadata: next/head`, `capabilities.serverComponents: false`,
`paths.server: src/pages/api`.

## React Router v7 (framework mode) / Remix (`react-router`, `remix`)

| Field | Value |
|---|---|
| renderModel | `ssr` |
| paths.routes | `app/routes` |
| paths.views | `app/views` — create it |
| paths.styles | `app/styles/app.css` (or wherever the root imports from) |
| paths.staticRoot | `public` |
| paths.server | route modules themselves (`loader` / `action`) — record the routes dir |
| bindings.image / link / router | `native` / `react-router` `Link` / `react-router` |
| bindings.metadata | route `meta` export |
| envPublicPrefix | none by default — server env stays server-side; anything the client needs is passed through a `loader`. Record `null` and note it. |

**Traps.** `loader`/`action` run server-side only — secrets are safe there and
must not be imported into a component module. A `null` public prefix makes
`verify.sh` skip the env check; note in `notes[]` that env discipline is enforced
by the loader boundary instead.

## Vite + React (SPA) (`vite-react`)

| Field | Value |
|---|---|
| renderModel | `spa` |
| paths.routes | `src/routes` if react-router is used, else `null` |
| paths.views | `src/views` |
| paths.styles | `src/styles/globals.css` (or `src/index.css`) |
| paths.staticRoot | `public` |
| paths.server | `null` — `capabilities.apiRoutes: false` |
| bindings.image / link | `native` / `react-router` `Link` or `native` |
| bindings.metadata | `react-helmet-async`, or manual `document.title` |
| envPublicPrefix | `VITE_` |

**Traps.** No server means **no secrets in this repo at all** — every value in the
bundle is public. Say so in `notes[]`. SEO depends on prerendering; without it a
marketing site ships an empty `<div id="root">` to crawlers, and the whole
`seo-audit` skill has one finding: "this route renders nothing without JS".

## TanStack Start (`tanstack-start`)

`renderModel: ssr`, `paths.routes: src/routes`, views `src/views`, server
functions colocated, `envPublicPrefix: VITE_`. Confirm the router/metadata API
against the installed version — it moves quickly.

## Astro (`astro`)

| Field | Value |
|---|---|
| renderModel | `ssg` (or `hybrid` with an adapter) |
| paths.routes | `src/pages` |
| paths.views | `src/views` — create it; `.astro` pages delegate to it |
| paths.components | `src/components` |
| paths.styles | `src/styles/global.css` |
| paths.staticRoot / assets | `public` / `public/assets` |
| paths.server | `src/pages/api` (endpoints) — only with an adapter |
| bindings.image | `astro:assets` `<Image />` |
| bindings.link | `native` (plain `<a>`) |
| bindings.metadata | head tags in the layout component |
| envPublicPrefix | `PUBLIC_` |
| capabilities | islands: true, serverComponents: false, metadataApi: false |
| paths.routeEntryGlob | `["*.astro"]` — **any** file in `src/pages` is a route, not just `index` |

**Traps.** Motion lives in **islands**. Every `client:*` component is a separate
hydration root with its own module instance — a shared rAF ticker or scroll store
must live in one island (or a plain `<script>` in the layout) or you get N of
them. Prefer `client:visible` for below-the-fold motion. `.astro` files are not
components in the JSX sense; `extensions.component` should list `.astro` plus
whichever framework files the islands use.

## Nuxt (`nuxt`)

| Field | Value |
|---|---|
| renderModel | `ssr` |
| paths.routes | `pages` (or `app/pages` in Nuxt 4 layout) |
| paths.views | `views` under the same root — create it |
| paths.styles | `assets/css/main.css` |
| paths.staticRoot / assets | `public` / `public/assets` |
| paths.server | `server/api` |
| bindings.image / link / router | `@nuxt/image` `<NuxtImg>` / `<NuxtLink>` / `vue-router` + `navigateTo` |
| bindings.metadata | `useHead` / `useSeoMeta` / `definePageMeta` |
| envPublicPrefix | `NUXT_PUBLIC_` (bound to `runtimeConfig.public`) |
| paths.routeEntryGlob | `["*.vue"]` — any file in `pages` is a route |

**Traps.** Nuxt 4 moved the app directory; check which layout the project uses
before recording paths. Server-only secrets belong in `runtimeConfig` (not
`public`), read via `useRuntimeConfig()` in `server/`. Auto-imports mean a missing
import is not always an error — do not rely on import lines to prove usage.

## SvelteKit (`sveltekit`)

| Field | Value |
|---|---|
| renderModel | `ssr` |
| paths.routes | `src/routes` |
| paths.views | `src/lib/views` — create it; `+page.svelte` delegates to it |
| paths.styles | `src/app.css` |
| paths.staticRoot / assets | `static` / `static/assets` |
| paths.server | `src/routes/api` (`+server.ts`), plus `+page.server.ts` |
| bindings.image | `@sveltejs/enhanced-img` if installed, else `native` |
| bindings.link | `native` — SvelteKit intercepts plain `<a>` |
| bindings.router | `$app/navigation` |
| bindings.metadata | `<svelte:head>` |
| envPublicPrefix | `PUBLIC_` (`$env/static/public`; secrets via `$env/static/private`) |
| paths.routeEntryGlob | `["+page.*"]` |

**Traps.** `bindings.link: native` is correct here — do not flag plain `<a>`.
Svelte 5 ships spring physics in `svelte/motion` (`Spring`), so the motion binding
is usually built in; earlier versions used the `spring()` store. Check the
installed major.

## Vue + Vite (SPA) (`vue-vite`)

`renderModel: spa`, routes via `vue-router` (`src/router`), views `src/views`
(Vue's own convention — use it), styles `src/assets/main.css`,
`envPublicPrefix: VITE_`, `apiRoutes: false`. Same no-secrets and prerendering
warnings as Vite + React.

## SolidStart / Qwik / Angular

Fill in from the framework's own docs; the shape is the same. Notable:

- **SolidStart** — `src/routes`, `envPublicPrefix: VITE_`, fine-grained
  reactivity means motion values do not need memoisation the way React does.
- **Qwik** — resumability: a component's handler may never execute eagerly. A
  render-loop ticker needs an explicit eager task; record it in `notes[]`.
- **Angular** — `src/app`, standalone components; keep Angular Animations *out*
  in favour of the spring binding, per hard rule 1, and note it.

## Eleventy / Hugo / plain HTML (`eleventy`, `hugo`, `vanilla`)

| Field | Value |
|---|---|
| renderModel | `ssg` |
| paths.routes | the template/page directory (`src`, `content`, or the site root) |
| paths.views | a per-page JS module directory, e.g. `src/js/views` |
| paths.styles | `src/css/tokens.css` (or wherever the token file lives) |
| paths.server | `null` |
| bindings.image / link | `native` / `native` |
| bindings.metadata | `manual` (head partial) |
| envPublicPrefix | `null` — everything is build-time |
| capabilities | fileRouting true, ssr/serverComponents/apiRoutes false |

**Traps.** Without a bundler, the motion binding must be loadable as an ES module
from a CDN or vendored locally. `conventions.routesDelegateToViews` still applies:
a page template includes markup, a JS module owns behaviour.

---

## Deciding `bindings.motion`

Full guidance and the invariant every binding must satisfy:
`obsidian/frontend/motion-bindings.md`. Short version:

| Stack | Default binding | Text motion |
|---|---|---|
| Any React | `@react-spring/web` | `spring-text-engine` |
| Svelte 5 | `svelte/motion` (`Spring`) | `recipe` |
| Vue 3 / Nuxt | `motion-v`, or `@vueuse/motion` | `recipe` |
| Solid | `motion` (`@motionone/solid`) | `recipe` |
| Astro islands | the island framework's binding | as that framework |
| Vanilla / no framework | `motion` | `recipe` |

`recipe` means the split-text-and-stagger recipe in
`obsidian/frontend/text-motion.md`, built on the motion binding — not a bespoke
per-project text animator.

**Never install a binding without asking.** If one is already present, use it
even if it is not the default — a second motion library is a hard-rule violation,
and the rule outranks the preference.
