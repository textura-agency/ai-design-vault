---
tags: [frontend, motion, stable, stack-specific]
updated: 2026-08-18
---

# Motion Bindings

Which library implements [[motion-system]]'s contract, per framework. This
project's choice is `stack.json → bindings.motion`. ADR: [[decisions-log]] ADR-0002.

## The invariant a binding must satisfy

Any library qualifies if it can do all five:

1. **Spring physics** — mass/tension/friction (or stiffness/damping), not a
   duration and an easing curve.
2. **Interruptible** — retargeting mid-flight resolves smoothly from the current
   value and velocity.
3. **Imperative per-frame updates** — values can be driven from the shared ticker
   and from a scroll progress number, not only from declarative state changes.
4. **Transform/opacity output** without forcing layout — writes to style or a
   compositor-friendly property.
5. **Runs where the project runs** — importable in the framework's client
   boundary, tree-shakeable, no hard peer conflicts.

A library that only does time-based keyframes fails (1) and is not a candidate,
whatever else it offers.

## Defaults per stack

| Stack | Motion | Text motion | Smooth scroll |
|---|---|---|---|
| Any React (Next, Vite, React Router/Remix, TanStack Start, Astro React islands) | `@react-spring/web` | `spring-text-engine` | `lenis` |
| Svelte 5 / SvelteKit | `svelte/motion` (`Spring`) — built in | recipe | `lenis` |
| Vue 3 / Nuxt | `motion-v`, or `@vueuse/motion` | recipe | `lenis` |
| Solid / SolidStart | `motion` (`@motionone/solid`) | recipe | `lenis` |
| Astro with no framework, plain HTML, web components | `motion` | recipe | `lenis` |
| Angular | `motion` (not Angular Animations — time-based) | recipe | `lenis` |

`recipe` = the split-and-stagger implementation in [[text-motion]], built once on
the motion binding.

`lenis` is framework-agnostic (a vanilla core with optional wrappers) which is
why it is the default everywhere — but it is **optional**. Smooth scroll is a
design decision, not a requirement, and it must always be driven from the shared
ticker rather than its own loop.

> [!warning] Verify the API before writing code
> These package APIs move. Check the installed version's own docs — a spring
> helper renamed between majors is exactly the kind of thing training data gets
> wrong confidently.

## The rule that outranks the defaults

**A binding already installed wins.** Two animation libraries in one codebase is
a hard-rule violation and `verify.sh` FAILs it. If a project arrives with
something workable already in place, use it and record it — consistency beats
preference. If what is there fails the invariant (a keyframe-only library),
that is a migration to propose, not a second library to add.

## Choosing when nothing is installed

1. Check the framework's **built-in** option first — Svelte ships springs; using
   the platform beats adding a dependency.
2. Otherwise take the default from the table.
3. Weigh bundle cost against what the site actually does. A site with three
   reveals does not need the largest option.
4. **Ask the user before installing.** Say what it is, what it costs, and what it
   changes.

## Recording the choice

`stack.json → bindings.motion` / `textMotion` / `smoothScroll`, plus
[[tech-stack]], a [[changelog]] entry, and an ADR covering what was chosen and
what was rejected. The next person should not have to re-derive it.

## Related

[[motion-system]] · [[text-motion]] · [[stack-profile]]
