---
description: Install or extend the motion layer for this framework
argument-hint: [primitive-or-question?]
---

Motion work: **$ARGUMENTS**

Use the `motion-system` skill. Non-negotiables:

- **Check `bindings.motion` in `.claude/stack.json` first.** A binding that is
  already installed wins, even if it is not the kit's default — a second
  animation library is a hard-rule violation.
- If nothing is installed, propose one from
  `obsidian/frontend/motion-bindings.md` for this framework, say what it costs,
  and **ask before installing**.
- Build the **shared render loop first** — one reference-counted rAF for the
  whole page, paused on a hidden tab, driving the smooth-scroll library if one is
  used. Everything per-frame subscribes to it.
- Then the primitive set — `Inview`, `SpringTrigger`, `Hover`, `Handle` — with
  the **same names and props in every framework** (`tag`, `from`, `to`, `config`,
  `mode`, `delayIn`/`delayOut`, `disableOnMobile`, `className`). That contract is
  what makes a page written here portable.
- Transform and opacity only. Content present regardless of motion state.
  Reduced-motion jumps to the end state. Hover off on touch.
- Text goes through `bindings.textMotion`, built once as a shared component —
  never a bespoke per-section text animator.

Finish by updating `stack.json`, `obsidian/frontend/motion-system.md`,
`tech-stack.md`, the changelog, and an ADR for the binding choice.
