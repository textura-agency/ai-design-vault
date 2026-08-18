---
tags: [workflow, template, prompt, stable]
updated: 2026-08-18
---

# Generic Layout Prompt

> Fill-in prompt template for implementing a page or section. Copy the body
> below, replace every `[PLACEHOLDER]`, and hand it to an AI agent. Companion
> playbook: [[new-page]].

---

We need to implement the **[PAGE NAME]** page/section.

## Before you start

Read `.claude/stack.json` for this project's paths, bindings and commands, and
`obsidian/workflows/ai-agent-guide.md` for the hard rules. Every path below is a
*concept* — resolve the actual address from the profile.

## Design references

- **Desktop frame:** [Figma URL or frame name]
- **Mobile frame:** [Figma URL or frame name]

Use the Figma MCP server to fetch exact measurements, colours, typography and
spacing from **both** frames before writing any code — `get_design_context` for
values, `get_screenshot` for layout.

## Requirements

### 1. Responsive layout
Mobile-first. Match the desktop frame exactly at desktop widths and the mobile
frame exactly at mobile widths, including elements that are hidden, reordered or
resized between them. No horizontal overflow at any width down to 320px.

### 2. Component structure
Route files import only from the views directory; all layout and UI logic lives
in the view and its components. Reuse existing primitives and shared components
before creating new ones. New primitives go with the primitives; feature-specific
pieces sit next to the feature. Every component has typed props. No `any`.

### 3. Tokens
Every colour, spacing, typography and radius value references a design token. If
a design value has no token, **add it first** — a Tier 1 `--raw-*` primitive plus
the Tier 2 semantic token naming its purpose, commented with its origin. Nothing
hardcoded in class names or inline styles. Styles go in the right layer;
repeated patterns become components, not CSS classes.

### 4. Motion
**All motion uses this project's motion binding and the kit's primitives. No CSS
keyframes, no second animation library.**

| Need | Primitive |
|---|---|
| Fades/slides in when scrolled into view | `Inview` `mode="once"` |
| Moves continuously with scroll (parallax, progress) | `SpringTrigger` `mode="scrub"` |
| Snaps at a scroll position | `SpringTrigger` `mode="toggle"` |
| Hover motion | `Hover` |
| Heading or copy reveal | the text binding |

Rules: pass the semantic element via `tag`/`as`, never a `div`. Spring values are
numbers or unit strings with matching types on both ends — never class names.
Tailwind classes go on `className`/`class`. Stagger with incremental `delayIn`.
Transform and opacity only. Never disable motion globally — use `disableOnMobile`
per instance where an animation hurts mobile UX.

### 5. Navigation and images
Use the project's link and image bindings. Images carry explicit dimensions and
meaningful `alt`; decorative images take `alt=""`.

### 6. Data & state
No hardcoded content — everything through props or hooks. Placeholder data goes
in `data/mocks/[page-name].*` and is passed in; the component stays pure. Async
data has `loading` / `error` / `empty` states with skeletons mirroring the final
layout. Fetching happens at the route or in a hook, never in a presentational
component.

### 7. Rendering
Server-render by default; make a component interactive only at the leaf that
needs it. Never mark a layout, page or view client-side to avoid a boundary.

### 8. Accessibility
Semantic elements over `div`s. One `<h1>`, no skipped heading levels. Every
interactive element keyboard-operable with visible focus. Icon-only controls
labelled. Landmarks named.

### 9. Code quality
Components focused and under ~150 lines. Early returns over deep nesting.
Comments explain *why*, never narrate *what*. No `console.log`.

## What to deliver

1. All components, in their correct folders.
2. The view assembling them.
3. Any new design tokens, commented with where they came from.
4. Mock data file, if needed.
5. A brief summary: assumptions made, new tokens and why, and any design values
   that could not be matched to a token (flag for design review).

**Verify before reporting done** — `.claude/scripts/verify.sh`, the project's
lint and build, and the judgement pass in `obsidian/workflows/qa-verification.md`.

**If this updates an existing page:** preserve all existing logic. Keep diffs
minimal and focused on the required change only.
