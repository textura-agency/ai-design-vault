---
tags: [workflow, performance, 3d, stable]
updated: 2026-08-18
---

# Workflow — Optimise a 3D Scene

When the project renders a three.js or raw WebGL scene and the request is about
performance, jank, or shipping readiness: **invoke the `optimize-3d-scene` skill
first and follow its order.** Do not improvise one. Hard rule 12.

The skill carries the full procedure and `references/patterns.md` carries
working implementations of every pattern. This note is the map.

## Why an order at all

A 3D scene has half a dozen plausible-looking fixes, and their costs differ by
orders of magnitude. Reaching for the interesting one (rewriting a shader) before
the cheap ones (clamping DPR, gating the render loop) is how a day disappears for
2fps. The skill's order is cheapest-and-highest-impact first, and it was measured
on phones rather than laptops.

## The shape of the fix, in brief

| Stage | The idea |
|---|---|
| 0 — Audit | measure before touching anything: draw calls, programs, memory, real frame timings on a **production build** |
| 1 — Don't ship it to everyone | tier by device; strip the scene for bots and low-end devices; lazy-load the chunk |
| 2 — Clamp DPR | a phone rendering at DPR 3 draws nine times the fragments of DPR 1 |
| 3 — Prewarm | compile every shader and upload every texture at load, so nothing stalls mid-scroll |
| 4 — Gate the loop | render only when the scene is on screen and the tab is visible; subscribe to the **shared ticker**, never a private rAF |
| 5 — Budget the frame rate | 30fps on low tiers beats a stuttering 60 |
| 6+ | particles, lights, post-processing, GPU-side scroll transforms, compressed assets, canvas sizing |

## Where it meets the rest of the kit

- **The shared ticker is the same one** the motion primitives use (ADR-0005). A
  scene with its own forever-rAF is the single largest source of scroll jank on a
  page that also animates.
- **Canvas sizing uses large-viewport units** so a collapsing mobile URL bar does
  not reallocate the framebuffer mid-scroll — that unit is for the canvas, **not**
  the layout.
- **Bot/reduced-motion paths** must leave the content readable — a static poster,
  not an empty section ([[seo-metadata]]).
- **Framework glue** (lazy boundary, island, server-side UA read) comes from
  [[stack-profile]]; the scene code itself is framework-independent.

## Related

[[motion-system]] · [[ship]] · [[qa-verification]]
