---
tags: [meta, decision, stable]
updated: 2026-08-18
---

# Decisions Log (ADRs)

Why the conventions are what they are. **ADR-0001 … ADR-0016 are inherited from
the kit** — notes across the vault link to them by number, so keep the numbers
stable. Add this project's decisions on top, continuing the sequence.

Amending an inherited decision is fine: write a new ADR that supersedes it rather
than editing the old one. Template: [[templates/adr-note]].

---

## ADR-0001 — The vault is the single source of truth for conventions

**Context.** Conventions spread across a README, a few comments and one long
prompt drift apart within weeks, and an agent reading any one of them writes
inconsistent code.

**Decision.** All conventions live in `obsidian/`, linked and navigable. Root
files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`) are thin shims carrying the hard
rules and pointing here.

**Consequences.** One place to update, one place to read. The vault must be kept
current — enforced by the `Stop` hook (ADR-0006) and the `vault-librarian` agent.
It costs tokens on every session; that is the trade for first-pass-correct code.

---

## ADR-0002 — All real motion is spring-based, through exactly one binding

**Context.** Immersive sites live or die on how motion *feels*. Time-based
keyframes cannot be interrupted, do not respond to velocity, and read as
mechanical. A codebase that accumulates a second and third animation library ends
up with three motion languages and no consistent feel.

**Decision.** Every real motion is spring physics, through a single binding
recorded in `stack.json → bindings.motion`. `@keyframes` are banned outright. Any
animation library that is not the configured binding is banned — including the
ones this kit would otherwise recommend.

**Consequences.** Motion is consistent and interruptible. Adding a library
"just for this one thing" is a hard-rule violation that `verify.sh` FAILs. When a
project already has a binding, that one wins over the kit's default — consistency
outranks preference. See [[motion-system]], [[motion-bindings]].

---

## ADR-0003 — Routes delegate to views

**Context.** Route files are the most framework-coupled files in any codebase.
When UI logic lives in them, a framework upgrade or a migration rewrites the
entire site.

**Decision.** A route/page file is a few lines: load data, render a view. All UI
logic lives in `paths.views`.

**Consequences.** The UI survives framework changes and ports between stacks
almost unchanged — which is what makes this kit portable at all. It adds one file
per route. `verify.sh` FAILs a route importing anything but a view.
See [[routing-views]].

---

## ADR-0004 — Design tokens in three strict tiers

**Context.** Two-tier systems (primitive → utility) make re-theming a
find-and-replace, and "just this one hex" accumulates until a rebrand is a
rewrite.

**Decision.** Tier 1 primitives (`--raw-*`, literals only) → Tier 2 semantic
roles (purpose-named, the themeable layer) → the theme binding, which is always
exactly `--<namespace>-<role>: var(--<role>)`. No tier may be skipped.

**Consequences.** Re-theming is one block of Tier 2 overrides. The indirection
looks redundant until you try to theme without it — an inlining theme layer
freezes a literal at build time and silently breaks theming. The grammar is
identical in every project using this kit, so token names are predictable without
reading the file. See [[design-system]].

---

## ADR-0005 — One shared render loop

**Context.** Every scroll-driven component starting its own
`requestAnimationFrame` gives a page with twenty of them twenty loops, twenty
layout reads per frame, and jank that no individual component looks responsible
for.

**Decision.** One reference-counted, app-wide ticker. Everything per-frame
subscribes; the smooth-scroll library is driven *by* it rather than running its
own loop. Resize listeners are shared the same way. The ticker is an extension
point, never protected code.

**Consequences.** An idle page costs nothing; a hidden tab renders nothing.
Per-frame work is measurable in one place. Components must not call
`requestAnimationFrame` directly. See [[motion-system]], [[data-flow]].

---

## ADR-0006 — Hooks enforce the workflow, not good intentions

**Context.** "Read the docs first, update them after" is advice, and advice is
skipped under pressure — by humans and models alike.

**Decision.** Three Claude Code hooks in `.claude/settings.json`: `SessionStart`
points at the vault (or at `/adapt` when the kit is unfitted), `UserPromptSubmit`
reminds before every request, `Stop` blocks **once per turn** to confirm the docs
were updated.

**Consequences.** The workflow happens without anyone asking for it. The `Stop`
hook is bounded by a session-keyed marker file, so it cannot loop. Every turn
costs some extra context. Disable or edit with `/hooks`.

---

## ADR-0007 — A stack profile instead of a framework lock

**Context.** The kit's predecessor was a Next.js starter: every rule, script and
skill named `src/app`, `next/image`, `NEXT_PUBLIC_`. All of it correct, none of
it portable — and every one of those references becomes a lie after a framework
migration.

**Decision.** One machine-readable profile, `.claude/stack.json`, holds the
framework, paths, bindings, capabilities, conventions and commands. Rules, skills
and `verify.sh` read from it. Prose stays neutral; the profile carries the
specifics. `/adapt` writes it by detection, not assumption.

**Consequences.** The same kit runs on Next, Astro, SvelteKit, Nuxt, a Vite SPA
or plain HTML. A stale profile is now a real failure mode — it silently disables
checks — so updating it is part of any change that moves a path (ADR-0010, and
the `Stop` hook). Agents must resolve paths from the profile rather than from
documentation examples, which is a habit that needs stating loudly and often.
See [[stack-profile]], [[adapt-stack]].

---

## ADR-0008 — The motion layer is a contract, not a shipped library

**Context.** A drop-in kit cannot ship React components to a Svelte project. But
"use springs, figure it out" produces a different vocabulary in every project,
which defeats the point of a shared system.

**Decision.** The kit specifies the **primitive contract** — `Inview`,
`SpringTrigger`, `Hover`, `Handle`, plus the ticker and the text recipe — with
identical names, props and semantics in every framework. The implementation is
built per project against `bindings.motion`.

**Consequences.** A page written in one stack reads the same in another, and a
developer moving between projects already knows the vocabulary. It costs a build
step per project (the `/motion` command). Where a framework has no
children-wrapping component model, the same names appear as directives, actions
or hooks. See [[motion-system]].

---

## ADR-0009 — Text motion is split-and-stagger, with the traps written down

**Context.** Per-character and per-line text reveals are the signature move of an
immersive site, and they are re-implemented badly every time. Two failures are
near-universal: a flex split container that ignores `text-align`, and clipped
overflow shaving descenders when leading is tight.

**Decision.** Text animates through `bindings.textMotion` — `spring-text-engine`
on React, the documented split-and-stagger recipe elsewhere, built once as a
shared component. The traps are hard rule 3 and are checked mechanically where a
script can see them.

**Consequences.** Text motion is consistent and the two classic bugs are caught
before review. A bespoke per-section text animator is a rule violation.
See [[text-motion]].

---

## ADR-0010 — `verify.sh` skips what it cannot check, and says so

**Context.** A mechanical checker that assumes one framework either fails
constantly on another or, worse, passes because its checks silently matched
nothing.

**Decision.** Every check declares its preconditions from `stack.json`. If they
are not met the check prints **SKIP**, and skips are counted in the summary. An
unadapted profile prints a warning banner and runs only the universal checks.

**Consequences.** A clean run means something. A SKIP is a prompt: either the
stack genuinely lacks the concept, or the profile is incomplete. Silence is never
mistaken for a pass.

---

## ADR-0011 — External calls run server-side, behind one envelope

**Context.** A key in the browser is a key that is public, and every endpoint
inventing its own response shape means every caller invents its own error
handling.

**Decision.** Third-party calls run in server code; the browser calls only
same-origin endpoints. Secrets are server-only env vars behind a validated env
module. Input is schema-validated. Responses are `{ data }` or
`{ error: { code, message } }` via a shared handler.

**Consequences.** Secrets cannot leak by refactor. Clients share one error path.
On a stack with **no server**, this rule becomes a warning instead: there is no
safe place for a secret in the repo at all, and that must be said out loud rather
than worked around. See [[api-architecture]].

---

## ADR-0012 — A repeated pattern is a component, not a CSS class

**Context.** "This looks repeated" answered with a global CSS class produces a
second, undocumented design system inside the stylesheet.

**Decision.** One-offs use utilities. Repetition with structure becomes a
component. `@layer components` is reserved for pseudo-elements, third-party DOM
overrides and selectors utilities cannot express. The token file holds tokens and
base resets only.

**Consequences.** The token file stays a few hundred lines forever. Styling stays
where the markup is. See [[design-system]].

---

## ADR-0013 — One narrow exception for CSS transitions

**Context.** Wiring a spring for a colour fade on hover costs a client component
and a hook for no perceptible benefit.

**Decision.** CSS `transition-*` is allowed for simple discrete state changes —
hover/focus colour, opacity, border, a few-px nudge — under three conditions:
token-backed timing, `transition-*` only (never `@keyframes`), and living in the
class attribute rather than a CSS file. Everything scroll-driven, revealing,
staggered or layout-affecting stays a spring.

**Consequences.** The common trivial case stops being ceremonial. The boundary is
narrow and checkable — untokenised transitions WARN. See [[design-system]].

---

## ADR-0014 — Semantic HTML, and structured data as JSON-LD only

**Context.** Animation wrappers erase semantics by default (everything becomes a
`div`), and microdata scattered through markup is unmaintainable and easy to get
subtly wrong.

**Decision.** The tag carries meaning, the class carries looks. Every animation
primitive takes a semantic element and it is always passed. Structured data is
JSON-LD from one shared builder, rendered into the server HTML — never microdata,
never inline script tags scattered through components.

**Consequences.** Accessibility and SEO come from the markup rather than from a
later audit. `verify.sh` WARNs on a wrapper rendering as a `div`.
See [[html-semantics]], [[seo-metadata]].

---

## ADR-0015 — No CMS, database or auth vendor is prescribed

**Context.** The right CMS for an in-app Node framework is the wrong one for a
static site, and the right database for a long-lived server is the wrong one for
serverless. A kit that picks for you is wrong on a large fraction of projects.

**Decision.** The kit ships the *decision procedure* — how to choose against the
render model and runtime, and how to wire it identically once chosen (server-side
fetching, generated types, content through props, media in object storage) — and
no vendor.

**Consequences.** Every project makes and records its own choice as an ADR. The
skills stay useful across vendors. Nothing is installed until it is needed.
See [[cms]], [[database]].

---

## ADR-0016 — The kit ships no application code

**Context.** A starter repo can only start a project. This system has to be
droppable into a codebase that already exists, mid-life, without a rewrite.

**Decision.** The kit is documentation plus an execution layer: `obsidian/`,
`.claude/`, and three root shims. No components, no dependencies, no build
config, no framework.

**Consequences.** It can be added to any project at any point, and removed by
deleting three paths. The cost is that the motion layer must be *built* on first
use rather than imported (ADR-0008), and a brand-new project still needs its
framework scaffolded separately. The kit's value is the conventions and the
enforcement, not the boilerplate.
