---
name: qa-verify
description: Verify built UI against this project's hard rules and against the design — runs the mechanical check script, then the judgement checks a script cannot make (visual fidelity vs the design, token naming, motion primitive choice, semantics, responsive behaviour, client-JS budget), and fixes what it finds in a loop until clean. Use after building or changing any page, view, section or component, before committing, and whenever the user says "QA this", "check my work", or "is this ready to ship".
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# QA & verification

Two layers. The script decides what is decidable; you decide the rest. Never
report "done" on the script alone — it cannot see a design.

## Layer 1 — mechanical (always run first)

```bash
.claude/scripts/verify.sh                      # whole source root
.claude/scripts/verify.sh src/views/about.tsx  # scoped
```

Then the project's own gates — **read them from `.claude/stack.json`**, do not
guess the package manager:

```bash
node -e 'const c=require("./.claude/stack.json").commands;console.log([c.lint,c.typecheck,c.build].filter(Boolean).join("\n"))'
```

Run each. Every **FAIL** must be fixed. **WARN**s are judgement calls: fix or
justify in your summary, never silently ignore. **SKIP**s mean a check could not
apply — if one is skipped because a `stack.json` path is `null`, that is a gap in
the profile, not a pass.

## Layer 2 — judgement checks

Work section by section. For each one:

### Design fidelity (only when a design exists)
Re-fetch the Figma node — do not QA from memory or from your own earlier summary.
`get_design_context` for values, `get_screenshot` for layout. Then compare:

- **Copy** — character for character. Flag anything paraphrased, shortened or invented.
- **Layout** — column count, flex direction, alignment, order, positioning.
- **Spacing** — margins, padding, gaps against the design values.
- **Typography** — size, weight, line-height, letter-spacing. Never assume a
  heading is bold; designs often use 400.
- **Colour** — exact values, resolved through tokens rather than matched by eye.
- **Images** — aspect ratio, crop, radius, overlap. No effects the design lacks.

If an image looks invisible or wrong, check the **container** first — an invented
wrapper background is the usual cause, not the asset itself.

### Tokens
- Every colour/spacing/radius/type value resolves to a token.
- New tokens follow the three-tier grammar and carry a comment naming their origin.
- No literal reached the theme-binding layer or a Tier 2 token.
- A value that had to be invented because the design has no token for it is
  **flagged to the user for design review**, not quietly added.

### Motion
- Everything scroll-driven, revealing, staggered or layout-affecting is a spring
  through `bindings.motion`.
- CSS `transition-*` appears only for hover/focus/discrete state, with
  token-backed duration and easing.
- Each primitive is the right one — `Inview` for reveals, `SpringTrigger` scrub
  for parallax, `Hover` for hover, text through the text binding.
- A semantic element on every animation wrapper — never a bare `div`.
- Transform/opacity only; nothing animating layout properties.
- One shared render loop, not one rAF per component.
- With `prefers-reduced-motion`, content is present and readable.

### Semantics & a11y
- One `<h1>`; heading levels never skip; the outline reads as a document.
- Landmarks named; icon-only controls labelled; real `button` / `a`.
- Keyboard reachable, visible focus, logical tab order.
- Meaningful `alt`; decorative images `alt=""`.
- Contrast meets WCAG AA (4.5:1 body, 3:1 large text).

### Responsive
- No horizontal overflow at any width down to 320px.
- Grid/flex reflow at each breakpoint; nothing cramped or orphaned.
- Touch targets ≥ 44px on mobile.
- Navigation collapses at the intended breakpoint.
- Text stays readable; nothing clipped by a tight-leading + overflow combination.
- If the project scales the root font-size with the viewport, check the design
  base width still maps cleanly — most sizing follows from that one rule.

### Architecture & payload
- Route delegates to a view; UI logic lives in the view (`conventions.routesDelegateToViews`).
- Content arrives via props/hooks — nothing hardcoded in a component.
- Async data has loading/error/empty states with skeletons.
- Components under ~150 lines, in the right folder, typed props.
- **Client-JS budget**: interactivity pushed to the leaf that needs it. On an
  islands or server-components stack, check what actually hydrates — a whole
  section shipped to the client to animate one heading is the common regression.

## The loop

1. Run layer 1, fix every FAIL.
2. Walk layer 2 section by section, fixing as you go.
3. Re-run layer 1 (fixes can introduce violations).
4. Repeat until clean.

## Report

State plainly: what failed and was fixed, what is a WARN you consciously kept and
why, any design values that could not map to tokens, and anything you could not
verify (no design available, no device to test on). Do not report a clean pass
you did not achieve.
