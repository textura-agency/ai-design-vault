---
tags: [frontend, catalog, wip]
updated: 2026-08-18
---

# Hooks / Composables Catalog

Custom hooks (React), composables (Vue), runes/stores (Svelte) — whatever this
framework calls its reusable reactive logic. **Filled in as the project is
built.** Template: [[templates/hook-note]].

## Motion & loop

| Name | Returns | Notes |
|---|---|---|
| ticker subscription | `unsubscribe` | the one rAF loop — [[motion-system]] |
| window size | `{ width, height }` | one shared debounced resize listener, never one per component |
| in-view | `ref`, `isInView` | one `IntersectionObserver`, not a scroll listener |

## Scroll

| Name | Returns | Notes |
|---|---|---|
| scroll store | instance, progress, `start`/`stop` | [[smooth-scroll]] |

## Data

| Name | Returns | Notes |
|---|---|---|
| | | Data fetching lives here or at the route — never in a presentational component |

## Rules

- One concern per hook; compose rather than adding options.
- Anything per-frame subscribes to the shared ticker.
- Clean up on unmount — listeners, observers, subscriptions. A leak here shows up
  as jank three pages later.

## Related

[[data-flow]] · [[motion-system]] · [[component-conventions]]
