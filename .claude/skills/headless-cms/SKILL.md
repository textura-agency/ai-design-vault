---
name: headless-cms
description: Add or change a headless CMS for this project — choosing between an in-app CMS and a hosted one against the actual framework, modelling collections from what the site renders, typed content access, media handling, preview, and proving the loop end to end. Use when the user wants editable content, says "add a CMS", "make this editable", "connect Sanity/Payload/Contentful/Storyblok/Directus", or asks how the client will update copy.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch
---

# Headless CMS

The kit prescribes no vendor. It prescribes how content reaches the page.

## 1. Choose against the framework, not against fashion

Read `framework.id` and `capabilities` from `stack.json` first.

| Situation | Reasonable choice |
|---|---|
| Node framework with server routes and its own admin story (Next, Nuxt, SvelteKit-with-adapter) | An **in-app CMS** (e.g. Payload) — one deploy, one database, direct data access with no HTTP hop |
| Static/SSG site, or a team that wants zero backend to run | A **hosted CMS** (Sanity, Storyblok, Contentful, Hygraph, Prismic) — content over an API at build time |
| Content is genuinely files, edited by developers | **Markdown/MDX in the repo** with a content-collection API. Do not add a CMS to a five-page site nobody else edits |
| Existing marketing team already on a platform | Whatever they already use — migration cost usually outweighs the technical fit |

Constraints that decide it faster than preference: does the framework have a
server at runtime; is there a database; who edits, and how often; does the
content need preview/drafts; does the host support the CMS's runtime.

**Check peer compatibility before installing anything.** An in-app CMS pins the
framework version range — verify the installed major is inside it, and say so
rather than discovering it during install.

## 2. Model from what the site renders

Do not invent a schema. Read the views and the mock data (`<paths.views>`,
`<paths.source>/data/mocks/`) and name the content types that actually exist.
Propose the model, **confirm with the user**, then write config.

- One collection per real content type; a "Page" collection with a blocks field
  beats twenty near-identical page types.
- Globals for site-wide singletons (nav, footer, contact details).
- Fields the design uses, nothing else. Every unused field is a question an
  editor has to answer forever.

## 3. Wire it the same way regardless of vendor

- **Fetch on the server.** In-app CMS → its local/direct API in server code, no
  HTTP hop to yourself. Hosted CMS → its SDK in a server loader/route, with a
  token that is *not* public. Never fetch content from a client component with a
  write-capable key.
- **Types are generated, never hand-written.** Run the vendor's type generation
  after every schema change and use the generated types in views. Casting CMS
  data to a hand-written interface is how a schema change becomes a runtime crash.
- **Content flows through props.** Views receive content as props; presentational
  components stay pure and CMS-unaware (`obsidian/frontend/component-conventions.md`).
- **Media**: uploads go to object storage (the CMS's own, or S3-compatible), never
  committed to the repo. Serve through the stack's image pipeline where one
  exists; set explicit dimensions either way.
- **Draft/preview** is a separate render path with its own cache rules — get it
  working before handing over, or the client will publish to check their work.

## 4. Prove the loop before reporting done

Not "the config compiles". All four:

1. the admin/studio loads and a user can log in
2. a document with an uploaded image saves
3. that image renders from storage in the browser
4. the content appears on a public route, and a change to it shows up

Then run the build.

## 5. Record it

`obsidian/backend/cms.md` (which vendor, why, the model), `architecture/tech-stack.md`,
`environment-variables.md`, the changelog, and an ADR for the choice. Add the CMS
client path to `stack.json → paths` and point `.claude/rules/data-layer.md` at it.
