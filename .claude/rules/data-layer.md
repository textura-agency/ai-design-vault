---
paths:
  - "src/lib/supabase/**"
  - "src/lib/db/**"
  - "src/lib/cms/**"
  - "src/server/db/**"
  - "server/db/**"
  - "**/payload.config.ts"
  - "**/sanity.config.ts"
  - "src/collections/**"
  - "supabase/**"
  - "prisma/**"
  - "drizzle/**"
description: CMS, database and auth conventions
---

# Data layer

Full notes: `obsidian/backend/cms.md` · `obsidian/backend/database.md` ·
Skills: `headless-cms`, `database`, `auth`

- **Generated types are generated.** Never hand-edit them, and never cast content
  or rows to a hand-written interface — regenerate after every schema change and
  use the generated type. A schema change that only breaks at runtime is the
  failure this prevents.
- **The schema is the contract.** Add a field → update the schema → regenerate
  types → generate a migration → use it in the view. In that order.
- **Fetch on the server**, and pass content to views as props. Presentational
  components stay pure and unaware of the CMS or database.
- **Connection strings are not interchangeable** — pooled for app runtime,
  direct for migrations. Transaction-mode pooling does not support prepared
  statements. Running migrations through the pooler is the classic setup failure.
- **Secret/service keys bypass row-level security.** Server only, never behind
  the public env prefix, never imported into a client component.
- **Row-level security on every table holding user data**, with an index on any
  column a policy filters. If a CMS manages its own tables, it enforces its own
  access control — do not layer RLS onto them.
- **Authorisation lives in the data layer and the endpoint**, not in middleware
  or the UI. Verify a session's signature server-side; never trust an unverified
  session object.
- **Never point local development at the production database.** A schema push
  rewrites it.
- Media uploads go to object storage, never into the repo.
