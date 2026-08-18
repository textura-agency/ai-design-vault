---
description: Fit this kit to the framework it was dropped into — detect, profile, retarget
argument-hint: [framework-hint?]
---

Adapt the AI Design Vault kit to this project. Hint from the user: **$ARGUMENTS**

Use the `stack-adapt` skill and follow it in order. The short version:

1. `.claude/scripts/detect-stack.sh` — gather evidence. Read all of it.
2. Identify the framework **and its major version**, then confirm the current API
   against the installed docs rather than memory. Frameworks rename things
   between majors; that is the failure this kit exists to prevent.
3. Fill in `.claude/stack.json` field by field against
   `.claude/stack.schema.json`. Record only paths that exist — except
   `paths.views`, which you create if the stack has no equivalent.
4. Ask the user only what the repo cannot answer. Batch it; rarely more than
   three questions. The one that usually matters: **no motion library is
   installed — which binding, and may I install it?**
5. Retarget the `paths:` frontmatter in every `.claude/rules/*.md`, and fix the
   prose inside them where it names a path. Delete `engine-protected.md` if
   `paths.protected` is empty.
6. Record the profile in `obsidian/architecture/stack-profile.md`, update
   `tech-stack.md` and `folder-structure.md`, log a changelog entry and an ADR
   for any convention you switched off.
7. Prove it: `.claude/scripts/verify.sh` plus the project's lint and build.
   Read the SKIPs — a skip from a `null` path is unfinished work.

Report the path table, the bindings chosen, what you created, what you assumed,
and what still needs the user. If the project has no motion layer, say so and
point at `/motion`.
