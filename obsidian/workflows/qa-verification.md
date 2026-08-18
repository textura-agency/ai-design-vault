---
tags: [workflow, qa, stable]
updated: 2026-08-18
---

# Workflow — QA & Verification

How work is checked before it is called done. Skill: `qa-verify`. Command: `/qa`.
Hard rule 11.

## Two layers, in order

### Layer 1 — mechanical

```bash
.claude/scripts/verify.sh          # whole source root
.claude/scripts/verify.sh <path>   # scoped
```

plus the project's own gates from `stack.json → commands`: lint, typecheck,
build.

- **FAIL** — must be fixed. No exceptions.
- **WARN** — a judgement call. Fix it, or justify it explicitly in the summary.
- **SKIP** — the check could not apply. Fine when the stack genuinely lacks the
  concept; **a gap to close** when it is caused by a `null` in the profile
  (ADR-0010).

The header line names the framework and source root the script used. If that
surprises you, the profile is wrong — fix it before trusting the result.

### Layer 2 — judgement

A script cannot see a design, weigh a token name, or tell a reveal from a scrub.
The `qa-verify` skill walks the full list: design fidelity against a **re-fetched**
Figma node, token discipline, motion primitive choice, semantics and a11y,
responsive down to 320px, architecture and client-JS budget.

Two rules people skip:

- **Re-fetch the design.** Never QA against your own earlier summary — the
  summary is what dropped the value you are checking.
- **Check the production build**, not the dev server, before anything is called
  shippable.

## The loop

1. Run layer 1, fix every FAIL.
2. Walk layer 2 section by section, fixing as you go.
3. Re-run layer 1 — fixes introduce violations.
4. Repeat until clean.

## Reporting

State plainly: what failed and was fixed, what WARNs were kept and why, which
design values could not map to tokens (design-review flags), and what could not be
verified at all (no design, no device, no live URL).

**Never report a clean pass you did not achieve.** A verify you did not run is not
a pass, and saying so costs nothing compared to finding it in production.

## Related

[[ai-agent-guide]] · [[new-page]] · [[ship]] · [[agent-harness]]
