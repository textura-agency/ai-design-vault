---
tags: [frontend, catalog, wip]
updated: 2026-08-18
---

# Component Catalog

Every component in this project, what it is for, and how to use it. **Filled in
as the project is built** — a component without an entry here is an incomplete
change ([[meta/README]] maintenance rules). Template:
[[templates/component-note]].

Placement rules: [[component-conventions]]. Real paths: [[stack-profile]].

## Motion primitives

The contract is in [[motion-system]]; record the built implementations here.

| Component | Props of note | Notes |
|---|---|---|
| `Inview` | `mode`, `from`, `to`, `delayIn` | reveal on enter |
| `SpringTrigger` | `mode`, `start`, `end` | scrub / toggle on scroll |
| `Hover` | `from`, `to` | disabled on touch |
| `Handle` | — | smooth swap on content change |
| text binding | see [[text-motion]] | |

## Design-system primitives

| Component | Purpose | Props |
|---|---|---|
| | | |

## Shared infrastructure

| Component | Purpose | Notes |
|---|---|---|
| | | |

## Feature components

Feature-specific components live next to their feature and do not need an entry
here unless they are reused.

## Related

[[component-conventions]] · [[motion-system]] · [[design-system]]
