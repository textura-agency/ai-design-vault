---
description: Add or operate the database for this project
argument-hint: [setup|migrate|rls|types]
---

Database task: **$ARGUMENTS**

Use the `database` skill. First: does this project need a database at all? A
marketing site usually does not — form submissions go to a CRM, content to a CMS.

The things that go wrong first:

- **Connection strings are not interchangeable.** Pooled for app runtime, direct
  for migrations. Transaction-mode pooling has no prepared statements. Migrations
  through the pooler is the classic failure.
- **Pick for the runtime.** Serverless needs a pooled or HTTP driver; a plain TCP
  pool exhausts connections. A static/SPA stack cannot talk to a database at all
  without a function layer.
- **Use current keys**, stored server-only and validated in the env module. The
  secret key bypasses row-level security entirely.
- **RLS on every user-data table**, with an index on any column a policy filters.
- **Never point local dev at production** — a schema push will rewrite it.

If a CMS owns the schema, it owns migrations too; use the database CLI only for
what sits outside its tables.
