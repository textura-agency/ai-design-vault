---
tags: [workflow, ai, stable]
updated: 2026-08-18
---

# AI Agent Guide

Rules of engagement for AI agents (Claude Code, Cursor) working in this repo.

## Read this first

> [!important] Rule zero — resolve everything from the stack profile
> `.claude/stack.json` holds this project's paths, packages and commands. The
> vault tells you *how*; the profile tells you *where and with what*. **Never take
> a path or an import from an example in these notes** — they are illustrations.
> If `"adapted": false`, run `/adapt` before writing project code.
> See [[stack-profile]].

> [!warning] This may not be the framework you know
> Frameworks ship breaking changes faster than training data updates. Verify
> routing, metadata, middleware and data-fetching APIs against the **installed
> version's** own docs before writing them. Heed deprecation notices. Confidently
> writing last year's API is the most common failure here.

> [!tip] Where to start in an empty project
> Build the home route first, and follow [[new-page]]. If the project has no
> motion layer yet (`bindings.motion` is null), run `/motion` before building
> anything animated — the motion system is the point.

## Source-of-truth hierarchy

| Layer | Files | Purpose |
|---|---|---|
| **The profile** | `.claude/stack.json` | **This project's shape** — paths, bindings, capabilities, commands |
| **This vault** (`obsidian/`) | all of `obsidian/**` | **The conventions** — how work is done, and why. Framework-neutral |
| **AI entry points** (repo root) | `AGENTS.md`, `CLAUDE.md`, `.cursorrules` | Thin shims — the hard rules and a pointer here |
| **Execution layer** | `.claude/**` | Commands, path-scoped rules, skills, agents, hooks and `verify.sh` — see [[agent-harness]] |

## Hard rules (never violate)

1. **All real motion is spring-based**, through `bindings.motion`. No
   `@keyframes`, no second animation library. CSS `transition-*` is allowed only
   for discrete hover/focus state with token-backed timing (ADR-0013).
   See [[motion-system]].
2. **Do not modify anything in `paths.protected`** without explicit sign-off —
   it is a vendored engine. Consume it, wrap it, never edit it.
3. **Text motion's three traps**: no imperative mode where a scroll mode exists;
   pair `text-*` with `justify-*` on a flex split container; keep leading ≥ 1.1
   wherever overflow clips. See [[text-motion]].
4. **No hardcoded values** — three-tier tokens for styles ([[design-system]]),
   props/hooks for content ([[component-conventions]]).
5. **Routes delegate to views.** Route files load data and render; UI logic lives
   in the view ([[routing-views]]).
6. **Ship the least client JavaScript that works.** Server-render by default;
   interactive only at the leaf.
7. **No `any`.** Type everything. Run `commands.lint` before finishing.
8. **Navigation and images go through the stack's own components**
   (`bindings.link`, `bindings.image`) — and never a router API from a different
   framework generation.
9. **External calls run server-side; secrets never reach the browser.** Validate
   input, return the envelope ([[api-architecture]]).
10. **Semantic, SEO-correct HTML**, and a semantic element on every motion
    wrapper ([[html-semantics]]).
11. **Verify before reporting done.** `.claude/scripts/verify.sh` (zero FAILs)
    plus lint and build, and the `qa-verify` skill after any UI change. Zero
    FAILs, or say explicitly what you left and why ([[qa-verification]]).
12. **Performance request + a three.js/WebGL scene → invoke the
    `optimize-3d-scene` skill first.** It owns the order of fixes; do not
    improvise one ([[optimize-3d-scene]]).

## Where to look

| Question | Note |
|---|---|
| What are this project's paths and packages? | [[stack-profile]] — and `.claude/stack.json` itself |
| How is the project structured? | [[system-overview]], [[folder-structure]] |
| What's in the stack? | [[tech-stack]] |
| How do I add a page? | [[new-page]] |
| How does motion work? | [[motion-system]], [[motion-bindings]], [[text-motion]] |
| How do I style something? | [[design-system]] |
| What components/hooks/utils exist? | [[components]], [[hooks]], [[utils]] |
| The 3D scene lags? | [[optimize-3d-scene]] |
| How do I check my work? | [[qa-verification]] |
| A Figma design needs building | [[figma-to-code]] |
| Content needs to be editable | [[cms]] |
| The project needs a database | [[database]] |
| SEO / AI visibility | [[seo-aeo]] |
| Is it ready to launch? | [[ship]] |
| Rebuilding an existing live site | [[site-migration]] |
| The kit needs fitting to a framework | [[adapt-stack]] |
| What can Claude Code run here? | [[agent-harness]] |
| Why was X decided? | [[decisions-log]] |

## After making changes

- New dependency → [[tech-stack]] + [[changelog]].
- Architectural choice → an ADR in [[decisions-log]].
- New component/hook/util → the relevant catalog note.
- **A path, package or command changed → `.claude/stack.json`.** A stale profile
  silently disables checks; that is worse than a stale paragraph.

## Automated enforcement (hooks)

This workflow is **enforced automatically** by Claude Code hooks in
`.claude/settings.json` — nobody has to remember to ask for it:

| Hook | Fires | Effect |
|---|---|---|
| `SessionStart` | new chat / resume | Points at the vault — or at `/adapt` if the kit is unfitted |
| `UserPromptSubmit` | every request | Reminds the agent to consult the relevant guide, resolve paths from the profile, and update docs |
| `Stop` | end of every turn | Blocks once to confirm the vault and profile were updated |

The `Stop` hook blocks **at most once per turn** — a session-keyed marker file
guarantees termination. Review, edit or disable with `/hooks`. ADR-0006.

## Related

[[agent-harness]] · [[stack-profile]] · [[qa-verification]] · [[new-page]]
