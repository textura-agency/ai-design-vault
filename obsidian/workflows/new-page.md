---
tags: [workflow, playbook, stable]
updated: 2026-08-18
---

# Workflow — Implement a New Page / Section

The repeatable playbook. The fill-in prompt template is
[[generic-layout-prompt]] — copy it, replace the `[PLACEHOLDERS]`, hand it over.

> [!tip] Empty project? Start at the home route.
> Build the home route first rather than scaffolding a new one. If
> `bindings.motion` is null, run `/motion` before building anything animated.

## Steps

1. **Read the profile.** `.claude/stack.json` — routes, views, components,
   styles, assets, bindings. Every path below comes from there.
2. **Get the design.** Desktop + mobile frames, via [[figma-to-code]] — fetch both
   `get_design_context` and `get_screenshot`, record node IDs, download and verify
   assets. Never build from a description.
3. **Plan the route.** A thin route file under `paths.routes` that delegates
   ([[routing-views]]). Add it to the sitemap **in the same change**.
4. **Build the view** in `paths.views`, composed of components.
5. **Break into components.** Reuse what exists before creating anything. New
   primitives with the primitives; feature pieces next to the feature. Typed
   props, named exports ([[component-conventions]]).
6. **Tokens before styles.** Every colour/spacing/type/radius value references a
   token. Missing? Add the Tier 1 primitive + Tier 2 semantic token first, with a
   comment naming its origin ([[design-system]]).
7. **Motion via the primitives.** The right one for each need, a semantic element
   on every wrapper, transform/opacity only, text through the text binding
   ([[motion-system]], [[text-motion]]).
8. **Data via props/hooks.** No hardcoded content. Placeholders in
   `data/mocks/<page>.*`. Async data gets loading/error/empty states.
9. **Assets per section** — `paths.assets/<section>/`, absolute paths
   ([[folder-structure]]).
10. **Server-first.** Interactive only at the leaf that needs it; watch what
    actually hydrates.
11. **Semantic & accessible markup** — one `<h1>`, proper landmarks, native
    elements, named controls, visible focus, `alt` text ([[html-semantics]]).
12. **Verify.** `verify.sh`, lint, build, then the judgement pass in
    [[qa-verification]]. Components under ~150 lines. Conventional commit.

## Deliverables

- Components in their correct folders, and the view assembling them.
- Any new tokens (commented with their origin).
- A mock data file if needed.
- Section assets under `paths.assets/<section>/`.
- A short summary: assumptions made, new tokens and why, any design values that
  could not map to a token (flag for design review).

> [!important]
> Updating an existing page? Preserve all existing logic. Keep diffs minimal and
> focused on the required change.

## Motion cheat-sheet

| Need | Use |
|---|---|
| Reveal on scroll-into-view | `Inview` `mode="once"` |
| Continuous scroll motion (parallax) | `SpringTrigger` `mode="scrub"` |
| Snap at a scroll point | `SpringTrigger` `mode="toggle"` |
| Hover effect | `Hover` |
| Heading / copy reveal | the text binding — [[text-motion]] |
| Hover colour or opacity only | CSS `transition-*` with token timing (ADR-0013) |

## Related

[[routing-views]] · [[component-conventions]] · [[design-system]] · [[motion-system]] · [[figma-to-code]] · [[qa-verification]] · [[ship]]
