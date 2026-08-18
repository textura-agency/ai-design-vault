---
tags: [workflow, design, stable]
updated: 2026-08-18
---

# Workflow — Figma to Code

Turning a design into components. Skill: `figma-to-section`. Commands:
`/section`, `/new-page`.

## The rule underneath all of it

**Build from live Figma data, never from a description** — not from a summary you
wrote earlier, not from memory, not from a screenshot alone. A description loses
exactly the values that matter: the 28px gap, the 400-weight heading, the exact
copy.

## Extraction order

1. `get_metadata` — file structure, `fileKey`, node IDs.
2. `get_design_context` on the node — **the source of truth for values**: text,
   colours, typography, spacing, layout, asset URLs.
3. `get_screenshot` on the same node — **the source of truth for layout**: column
   count, direction, alignment, order, positioning.

Both, always. Design context will not tell you a layout reads as three columns;
the screenshot will not tell you the gap is 28px.

## Record the map

`DESIGN-MAP.md` at the repo root: file key, source URL, frame width, and a row per
section with its node ID and the component it became. QA re-fetches from these — a
section without a node ID cannot be verified against its design later.

## Assets

Figma asset URLs **expire** (~7 days) — download immediately, to
`paths.assets/<section>/`, kebab-case and section-prefixed.

Then **verify each one**: run `file` on it (Figma returns SVGs where you asked for
rasters, and PNGs named `.jpg` — a mismatched extension renders as a broken
image), and sanity-check the size (a content photo under ~5KB is a placeholder,
not the export). A failed download is reported to the user immediately, never
silently skipped.

## Values → tokens, before markup

Map every value onto the three-tier system first ([[design-system]]). New colours
become a `--raw-*` primitive plus a semantic role naming its purpose. A value you
cannot justify as a token is a **design-review flag** in your summary, not a magic
number in a class name.

Check the frame width against the project's breakpoints before converting
anything — if the root font-size scales with the viewport, design px map cleanly
at the base width and fight you everywhere else.

## Fidelity rules

- **Copy is character-for-character.** Never rewrite, shorten or invent — flag bad
  copy instead of fixing it.
- **Do not invent visual features.** No shadows, gradients, overlays, hovers or
  card wrappers the design lacks. An invented wrapper background is the single
  most common cause of "the logo disappeared".
- **Do add motion.** That is the one deliberate departure from a static frame —
  reveals, parallax and text motion are the house style. Keep it restrained, and
  use the primitives ([[motion-system]]).

## Parallelism

Several sections at once → one `section-builder` agent per section, each fetching
its own node and verifying its own work. They must not share a token-file edit
without coordination — merge new tokens deliberately.

## Related

[[new-page]] · [[design-system]] · [[motion-system]] · [[qa-verification]]
