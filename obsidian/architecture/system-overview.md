---
tags: [architecture, stable]
updated: 2026-08-18
---

# System Overview

## What this is

An **immersive, animation-heavy website** built with the AI Design Vault
conventions: spring-based motion through one binding, a strict three-tier token
system, routes that delegate to views, server-first rendering, and semantic
SEO-correct markup.

The framework is whatever [[stack-profile]] says it is. The conventions below
hold regardless.

## Mental model

```
Request (or build step)
   │
   ▼
Route file  ────────────────────────►  loads data, renders a view. Nothing else.
   │                                    (paths.routes — thin by rule, ADR-0003)
   ▼
Root layout / app shell
   │  design tokens loaded once · fonts · metadata · JSON-LD
   │
   ├─ smooth-scroll wrapper ──────────► drives the shared ticker
   │
   └─ View  (paths.views)
         │  composes sections from components; receives content as props
         ▼
      Motion primitives  ─────────────► Inview · SpringTrigger · Hover · Handle
         │                               all subscribed to ONE render loop
         ▼
      Rendered page — server-rendered by default, interactive only at the leaves
```

## The four pillars

1. **Routes → views.** Route files stay thin so the UI survives framework
   changes. [[routing-views]]
2. **One motion vocabulary.** The same primitive names and props in every stack,
   built on one spring binding, sharing one render loop. [[motion-system]]
3. **Tokens, three tiers deep.** No literal outside Tier 1; re-theming is a
   Tier 2 override. [[design-system]]
4. **Semantics as a first-class output.** The markup is the accessibility and SEO
   story; it is not retrofitted. [[html-semantics]]

## Request lifecycle

1. The framework resolves the route.
2. The route loads whatever data it needs (server component, loader, endpoint,
   or build-time fetch) and renders its view with it as props.
3. The app shell has already established tokens, fonts, metadata and the scroll
   layer.
4. The view composes components; motion primitives subscribe to the shared
   ticker on mount and unsubscribe on unmount.
5. Content is present in the server-rendered HTML regardless of motion state —
   which is what keeps reveals crawlable.

## Rendering strategy

Server-render or pre-render by default; push interactivity to the leaf that needs
it. What that means concretely depends on `capabilities` in [[stack-profile]] —
a server-components stack, an islands stack and an SPA each express the same
principle differently, and an SPA cannot express it at all without prerendering.

## Related

[[stack-profile]] · [[folder-structure]] · [[data-flow]] · [[motion-system]]
