---
description: Build a new page or section following this kit's playbook
argument-hint: [page-name] [figma-url?]
---

Implement a page or section: **$ARGUMENTS**

Follow `obsidian/workflows/new-page.md`. If a Figma URL was given, use the
`figma-to-section` skill for extraction and asset handling.

1. **Read first** — `.claude/stack.json` for the real paths, then
   `obsidian/workflows/ai-agent-guide.md` for the hard rules, then the topic
   notes you actually need (`design-system.md` for styling,
   `motion-system.md` + `text-motion.md` for motion,
   `component-conventions.md` for placement, `html-semantics.md` for markup).
2. **Plan the route** — a thin route file under `paths.routes` that delegates to
   a view. Register it in the sitemap in the same change.
3. **Build the view** in `paths.views`, composed of components. Reuse what exists
   before creating anything new.
4. **Tokens before styles.** Any new colour/spacing/type/radius value becomes a
   Tier 1 primitive + Tier 2 semantic token in `paths.styles`, commented with its
   origin. Nothing hardcoded.
5. **Motion via the kit's primitives** — the right one for each need, a semantic
   element on every wrapper, transform/opacity only.
6. **Content via props/hooks.** Mocks under `<paths.source>/data/mocks/<page>.*`.
   Async data gets loading/error/empty states.
7. **Server-first** — interactivity only at the leaf that needs it.
8. **Assets** to `<paths.assets>/<section>/`, referenced by absolute path.
9. **Verify** — run the `qa-verify` skill (script + judgement checks) and fix
   until clean.
10. **Document** — update the catalog notes for anything new, add a changelog
    entry, and an ADR if you made an architectural choice.

Report: files created, new tokens and why, values that could not map to tokens
(flag for design review), assumptions made.
