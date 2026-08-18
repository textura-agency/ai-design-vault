---
tags: [frontend, design-system, stable]
updated: 2026-08-18
---

# Design System

Styling runs through **design tokens in three tiers**. The examples below use
Tailwind v4 (the kit's default and the most common case); the tier grammar is the
point and it applies to plain CSS custom properties, CSS Modules or
vanilla-extract equally. This project's styling binding and token file are in
[[stack-profile]]. ADR: [[decisions-log]] ADR-0004.

## Where config lives

**One token file** (`paths.styles`) holds the tokens and base resets. Extra CSS
layers can be split into sibling files and imported. In Tailwind v4 there is no
`tailwind.config.js` — configuration is CSS.

If the setup scans for class names, **scope the scan to the source directory**.
An unscoped scan parses class *patterns* written in documentation — including
this vault and `.claude/` — as real candidates and emits build warnings.
Documentation is not a source of utilities.

## Token naming convention

> [!important] This convention is **strict and portable by design**
> It is identical in every project using this kit, so anyone moving between them
> can predict a token's name without reading the file. Deviating in one project
> defeats the point.

Three tiers. Each may only reference the tier below it, and **no tier may be
skipped** — semantic tokens are what make a re-theme a one-block change instead of
a find-and-replace.

| Tier | Grammar | Lives in | Example | Usable in markup? |
|---|---|---|---|---|
| **1 — Primitive** | `--raw-<category>-<name>[-<shade>]` | `:root` | `--raw-color-neutral-950` | ❌ never |
| **2 — Semantic** | `--<role>[-<variant>][-<state>]` | `:root` | `--background`, `--action-primary-hover` | ❌ only via its binding |
| **3 — Component** | `--<namespace>-<component>[-<property>]` | the theme layer | `--radius-button` | ✅ `rounded-button` |

Plus the **theme binding**, which is what actually creates the utilities:

```css
@theme inline {
  --color-background: var(--background);   /* --<namespace>-<role>: var(--<role>) */
}
```

### The rules

1. **Only Tier 1 contains literals.** A hex, px or ms value anywhere else is a bug.
2. **Tier 2 names purpose, never appearance.** `--action-primary`, not `--blue`.
   `--surface-raised`, not `--grey-light`. If renaming the colour would force
   renaming the token, the name is wrong.
3. **Tier 2 is the themeable layer.** Dark mode and runtime theming override
   Tier 2 — never Tier 1, never a binding entry.
4. **Every binding entry is exactly `--<namespace>-<role>: var(--<role>)`.**
   No literals, no `calc()`, no skipping to `var(--raw-*)`.
5. **kebab-case, singular, unabbreviated.** State goes last.
6. **Tier 3 is rare.** A repeated pattern is a component, not a token set
   (ADR-0012). Reach for a component token only when the same value must be
   shared across components that cannot import each other.

### Why Tier 2 is separate from the theme layer

`@theme inline` **inlines** each `var()` into the generated utility. That is what
makes overriding the Tier 2 token in a `prefers-color-scheme` block cascade into
every `bg-background` on the page. Binding a literal — or a `var(--raw-*)` —
directly in the theme layer freezes the value at build time and silently breaks
theming. The indirection is load-bearing, not ceremony.

### Namespaces that generate utilities (Tailwind v4)

A token becomes a utility only if its prefix is a known namespace:

| Namespace | Generated utilities |
|---|---|
| `--color-*` | `bg-*`, `text-*`, `border-*`, … |
| `--spacing-*` | `p-*`, `m-*`, `gap-*`, … |
| `--radius-*` | `rounded-*` |
| `--leading-*` / `--tracking-*` | `leading-*` / `tracking-*` |
| `--text-*` / `--font-*` | `text-*` (size) / `font-*` |
| `--ease-*` | `ease-*` |
| `--shadow-*` / `--blur-*` / `--animate-*` | `shadow-*` / `blur-*` / `animate-*` |
| `--breakpoint-*` / `--container-*` | `sm:` … / `max-w-*` |

> [!warning] There is **no `--duration-*` namespace** in Tailwind v4
> A `duration-fast` class silently compiles to nothing. Durations stay **Tier 2
> only** and are consumed as `duration-[var(--duration-fast)]`. (Guides listing
> `--duration-*` alongside `--ease-*` are wrong for v4; `--ease-*` *is* real.)

> [!important] The token rule
> **Never** hardcode hex values, pixel spacing or named colours in class names or
> inline styles. If a value doesn't exist as a token, **add it first** — a Tier 1
> primitive plus the Tier 2 semantic token naming its purpose — with a comment
> saying where it came from (e.g. a Figma frame).

## CSS layers

Every custom style goes inside a layer — never outside one:

```css
@layer base {        /* element resets & defaults */ }
@layer components {  /* pseudo-elements & 3rd-party overrides only */ }
@layer utilities {   /* single-purpose helpers */ }
```

## Where a style goes (ADR-0012)

The token file is **not** a place to park component styles — it holds tokens and
base resets and stays a few hundred lines forever. First match wins:

| Situation | Goes where |
|---|---|
| One-off styling | utility classes in the markup |
| Repeated pattern with markup / structure / props | a **component** |
| Repeated *pure-utility* combo, no structure | a `@utility` (or the framework's equivalent) |
| Pseudo-elements, 3rd-party DOM overrides, complex selectors | `@layer components` |
| A new colour / spacing / radius value | a **token** — Tier 1 + Tier 2 |

> The default answer to "this looks repeated" is a **component**, not a CSS class.
> An eyebrow label with a `::before` dot is an `<Eyebrow>` component, not a
> `.label-eyebrow` global class.

## The starting theme

Start **minimal on purpose** — the convention is the deliverable, not a palette:

- **Tier 1:** a small neutral ramp and two durations
  (`--raw-duration-fast/normal`).
- **Tier 2:** `--background`, `--foreground`, `--duration-fast`,
  `--duration-normal`, with a dark-mode override in a `prefers-color-scheme` block.
- **Bindings:** `--color-background`, `--color-foreground`, `--font-sans`, plus
  `--leading-display` (1.1 — the clip floor for [[text-motion]]) and
  `--ease-entrance`.

Add the brand palette per project as `--raw-color-brand-*` primitives plus the
semantic roles naming their purpose.

## Adaptive scaling

An immersive site usually scales the root font-size with the viewport, so a
design's px values map to `rem` once and the whole layout scales together. If this
project does that, the rule block lives in the token file and **must stay in sync**
with whatever grid config drives it. Check the design's base width against it
before converting any value.

## Motion: springs first, CSS for trivial state

Hard rule 1 stands — all real motion is spring-based ([[motion-system]]). One
narrow exception (ADR-0013), because wiring a spring for a hover colour fade costs
a client component and a hook for no benefit:

| Allowed (CSS) | Not allowed (use a spring) |
|---|---|
| `hover:` / `focus-visible:` / `active:` colour, `opacity`, `border-color`, underline | anything scroll-driven |
| Small decorative nudges (an arrow shifting a few px) | enter/reveal animations |
| | text animation |
| | layout/size changes, staggered sequences |
| | anything that must be interruptible or physical |

Conditions — all three, or it is a spring:

1. **Token-backed timing.** `transition-colors duration-[var(--duration-fast)] ease-entrance`
2. **`transition-*` only.** `@keyframes` remain banned outright.
3. **Utilities only.** The transition lives in the class attribute, not a CSS file.

## Styling rules

- Keep class strings short and readable; extract a repeated pattern to a
  component, not a CSS class.
- Mobile-first responsive prefixes.
- Dark mode via the `dark:` variant or Tier 2 overrides in a
  `prefers-color-scheme` block — never by duplicating a palette.
- No inline styles except genuinely dynamic values (spring-animated values).

## Related

[[component-conventions]] · [[motion-system]] · [[new-page]] · [[stack-profile]]
