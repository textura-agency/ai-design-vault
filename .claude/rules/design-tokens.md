---
paths:
  - "**/globals.css"
  - "**/global.css"
  - "**/app.css"
  - "**/main.css"
  - "**/tokens.css"
  - "src/style/**/*.css"
  - "src/styles/**/*.css"
  - "assets/css/**/*.css"
description: The three-tier design token convention
---

# Design tokens — three tiers, no skipping

Full note: `obsidian/frontend/design-system.md`. The token file for this project
is `paths.styles` in `.claude/stack.json`.

| Tier | Grammar | Lives in | Usable in markup |
|------|---------|----------|------------------|
| 1 — Primitive | `--raw-<category>-<name>[-<shade>]` | `:root` | never |
| 2 — Semantic | `--<role>[-<variant>][-<state>]` | `:root` | only via its binding |
| 3 — Component | `--<namespace>-<component>` | the theme layer | yes |

Binding (Tailwind v4 shown): `@theme inline { --color-background: var(--background); }`

## Rules

1. **Only Tier 1 holds literals.** A hex/px/ms anywhere else is a bug.
2. **Tier 2 names purpose, not appearance** — `--action-primary`, never `--blue`.
   If renaming the colour would force renaming the token, the name is wrong.
3. **Tier 2 is the themeable layer.** Dark mode and runtime theming override
   Tier 2 only — never Tier 1, never a binding.
4. **Every binding entry is exactly `--<namespace>-<role>: var(--<role>)`.**
   No literals, no `calc()`, no jumping to `var(--raw-*)`. An inlining theme
   layer freezes a literal at build time and silently breaks theming — the
   indirection is load-bearing, not ceremony.
5. kebab-case, singular, unabbreviated; state last (`--action-primary-hover`).
6. Tier 3 is rare — a repeated pattern is a component, not a token set.

**Tailwind v4 has no `--duration-*` namespace.** Durations stay Tier 2 and are
consumed as `duration-[var(--duration-fast)]`.

## Where a style goes (first match wins)

| Situation | Goes where |
|-----------|-----------|
| One-off | utility classes in the markup |
| Repeated pattern with structure/props | a **component** |
| Repeated pure-utility combo | a `@utility` (or the framework's equivalent) |
| Pseudo-elements, 3rd-party overrides | `@layer components` |
| A new colour/spacing/radius value | Tier 1 primitive + Tier 2 semantic token |

The token file holds tokens and base resets only — it stays a few hundred lines
forever. Component styles do not live here.
