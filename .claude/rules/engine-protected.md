---
paths:
  - "src/components/animation/**"
  - "src/hooks/animation/**"
  - "src/lib/motion/**"
description: Do-not-modify zone — the vendored motion engine
---

# STOP — this is the vendored motion engine

The paths listed in `.claude/stack.json → paths.protected` are treated as a
vendored library. **Do not edit them without explicit sign-off from the user.**

- Consume them; never modify them. Need different behaviour? Compose a wrapper
  alongside, in the normal component tree.
- `.claude/scripts/verify.sh` FAILs if `git diff` shows changes in a protected
  path.
- The shared ticker (`lib/animation/ticker.*`) is deliberately **not** protected —
  it is the supported extension point for loop-based motion.

If a change genuinely belongs in the engine, say so explicitly, explain why a
wrapper cannot work, and get the user's approval before touching a file.

> If `paths.protected` is empty in this project, this rule has nothing to guard.
> Delete the file — an unmatched rule is dead weight in every context window.

Reference: `obsidian/frontend/motion-system.md`
