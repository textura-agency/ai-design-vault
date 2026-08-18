---
tags: [frontend, motion, stable]
updated: 2026-08-18
---

# Motion System

The core of this kit. **Every motion is spring-based**, through the single binding
in `stack.json → bindings.motion`. CSS keyframes and any second animation library
are **banned**. ADR: [[decisions-log]] ADR-0002, ADR-0008.

> [!note] One narrow CSS exception (ADR-0013)
> CSS `transition-*` for **simple discrete state changes only** — hover/focus
> colour, opacity, border, underline, small decorative nudges — with token-backed
> timing. Anything scroll-driven, revealing, layout-affecting, staggered or
> interruptible is a spring. See [[design-system]].

## Why springs

A spring is defined by physics, not by a duration. It can be interrupted
mid-flight and will resolve smoothly from wherever it is, it carries velocity
between states, and it never needs an easing curve chosen by feel. Time-based
keyframes cannot do any of that — which is why an animation "long enough to need
keyframes is long enough to deserve a spring".

## The contract

The kit specifies **primitive names, props and semantics**; each project builds
them on its own binding (ADR-0008). This is what makes a page written in one
framework read the same in another.

| Primitive | Trigger | Use for |
|---|---|---|
| `Inview` | element enters the viewport | fade/slide-in reveals |
| `SpringTrigger` | scroll progress across a range | parallax, scrub, snap-at-point |
| `Hover` | pointer enter/leave | hover motion (off on touch) |
| `Handle` | children/content change | smooth enter/exit on a swap |

Text does **not** use these — see [[text-motion]].

### Shared props

| Prop | Meaning |
|---|---|
| `tag` | the semantic element to render (`section`, `h2`, `li`…) — use the real one |
| `from` / `to` | spring start / end states — animatable values only |
| `config` | spring physics (`tension`/`friction`, or the binding's equivalent) |
| `mode` | `once` / `always` / `forward`, or `scrub` / `toggle` for scroll |
| `delayIn` / `delayOut` | ms before enter / exit — staggers are increments of these |
| `disableOnMobile` | opt out per instance below the mobile breakpoint |
| `className` / `innerClassName` | styling stays in classes, never in `from`/`to` |

Where a framework has no children-wrapping component model, the same names appear
as directives, actions or hooks — the vocabulary does not change.

### Modes

- **`Inview` / `Spring`:** `once` (play once, stay), `always` (reverse on leave),
  `forward` (only on downward scroll).
- **`SpringTrigger`:** `scrub` (interpolate with scroll), `toggle` (snap at the
  trigger point).

## Choosing the right primitive

| Need | Use |
|---|---|
| Element fades/slides in when scrolled into view | `Inview` `mode="once"` |
| Element moves continuously with scroll (parallax) | `SpringTrigger` `mode="scrub"` |
| Element snaps to a state at a scroll point | `SpringTrigger` `mode="toggle"` |
| Hover motion — physical, or animating transforms | `Hover` |
| Hover/focus **colour, opacity or border** only | plain CSS `transition-*` (ADR-0013) |
| Just a 0–1 scroll progress value | `SpringTrigger`'s progress output |
| Heading / copy reveal | the text binding — [[text-motion]] |

## The shared render loop

Every per-frame subscriber goes through **one** `requestAnimationFrame` loop
(ADR-0005). Contract:

```
subscribe(callback, { framerate? }) -> unsubscribe
  callback({ time, delta, frame })
```

- Reference-counted: starts on the first subscriber, stops when the last
  unsubscribes. An idle page costs nothing.
- Paused while the tab is hidden.
- Drives the smooth-scroll library rather than letting it run its own loop.
- One shared, debounced `resize` listener — never one per component.
- Lives at `<source>/lib/animation/ticker.*` and is **not** protected code; it is
  the supported extension point for loop-based motion.

## Scroll trigger positions

One grammar across frameworks: `"<element-edge> <viewport-edge>[±=px]"`.

| Example | Meaning |
|---|---|
| `"top bottom"` | progress 0 when the element top hits the viewport bottom |
| `"bottom top"` | progress 1 when the element bottom hits the viewport top |
| `"top bottom+=200"` | the same, 200px later |
| `"center center"` | element centre meets viewport centre |

## Non-negotiables

- **Transform and opacity only.** Animating `width`, `height`, `top` or `margin`
  runs layout every frame.
- **Content exists regardless of motion state.** Reveals change appearance, never
  presence — that keeps them crawlable ([[seo-metadata]]) and accessible.
- **`prefers-reduced-motion: reduce` jumps to the end state**, with everything
  present, readable and in its final position. Never mid-transition, never hidden.
- **Read layout once per frame, in the loop.** Never in a scroll handler that also
  writes styles — that is a forced reflow on every event.
- **Value types must match** across `from` and `to` — all numbers, or all unit
  strings. Mixing `0` with `'100%'` throws in most spring implementations.
- **Never disable motion globally.** Mobile gating is per instance, via config.

## Global config

A single module (`<source>/lib/motion/config.*`) holds the mobile breakpoint and
per-primitive defaults — `hover` is always disabled on touch. Components opt in
per instance via `disableOnMobile`. Pass a reactive viewport width so the check
re-evaluates on resize rather than reading `window.innerWidth` once.

## Protected zones

If this project vendors its motion primitives, they are listed in
`stack.json → paths.protected`: consume them, wrap them, never edit them
(ADR-0002). `verify.sh` FAILs on a diff there.

## Related

[[motion-bindings]] · [[text-motion]] · [[smooth-scroll]] · [[data-flow]] · [[new-page]]
