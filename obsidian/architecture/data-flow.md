---
tags: [architecture, stable]
updated: 2026-08-18
---

# Data Flow

How content, state, scroll and motion move through the app. Four flows, kept
deliberately separate.

## 1. Content — top down, always

```
data source (CMS · database · endpoint · mock file)
        │  loaded at the route: server component, loader, endpoint, or build step
        ▼
   route file  ──props──►  view  ──props──►  components
```

- **Views do not fetch.** The route loads; the view receives. That is what keeps
  a view portable between frameworks and testable without a network.
- **Components never hold content.** No literal copy, numbers or image paths in a
  component — props or hooks, always ([[component-conventions]]).
- Placeholder content lives in `data/mocks/<page>.*` and enters through the same
  props, so swapping in real data changes one file.
- Async data carries `loading` / `error` / `empty` states with skeletons that
  mirror the final layout — designed, not an afterthought.

## 2. Motion — one loop, many subscribers

```
       ┌─────────────────────────────────────────┐
       │  ticker  (one requestAnimationFrame)    │
       │  reference-counted · pauses when hidden │
       └───────────────┬─────────────────────────┘
                       │ tick(time, delta)
     ┌─────────────────┼──────────────────┬───────────────────┐
     ▼                 ▼                  ▼                   ▼
 smooth scroll   scroll triggers    in-view watchers    WebGL scene loop
 (raf driven     (progress 0–1)     (visibility)        (if any)
  by the ticker)
```

- Nothing calls `requestAnimationFrame` directly (ADR-0005).
- Layout is read **once per frame, in the loop** — never in a scroll handler that
  also writes styles, which forces a synchronous reflow on every event.
- Each subscriber may throttle itself (a 30fps budget on a low tier), and
  unsubscribes on unmount.

## 3. Scroll state — one store, read by many

The smooth-scroll instance and its derived state (progress, direction, locked)
live in one small store, exposed through a hook/composable. Components read from
it; only the scroll layer writes to it. Locking scroll (a modal opening) is a
store action, never a direct DOM mutation somewhere in a component.

See [[smooth-scroll]].

## 4. Secrets and external data — server only, one direction

```
browser ──► same-origin endpoint ──► external API
                     │  secret env vars read here, never sent to the browser
                     ◄── { data } | { error }
```

Nothing in the client bundle ever holds a secret, and the browser never calls a
third-party origin directly (ADR-0011). On a stack with no server, this flow does
not exist — and neither does a safe place for a secret. See [[api-architecture]].

## Boundaries worth keeping

| Boundary | Why |
|---|---|
| route ↔ view | the framework's API stops at the route |
| view ↔ component | content flows down as props; components stay pure |
| store ↔ component | one writer, many readers |
| client ↔ server | secrets and third-party calls never cross into the bundle |

## Related

[[system-overview]] · [[motion-system]] · [[smooth-scroll]] · [[api-architecture]]
