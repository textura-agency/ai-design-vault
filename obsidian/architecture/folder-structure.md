---
tags: [architecture, stable]
updated: 2026-08-18
---

# Folder Structure

Where everything lives. The **concepts** below are fixed; their **addresses** are
in `.claude/stack.json → paths` — see [[stack-profile]].

## Repo root

```
<project>/
├── <source>/                ← application code (see below)
├── <static root>/           ← served as-is: favicons, manifest, OG image, assets/
├── obsidian/                ← this vault — ALL project documentation
├── .claude/                 ← agent execution layer — see [[agent-harness]]
│   ├── stack.json           ← THIS PROJECT'S SHAPE — read it before writing files
│   ├── stack.schema.json    ← what each field means
│   ├── settings.json        ← hooks + permissions
│   ├── scripts/             ← verify.sh · detect-stack.sh · stack.sh · hooks/
│   ├── rules/               ← path-scoped context (auto-loads per file read)
│   ├── skills/              ← procedures loaded on demand
│   ├── agents/              ← subagent definitions
│   └── commands/            ← slash commands
├── framework config         ← whatever this stack uses
├── AGENTS.md                ← agent guide — rule zero, hard rules, vault pointer
├── CLAUDE.md                ← Claude Code entry → @AGENTS.md
└── .cursorrules             ← Cursor entry → points at AGENTS.md
```

## Application code — the concepts

| Concept | `paths` key | Holds |
|---|---|---|
| Routes | `routes` | route/page files only. Thin: load data, render a view (ADR-0003) |
| Views | `views` | one page-level component per route. All layout and UI logic |
| Components | `components` | primitives, shared infrastructure, feature pieces |
| Styles | `styles` | the token file — tokens and base resets only (ADR-0012) |
| Server | `server` | endpoints. External calls and secrets live here (ADR-0011) |
| Env | `env` | the one validated env accessor |
| Assets | `assets` | site content assets, **one folder per section** |
| Static root | `staticRoot` | favicons, icons, manifest, OG image |
| Protected | `protected` | vendored motion engine — do not edit (ADR-0002) |

Alongside these, by convention:

```
<source>/
├── lib/
│   ├── animation/ticker.*    # the one shared rAF loop (ADR-0005) — not protected
│   ├── motion/config.*       # mobile breakpoint + per-primitive defaults
│   ├── site.*                # site-wide SEO config, single source of truth
│   └── api-client.*          # typed same-origin fetch wrapper
├── hooks/ (or composables/)  # grouped by domain
├── utils/                    # pure helpers, no side effects
├── types/                    # shared types
└── data/mocks/<page>.*       # placeholder content until real data exists
```

## Placement rules — where does a new file go?

| I am adding… | It goes in… |
|---|---|
| A route | `paths.routes` — thin, delegates to a view |
| An API endpoint | `paths.server` — see [[api-architecture]] |
| A page's UI | `paths.views/<page>` — see [[new-page]] |
| A reusable design primitive | the primitives folder under `paths.components` |
| Shared infrastructure | the common folder under `paths.components` |
| A feature-specific component | next to the feature, **not** in the shared folders |
| A custom hook / composable | `hooks/<domain>/` |
| A pure helper | `utils/<domain>/` |
| Mock/placeholder data | `data/mocks/<page>.*` |
| A site content asset | `paths.assets/<section>/` — one folder per section |
| A favicon / icon / OG / manifest asset | `paths.staticRoot` root |

> [!important] Asset convention
> Content assets get **one folder per section** (`assets/hero/`, `assets/footer/`)
> and are referenced by absolute path. Meta/PWA/SEO assets stay at the static root.
> This is what makes a section deletable in one move.

## Do-not-modify zones

Everything in `paths.protected` is a vendored library: consume it, wrap it, never
edit it. `verify.sh` FAILs on a diff there. If the list is empty, this project has
no protected zone — and `.claude/rules/engine-protected.md` should be deleted.

## Related

[[stack-profile]] · [[system-overview]] · [[component-conventions]] · [[agent-harness]]
