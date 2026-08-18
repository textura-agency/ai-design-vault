---
name: database
description: Add or operate a database for this project — picking one that fits the runtime, connection and pooling rules, migrations, row-level security, generated types, and the mistakes that cost a production dataset. Use when the user says "add a database", "set up Postgres/Supabase/Neon/Turso", "we need to store submissions", or asks about migrations, RLS, or connection errors.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch
---

# Database

## 1. Does this project need one?

A marketing site usually does not. Form submissions can go to a CRM or an email
service; content belongs in a CMS. Add a database when there is genuinely
relational, queryable, project-owned data. Say so if there is not.

## 2. Pick for the runtime, not the brand

`framework.renderModel` and the deploy target decide more than the vendor does.

- **Serverless / edge functions** — connections are the problem, not SQL. Use a
  pooled or HTTP-based driver (Supabase's pooler, Neon serverless, PlanetScale,
  Turso). A plain long-lived TCP pool in a serverless function exhausts
  connections under load.
- **A long-lived Node server** — a normal pool is fine.
- **Static/SPA with no server at all** — you cannot talk to a database from the
  browser safely. Either add a serverless function layer, or use a service
  designed for public clients with row-level security enforced server-side.

## 3. The rules that actually bite

- **Connection strings are not interchangeable.** Most hosted Postgres offers a
  *pooled* string for app runtime and a *direct* one for migrations and dumps.
  Transaction-mode pooling does not support prepared statements — disable them in
  the client. Running migrations through the pooler is the single most common
  setup failure.
- **Store both strings, validated, server-only** in the env module. Never behind
  the public prefix.
- **Use current keys.** Vendors rotate their key model (publishable/secret pairs
  replacing legacy JWTs). The secret key bypasses row-level security entirely —
  server only, never imported into a component.
- **Row-level security on every table holding user data**, with an index on any
  column a policy filters. A table with RLS on and no policy is locked; a table
  with RLS off is wide open. Neither by accident.
- **Never point local development at the production database.** A schema push
  rewrites it. Separate project, branch, or local instance.
- **One owner of the schema.** If a CMS manages its own tables, it owns their
  migrations too — do not hand-write migrations against them.

## 4. Migrations and types

- Migrations are files in the repo, reviewed like code, applied in CI or by an
  explicit command. Auto-sync/`push` is a development convenience and must be off
  in production.
- Generate types from the schema after every change and use them. No hand-written
  row interfaces.
- Queries live in a data-access module under `<paths.source>/lib/`, not inline in
  views.

## 5. Prove it

A row written from the app, read back through a real route, with RLS on and the
anonymous client — not a `service_role` smoke test that proves only that the
secret key works.

## 6. Record it

`obsidian/backend/database.md`, `architecture/environment-variables.md`,
`tech-stack.md`, the changelog, an ADR for the vendor choice, and the client path
in `stack.json → paths` so `.claude/rules/data-layer.md` can target it.
