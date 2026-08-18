---
tags: [architecture, wip]
updated: 2026-08-18
---

# Tech Stack

Every dependency, what it does, and why it is here. **Filled in by `/adapt`** and
maintained from then on — a dependency added without an entry here is an
incomplete change.

> The authoritative machine-readable list is `package.json` (or the equivalent);
> this note is the *why*, which the manifest cannot hold.

## Core framework

| Package | Version | Role |
|---|---|---|
| | | |

> [!warning] This may not be the framework you knew
> Frameworks ship breaking changes faster than training data updates. Before
> writing routing, metadata, middleware or data-fetching code, verify the API
> against the installed version's own docs. See [[routing-views]].

## Styling

| Package | Version | Role |
|---|---|---|
| | | |

Token conventions: [[design-system]].

## Motion — the heart of the kit

| Package | Version | Role |
|---|---|---|
| | | Spring physics — drives **all** motion |
| | | Text motion (or the built-in recipe) |
| | | Smooth scrolling |

No second animation library, no CSS keyframes (ADR-0002). See [[motion-system]]
and [[motion-bindings]].

## State, data & validation

| Package | Version | Role |
|---|---|---|
| | | |

## Tooling

| Package | Role |
|---|---|
| | |

## Commands

Recorded verbatim in `stack.json → commands` so scripts and skills do not guess
the package manager:

```
install · dev · build · start · lint · typecheck · test
```

## Runtime

Node/Bun/Deno version floor, and where it is pinned (`engines`, `.nvmrc`,
`.tool-versions`). Record *why* if the floor is higher than the framework needs —
a toolchain dependency usually is the reason, and the next person will otherwise
downgrade it.

## Deliberately held back

Dependencies **not** on latest, each with a verified reason and a re-test date.
Without this table, someone bumps them, breaks the build, and reverts blind.

| Package | Held at | Latest | Why |
|---|---|---|---|
| | | | |

## Not installed — decided per project

The kit prescribes no vendor for these (ADR-0015). Record the choice here when
one is made, with an ADR:

| Need | Choice | Playbook |
|---|---|---|
| CMS | | [[cms]] · `/cms` |
| Database | | [[database]] · `/data` |
| Auth | | `auth` skill |
| Analytics / payments / i18n / testing | | |

## Related

[[stack-profile]] · [[system-overview]] · [[motion-bindings]]
