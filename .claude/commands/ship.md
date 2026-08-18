---
description: Pre-launch gate — build, rules, SEO, performance, a11y, secrets, deploy
---

Run the full pre-launch gate using the `ship-check` skill.

Order: build + lint + `.claude/scripts/verify.sh` → `qa-verify` across every route
→ `seo-audit` → measured performance (Lighthouse, mobile) → accessibility pass →
secret and env hygiene → deploy steps.

Take every command from `.claude/stack.json → commands` — never guess the package
manager. Check the **production build**, not the dev server.

If this project replaces an existing live site, the `site-migration` redirect map
must be complete and verified **before** launch — check it, and stop if it is not.

Report each gate as passed / failed-and-fixed / not-verified-because. Do not
report a pass you did not actually run.
