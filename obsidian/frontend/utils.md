---
tags: [frontend, catalog, wip]
updated: 2026-08-18
---

# Utility Catalog

Pure functions — no side effects, no framework imports, trivially testable.
**Filled in as the project is built.**

## Maths & animation

| Function | Signature | Purpose |
|---|---|---|
| `clamp` | `(v, min, max) => number` | bound a value |
| `lerp` | `(a, b, t) => number` | linear interpolate |
| `mapRange` | `(v, inMin, inMax, outMin, outMax) => number` | remap a range |

## Layout & viewport

| Function | Purpose |
|---|---|
| large-viewport helper | `lvh`/`lvw` sizing that survives a collapsing mobile URL bar — for canvases, **not** for layout |
| `scrollTo` | the one programmatic scroll entry point — [[smooth-scroll]] |

## SEO

| Function | Purpose |
|---|---|
| metadata generator | per-route metadata — [[seo-metadata]] |
| structured-data builder | the JSON-LD graph |

## Rules

- Pure: same input, same output, no DOM writes, no module state.
- No framework imports — a util that needs one is a hook.
- Named exports, one concern per file, grouped by domain.

## Related

[[folder-structure]] · [[component-conventions]]
