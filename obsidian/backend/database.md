---
tags: [backend, database, wip]
updated: 2026-08-18
---

# Database

No vendor prescribed (ADR-0015). Playbook: the `database` skill, `/data`.

## Does this project need one?

A marketing site usually does not. Form submissions can go to a CRM or an email
service; content belongs in a CMS. Add a database when there is genuinely
relational, queryable, project-owned data — and say so when there is not.

## Pick for the runtime

The deploy target matters more than the brand:

- **Serverless / functions** — connections are the problem, not SQL. Use a pooled
  or HTTP-based driver. A plain long-lived TCP pool exhausts connections under
  load.
- **A long-lived server** — a normal pool is fine.
- **Static/SPA with no server** — the browser cannot safely talk to a database.
  Add a function layer, or use a service built for public clients with policies
  enforced server-side.

## The rules that actually bite

- **Connection strings are not interchangeable.** Pooled string for app runtime,
  **direct** for migrations and dumps. Transaction-mode pooling does not support
  prepared statements — disable them in the client. Running migrations through
  the pooler is the classic setup failure.
- **Store both strings, validated, server-only.** Never behind the public prefix.
- **Use current keys.** Vendors rotate their key model; a secret/service key
  **bypasses row-level security entirely** — server only, never imported into a
  client component.
- **RLS on every table holding user data**, with an index on any column a policy
  filters. A table with RLS on and no policy is locked; one with RLS off is wide
  open. Neither by accident.
- **Never point local development at production.** A schema push rewrites it.
- **One owner of the schema.** If a CMS manages its own tables, it owns their
  migrations — do not hand-write migrations against them, and do not layer RLS
  onto them.

## Migrations & types

- Migrations are files in the repo, reviewed like code, applied by an explicit
  command or in CI. Auto-sync/`push` is a development convenience and is **off in
  production**.
- Generate types from the schema after every change and use them.
- Queries live in a data-access module, not inline in views.

## Proving it

A row written from the app and read back through a real route, with RLS on and
the anonymous client — not a service-key smoke test, which proves only that the
service key works.

## This project

> [!todo] Fill in when a database is added
> Vendor and why (link the ADR), both connection strings and where they are
> validated, the migration command, which tables have RLS and their policies, and
> how types are generated.

## Related

[[backend/README]] · [[cms]] · [[environment-variables]]
