# Agent Guide — AI Design Vault

A portable build system for **immersive, animation-heavy websites**, dropped into
this project. It does not own the framework; it owns the *conventions*.

## Rule zero — read the stack profile first

**`.claude/stack.json` is the single source of truth for this project's paths,
packages and commands.** The vault (`obsidian/`) tells you *how* things are done;
`stack.json` tells you *where* and *with what*, here.

```bash
cat .claude/stack.json
```

- Never take a path, an import, or a command from an example in the docs — the
  docs are framework-neutral and their examples are illustrations.
- If `"adapted": false`, **run `/adapt` before writing any project code.** Nothing
  below is correctly scoped until it has run.
- If reality and `stack.json` disagree, reality wins: fix the profile in the same
  turn and say so.

## This may not be the framework you know

Frameworks ship breaking changes faster than training data updates. Before
writing routing, metadata, data-fetching or middleware code, **verify the current
API against the installed version's own docs** (`node_modules/<framework>/**`,
the project's config files, or the official docs). Heed deprecation notices.
Confidently writing last year's API is the most common failure mode here.

## Documentation lives in the vault

All conventions are in the **`obsidian/`** vault — the single source of truth for
how work is done.

**Before working, read:**
- `obsidian/README.md` — Map of Content (index of every note)
- `obsidian/workflows/ai-agent-guide.md` — full rules of engagement
- The relevant topic note (e.g. `frontend/motion-system.md` before motion work,
  `workflows/new-page.md` before building a page)

**Commands, skills and agents** live in `.claude/` and are mapped in
`obsidian/workflows/agent-harness.md`. Entry points: `/adapt`, `/new-page`,
`/section`, `/motion`, `/qa`, `/ship`, `/seo`, `/cms`, `/data`, `/migrate-site`.

Notes link each other with `[[wikilinks]]` — follow them to navigate.

## Hard rules (never violate)

1. **All real motion is spring-based**, through the binding in
   `stack.json → bindings.motion` (+ `bindings.textMotion` for text). No
   `@keyframes`. No second animation library — adding one is how a codebase ends
   up speaking three motion languages. **One exception:** CSS `transition-*` for
   simple discrete state changes (hover/focus colour, opacity, border, a few-px
   nudge) with token-backed timing. Everything scroll-driven, revealing,
   staggered or layout-affecting stays a spring. See
   `obsidian/frontend/motion-system.md`.
2. **Do not modify anything listed in `stack.json → paths.protected`** without
   explicit sign-off. That is the vendored motion engine — consume it, wrap it,
   never edit it.
3. **Text motion has three traps**: never a manual/imperative mode when a
   scroll-driven one exists; a split-text container is usually **flex**, so
   `text-align` alone will not align it — pair it with `justify-*`; and clipping
   `overflow` cuts to the line-height box, so keep leading ≥ 1.1 or glyphs get
   shaved. See `obsidian/frontend/text-motion.md`.
4. **No hardcoded values** — design tokens for styles, props/hooks for content.
   No raw hex/px in class names. Tokens follow a strict three-tier convention
   (`--raw-*` primitive → semantic role → theme binding) that is identical in
   every project using this kit. See `obsidian/frontend/design-system.md`.
5. **Routes delegate to views.** A route/page file is a few lines and imports
   only from `paths.views`. All UI logic lives in the view.
6. **Ship the least client JavaScript that works.** Server-render or
   pre-render by default; make a component interactive only at the leaf that
   needs it. What that means concretely per framework is in
   `obsidian/frontend/routing-views.md`.
7. **No `any`.** Type everything. Run `commands.lint` before finishing.
8. **Navigation and images go through the stack's own components**
   (`bindings.link`, `bindings.image`, `bindings.router`) — not raw `<a>`/`<img>`
   for internal links and content images, and never a router API from a different
   framework generation.
9. **API & secrets** — external/third-party calls run server-side; secrets are
   server-only env vars (never behind `bindings.envPublicPrefix`) read through
   the single validated env module. The browser only calls same-origin endpoints.
   Validate input; return a consistent `{ data }` / `{ error }` envelope. See
   `obsidian/backend/api-architecture.md`.
10. **Semantic, SEO-correct HTML** — native elements over `div`s, one `<h1>` and
    a clean heading outline, named landmarks, real `button`/`a`, `alt` text,
    JSON-LD (not microdata), a semantic element on every animation wrapper. See
    `obsidian/frontend/html-semantics.md`.
11. **Verify before reporting done.** `.claude/scripts/verify.sh` (zero FAILs)
    plus `commands.lint` and `commands.build` after any code change, and the
    `qa-verify` skill after any UI change. See
    `obsidian/workflows/qa-verification.md`.
12. **CMS, database and auth are added per project** via the `headless-cms`,
    `database` and `auth` skills — the kit ships none and prescribes no vendor.
13. **3D performance → use the skill.** If the request is about performance,
    jank, or shipping readiness **and** the project renders a three.js / WebGL
    scene, invoke the **`optimize-3d-scene`** skill first and follow its order of
    fixes — do not improvise one.

## After making changes

Update the vault: dependency changes → `architecture/tech-stack.md` +
`meta/changelog.md`; architectural choices → an ADR in `meta/decisions-log.md`;
new component/hook/util → the relevant catalog note; a changed path, package or
command → **`.claude/stack.json`**. The `vault-librarian` agent can do this pass
for you.
