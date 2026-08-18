---
tags: [frontend, stable]
updated: 2026-08-18
---

# Component Conventions

Rules for writing and placing components. This note is canonical; the addresses
are in [[stack-profile]].

## Placement

| Folder | What goes here |
|---|---|
| primitives (`components/ui/`) | design-system primitives — stateless, no provider deps (Button, Input, Card) |
| shared (`components/common/`) | shared infrastructure — may depend on providers (cookie banner, skeletons, grid) |
| motion (`components/animation/`) | the motion primitives — protected if listed in `paths.protected` |
| views (`paths.views`) | page-level components — one per route |
| next to the feature | feature-specific components — **not** in the shared folders |

See [[folder-structure]] for the full tree.

## Structure rules

- **Named exports only** — no default exports from component files (where the
  framework allows it; some require a default export for route files, which is
  fine — that is the framework's API, not a component).
- One component per file, unless tightly-coupled sub-components warrant an index.
- Always define and export **typed props**. No `any`.
- Expose a DOM ref where a parent may need one.
- **Server-first**: mark a component client-side only when it needs event
  handlers, browser APIs, reactive state or motion. Never mark a layout, page or
  view client to dodge a boundary — split a leaf wrapper instead.
- Keep components focused and under ~150 lines; split when they grow.
- A repeated visual pattern becomes a **component**, not a global CSS class
  (ADR-0012, see [[design-system]]).

## Data rules

- **No hardcoded content** inside components — text, numbers and media come from
  props or hooks.
- Placeholder data → `data/mocks/<page>.*`, passed via props. Never imported
  into a component file directly.
- **Site content assets** → `paths.assets/<section>/`, one folder per section,
  referenced by absolute path. Favicons/icons/OG/manifest stay at the static root.
- Every async-data component handles `loading` / `error` / `empty` with skeletons
  mirroring the final layout.
- Data-fetching lives in the route or a hook — never in a presentational
  component ([[data-flow]]).

## Accessibility & semantic markup

The full rulebook is [[html-semantics]] (hard rule 10). In short:

- Native elements over `div`s — real `button` / `a` / `nav` / `main` / `section`.
- One `<h1>`; never skip heading levels; the tag carries meaning, the class
  carries looks.
- Name landmarks and icon-only controls; visible focus; keyboard-operable.
- Images: meaningful `alt`; decorative images `alt=""`.
- Pass the correct semantic element to every motion primitive.

## Motion in components

Use the [[motion-system]] primitives with the semantic `tag`. Styling classes go
on `className`/`class`, never into spring `from`/`to` values. Subscribe per-frame
work to the shared ticker, never to a fresh `requestAnimationFrame`.

## Code quality

- Run the project's lint command before finishing (`commands.lint`).
- Prefer early returns over nested conditionals.
- Comments explain *why*, never narrate *what*. No `console.log` in committed code.
- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`.

## Related

[[design-system]] · [[motion-system]] · [[new-page]] · [[templates/component-note]]
