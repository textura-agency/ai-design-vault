---
paths:
  - "src/**/*.tsx"
  - "src/**/*.jsx"
  - "src/**/*.vue"
  - "src/**/*.svelte"
  - "src/**/*.astro"
  - "app/**/*.tsx"
  - "app/**/*.jsx"
  - "components/**/*"
  - "views/**/*"
  - "pages/**/*"
description: Motion rules — springs only, through this project's binding, with one narrow CSS exception
---

# Motion in this project

Full notes: `obsidian/frontend/motion-system.md` · `obsidian/frontend/text-motion.md`
The binding to use is `bindings.motion` / `bindings.textMotion` in `.claude/stack.json`.

- **All real motion is spring-based**, through that binding. Text animates through
  the text binding, never through a hand-rolled per-character animator.
- **Banned:** `@keyframes`, and **any second animation library**. If the project
  already has a binding, that is the binding — preference does not outrank the
  rule. Adding one alongside it is a hard-rule violation, and `verify.sh` FAILs.
- **The only CSS exception:** `transition-*` utilities for simple discrete state
  changes — hover/focus colour, opacity, border, a few-px nudge. All three
  conditions must hold, or it is a spring:
  1. token-backed timing — `duration-[var(--duration-fast)] ease-entrance`
  2. `transition-*` only, never `@keyframes`
  3. lives in the class attribute, never in a CSS file

  In Tailwind v4 `duration-fast` as a bare class does **nothing** — there is no
  `--duration-*` namespace. Always `duration-[var(--duration-fast)]`.

## Picking a primitive

| Need | Primitive |
|------|-----------|
| Reveal on scroll-into-view | `Inview` (`mode="once"`) |
| Continuous scroll motion (parallax, progress) | `SpringTrigger` (`mode="scrub"`) |
| Snap at a scroll point | `SpringTrigger` (`mode="toggle"`) |
| Hover | `Hover` — disabled on touch |
| Smooth swap when content changes | `Handle` |
| Heading / copy reveal | the text binding — see the text-motion note |

## Non-negotiables

- **Transform and opacity only.** Animating width/height/top/margin puts layout
  on every frame.
- **One shared render loop.** Subscribe to the app-wide ticker; never start a
  `requestAnimationFrame` per component.
- **Content exists regardless of motion state.** Reveals change appearance, never
  presence — that is what keeps them crawlable and accessible.
- **`prefers-reduced-motion`** jumps to the end state, with everything readable.
- Every animation wrapper takes a semantic element (`tag` / `as`) — pass the real
  one, never a `div`.
- Styling classes stay in `className`/`class`; never pass class names into spring
  `from`/`to` values, and keep both ends of a value the same type.
