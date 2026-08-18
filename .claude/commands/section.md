---
description: Build one section from a Figma node
argument-hint: <figma-url-or-node-id> [section-name]
---

Build the section at: **$ARGUMENTS**

Use the `figma-to-section` skill. Non-negotiables:

- Fetch **both** `get_design_context` (values, exact copy) and `get_screenshot`
  (layout). Never build from a description.
- Record the `fileKey` and node ID in `DESIGN-MAP.md` so this section can be
  re-verified later.
- Download assets to `<paths.assets>/<section>/`, verify each with `file`, check
  sizes, and report any failure immediately.
- Map every value onto the three-tier token system before writing markup.
- Copy is character-for-character. Do not invent visual features the design lacks
  — but *do* add this kit's motion, which is the house style.
- Finish with the `qa-verify` skill.

For several sections at once, run one `section-builder` agent per section.
