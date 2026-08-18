---
tags: [frontend, scroll, stable]
updated: 2026-08-18
---

# Smooth Scroll

Smooth scrolling is **optional** — a design decision, not a requirement. When the
project uses it, it is `stack.json → bindings.smoothScroll` (Lenis by default,
because its core is framework-agnostic).

## The shape

Two pieces, always:

| Piece | Role |
|---|---|
| A scroll layer wrapping the app | owns the library instance; renders children untouched so content stays server-rendered |
| A small store | exposes the instance and the scroll state (progress, direction, locked) to components |

The wrapper splits into a **server-safe shell** (renders `{children}`) and a
**client-only controller** that renders nothing and owns the instance. That split
is what keeps smooth scroll from turning the whole page into client-rendered
markup.

## Rules

1. **The library does not run its own render loop.** It is driven from the shared
   ticker (`raf(time)` inside the tick) — one loop for the page, always
   (ADR-0005).
2. **Scroll locking is a store action.** Opening a modal calls `stop()`; closing
   calls `start()`. Never mutate `overflow` from inside a component — two
   components doing that will fight, and the loser leaves the page unscrollable.
3. **Hash links go through the controller**, so an in-page anchor animates rather
   than jumping. Anchor targets need stable `id`s ([[html-semantics]]).
4. **Reset scroll on mount / route change** deliberately — restoring or resetting
   position is a decision, and doing neither produces the "new page starts
   halfway down" bug.
5. **Respect reduced motion.** Smooth scroll is motion: with
   `prefers-reduced-motion: reduce`, fall back to native scrolling.
6. **Never fight the platform.** Smooth scroll interacts badly with sticky
   positioning, scroll-driven CSS, iOS URL-bar resize and in-page find. If a
   section breaks, the fix is usually to stop overriding scroll for that section,
   not to add another workaround.

## The store

Exposed through the framework's own state primitive, with:

| Field | Purpose |
|---|---|
| the instance | the live library object, or `null` before mount |
| `isEnabled` | is scrolling currently allowed |
| `start()` / `stop()` | toggle scroll (modal open/close) |
| progress / direction | derived values components read for motion |

Only the controller writes; everything else reads.

## Programmatic scrolling

One helper (`scrollTo(target, smooth?)`) that accepts an element id or a numeric
offset, handles the disabled-scroll case, and is the only way components move the
page. No direct `window.scrollTo` calls scattered around.

## Related

[[motion-system]] · [[data-flow]] · [[system-overview]]
