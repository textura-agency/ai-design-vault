---
description: Add or change the headless CMS for this project
argument-hint: [vendor?] [collection-names?]
---

CMS task: **$ARGUMENTS**

Use the `headless-cms` skill. Before installing anything:

1. **Check the render model and runtime** in `.claude/stack.json`. An in-app CMS
   needs a server; a static site wants a hosted one; a five-page site nobody else
   edits may want neither. Say so if a CMS is the wrong answer.
2. **Check peer compatibility** against the installed framework major — an in-app
   CMS pins a version range. Verify rather than discover it mid-install.
3. **Propose the model from what the site actually renders** — read the views and
   the mock data, name real content types, and confirm with the user before
   writing config.

Prove the loop before reporting done: the admin loads, a document with an
uploaded image saves, that image renders from storage in the browser, and the
content appears on a public route. Then run the build.

Finish by updating `obsidian/backend/cms.md`, `tech-stack.md`,
`environment-variables.md`, the changelog, and `stack.json`.
