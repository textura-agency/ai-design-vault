---
tags: [workflow, ai, stable]
updated: 2026-08-18
---

# Workflow — Adapt the kit to a framework

The one-time (and after-upgrade) procedure that fits this kit to the host
project. Command: `/adapt`. Skill: `stack-adapt`. ADR: [[decisions-log]] ADR-0007.

## When to run it

- **First session in a project.** The `SessionStart` hook says "NOT YET ADAPTED".
- **After a framework upgrade or migration** — majors rename APIs, move
  directories and change env prefixes.
- **After a restructure** — paths moved, a `src/` was introduced, routes changed
  shape.
- **When `verify.sh` reports SKIPs it should not** — that is a `null` field in the
  profile, and a check that is not running.

## What it does

1. **Detects** — `.claude/scripts/detect-stack.sh` gathers evidence: manifest,
   lockfile, framework config, directory layout, route entry files, style
   entries, existing motion packages, env prefixes, git status.
2. **Resolves** every field in `.claude/stack.schema.json` from that evidence,
   confirming against the repo rather than assuming from the framework's
   conventions.
3. **Asks** only what the repo cannot answer — typically one question: *no motion
   library is installed; which binding, and may I install it?*
4. **Writes** `.claude/stack.json` with `"adapted": true`.
5. **Retargets** the `paths:` frontmatter in `.claude/rules/*.md` and fixes the
   prose inside them where it names a path. Deletes `engine-protected.md` if
   there is no protected zone.
6. **Records** the result in [[stack-profile]], [[tech-stack]],
   [[folder-structure]], [[changelog]] and an ADR for anything switched off.
7. **Proves it** — `verify.sh` (read the profile header and the SKIPs), plus lint
   and build.

## What it deliberately does not do

- **It does not rewrite the vault into one framework's idiom.** The notes stay
  neutral so they survive the next upgrade; specifics live in the profile
  ([[meta/README]] neutrality rule).
- **It does not install packages silently.** A motion binding is a real decision
  with a bundle cost and an ADR.
- **It does not invent paths.** A path that does not exist is not recorded — with
  one exception, `paths.views`, which is created because route→view delegation is
  load-bearing (ADR-0003).

## Conventions that can be switched off

`conventions` in the profile. Turning one off is legitimate when the host project
genuinely conflicts — and needs an ADR saying why:

| Flag | Off means |
|---|---|
| `routesDelegateToViews` | routes hold UI. Accepts framework-coupled UI code; the delegation check stops running |
| `namedExports` | the codebase is committed to default exports |
| `serverFirst` | an SPA with no server-render path at all |
| `tokenTiers` | an existing design system with its own token grammar |

Prefer "keep the convention and migrate gradually" over switching it off. Two
grammars in one codebase is worse than either one.

## Related

[[stack-profile]] · [[agent-harness]] · [[ai-agent-guide]] · [[motion-bindings]]
