---
name: motion-system
description: Install and wire this kit's motion layer into the host framework — pick the spring binding, build the primitive set (reveal, scrub, hover, handle) against a shared contract, add the single shared render loop, scroll progress triggers, reduced-motion and mobile gating, and the split-text recipe. Use when the project has no motion layer yet, when /adapt reports bindings.motion is null, when a new motion primitive is needed, or when the user says "set up animations", "add the motion system", "why is scrolling janky".
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# The motion layer

This kit's premise: **one motion vocabulary, identical across frameworks**. The
primitives below have the same names, the same props and the same behaviour
whether they are built on `@react-spring/web`, `svelte/motion`, `motion-v` or
plain `motion`. A page written against them reads the same in any stack — which
is the entire point of building it as a contract rather than shipping a library.

Read `obsidian/frontend/motion-system.md` (the contract) and
`obsidian/frontend/motion-bindings.md` (per-framework mapping) before building.

## 0. Before you install anything

Check what already exists:

```bash
cat .claude/stack.json                                  # bindings.motion
grep -rlE "spring|animate|gsap|motion" --include='*.json' package.json
```

- **A binding already installed wins**, even if it is not the kit's default. Two
  animation libraries is a hard-rule violation; personal preference is not a
  reason to add one.
- **No binding installed** → propose one from `motion-bindings.md`, say what it
  costs (bundle size, peer deps) and **ask before installing**.
- Record the answer in `stack.json → bindings.motion` / `textMotion`.

## 1. The shared render loop — build this first

Every per-frame subscriber goes through **one** `requestAnimationFrame` loop.
A page with 20 scroll-driven elements runs one rAF, not 20.

Contract:

```
subscribe(callback, options?) -> unsubscribe
  callback({ time, delta, frame })
  options: { framerate?: number }   // per-subscriber throttle
```

- Reference-counted: starts on the first subscriber, stops when the last
  unsubscribes. An idle page costs nothing.
- Pauses on `document.visibilitychange` (hidden tab renders nothing).
- One debounced `resize` listener shared the same way — never one per component.
- If a smooth-scroll library is in use (`bindings.smoothScroll`), **it drives the
  loop** rather than running its own: call its `raf(time)` from the ticker.

Put it at `<source>/lib/animation/ticker.*`. This file is the supported
extension point — it is not protected code.

## 2. The primitive set

Build these four, plus text. Same names and props in every framework; only the
implementation differs. Where a framework has no children-wrapping component
model, express them as directives/actions/hooks with the same prop names.

| Primitive | Trigger | Use for |
|---|---|---|
| `Inview` | element enters the viewport | reveals — fade/slide in |
| `SpringTrigger` | scroll progress across a range | parallax, scrub, snap-at-point |
| `Hover` | pointer enter/leave | hover motion (off on touch) |
| `Handle` | children/content change | smooth enter/exit on swap |

Shared props — do not rename them per framework:

| Prop | Meaning |
|---|---|
| `tag` | the semantic element to render (`section`, `h2`, `li`…). Never default to `div` |
| `from` / `to` | spring start / end states — animatable values only, no class names |
| `config` | spring physics (`tension`/`friction`, or the binding's equivalent) |
| `mode` | `once` / `always` / `forward` for triggers; `scrub` / `toggle` for scroll |
| `delayIn` / `delayOut` | ms before enter / exit — staggers are increments of these |
| `disableOnMobile` | opt out per instance under the mobile breakpoint |
| `className` / `innerClassName` | styling stays in classes, never in `from`/`to` |

**Rules that hold for all of them:**

- Animate **`transform` and `opacity`** wherever possible. Animating `width`,
  `height`, `top` or `margin` puts layout on every frame.
- The element and its content exist in the DOM regardless of animation state —
  motion changes appearance, never presence. Crawlers and screen readers must see
  the content, and this is what keeps reveals SEO-safe.
- Motion values are numbers or unit strings, and the **same type** on both ends —
  mixing `0` with `'100%'` is a runtime error in most spring implementations.

## 3. Scroll progress

One grammar across frameworks, borrowed from the GSAP convention:

```
"<element-edge> <viewport-edge>[±=px]"
  "top bottom"        progress 0 when the element top reaches the viewport bottom
  "bottom top"        progress 1 when the element bottom reaches the viewport top
  "top bottom+=200"   the same, 200px later
  "center center"     element centre meets viewport centre
```

`SpringTrigger` takes `start` / `end` in this grammar and exposes a 0–1 progress.
`mode="scrub"` interpolates with it; `mode="toggle"` snaps at the trigger point.
Read layout in one place per frame (the ticker), never per element per frame —
that is what turns a scroll page into a layout-thrash machine.

## 4. Text motion

Text does **not** use the primitives above. Use `bindings.textMotion`:

- **React** → `spring-text-engine`. Its traps are hard rule 3; see
  `obsidian/frontend/text-motion.md`.
- **Anything else** → the split-and-stagger recipe in the same note: split into
  line / word / letter slots, one spring per slot with a stagger, a clip wrapper
  when sliding in, and a plain-text copy left in the DOM for crawlers.

Build the recipe **once** as a shared component, not per section.

## 5. Gating — reduced motion and mobile

Both are required, both are per-instance rather than global:

- **`prefers-reduced-motion: reduce`** → skip to the end state. Content readable,
  layout final, no motion. Never leave an element mid-transition or invisible.
- **Mobile** → a single config module (`<source>/lib/motion/config.*`) with the
  mobile breakpoint and per-primitive defaults (`hover` is always disabled on
  touch). Components opt in via `disableOnMobile`. **Never disable motion
  globally** — that is a per-animation decision.

## 6. Verify

```bash
.claude/scripts/verify.sh
```

Then check by hand, because a script cannot:

- one rAF loop in the page (log subscriber count, or breakpoint the ticker)
- scrolling holds 60fps on a mid-range phone, not just a laptop
- with reduced motion on, every piece of content is present and readable
- no animation touching layout properties
- a hidden tab renders nothing

If the project carries a three.js/WebGL scene, the `optimize-3d-scene` skill owns
that half of the frame budget — run it rather than tuning springs.

## 7. Record it

Update `stack.json` (`bindings.motion`, `bindings.textMotion`,
`bindings.smoothScroll`, and `paths.protected` if the primitives should be frozen
as an engine), `obsidian/frontend/motion-system.md` with the primitives you built,
`architecture/tech-stack.md`, the changelog, and an ADR for the binding choice.
