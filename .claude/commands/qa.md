---
description: Verify the current work against the hard rules and the design
argument-hint: [path-or-section?]
---

Run verification on: **$ARGUMENTS** (the whole source root if empty).

Use the `qa-verify` skill. In short:

1. `.claude/scripts/verify.sh $ARGUMENTS` — every FAIL must be fixed; WARNs are
   fixed or explicitly justified; a SKIP caused by a `null` path in
   `stack.json` is a gap to close, not a pass.
2. The project's own gates — `commands.lint`, `commands.typecheck`,
   `commands.build` from `.claude/stack.json`.
3. The judgement pass: design fidelity against a re-fetched Figma node, token
   discipline, motion primitive choice, semantics and a11y, responsive behaviour
   down to 320px, architecture (routes delegate, server-first, client-JS budget,
   props not hardcoded content).
4. Fix, then re-run from step 1 until clean.

Report what failed, what you fixed, what you consciously left, and anything you
could not verify.
