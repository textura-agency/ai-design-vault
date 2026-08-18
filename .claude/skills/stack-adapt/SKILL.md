---
name: stack-adapt
description: Fit this kit to whatever framework it was dropped into — detect the framework, package manager, paths, bindings and commands, write .claude/stack.json, retarget the path-scoped rules, and record the profile in the vault. Use on the first session in a project (the SessionStart hook says "NOT YET ADAPTED"), after a framework upgrade or migration, when paths move, or when the user says "adapt", "set this up", "wire this kit in", or verify.sh reports SKIPs it should not.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# Adapt the kit to this project

The kit ships framework-neutral. This procedure fits it to the host project once,
so every rule, skill and check afterwards points at real paths and real packages.

**Detect from evidence, not from vibes.** A `package.json` dependency, a config
file, a directory that exists — those are evidence. "It's probably Next" is not.

## 1. Gather evidence

```bash
.claude/scripts/detect-stack.sh
```

Read its output fully. Then open what it flagged: the manifest, the framework
config file, the top-level source tree. If the framework is one you have not
seen in this exact version, **read the installed docs** rather than recalling an
API (`node_modules/<framework>/**`, the framework's own docs site). Frameworks
rename things between majors — that is exactly what this kit warns about.

`references/frameworks.md` in this skill folder holds the mapping for the common
stacks: paths, bindings, capabilities and the trap each one carries. Use it as a
starting point, then **confirm each value against the real repo** — a project is
allowed to lay itself out however it likes, and the repo wins over the table.

## 2. Resolve every field

Work through `.claude/stack.schema.json` field by field. Rules:

- **Paths must exist, or be deliberately created.** Never record a path that is
  not there. The one exception is `paths.views` — most frameworks have no such
  concept, and the route→view convention is one of the kit's load-bearing rules
  (see `obsidian/frontend/routing-views.md`). Create the directory, and say so.
- **`paths.protected` starts empty** unless the project actually carries a
  vendored motion engine or generated code that must not be hand-edited.
- **`paths.routeEntryGlob` matters where any file is a route.** Astro
  (`["*.astro"]`) and Nuxt (`["*.vue"]`) name pages freely; leave it empty where
  the framework has a fixed entry filename. Get this wrong and the route→view
  check silently inspects nothing.
- **Bindings come from what is installed.** Read `package.json` — do not assume
  the house default is present. A binding that does not exist yet is `null`.
- **`envPublicPrefix` is not cosmetic.** It is what `verify.sh` uses to tell a
  leaked secret from a public value. Get it right per framework (Vite `VITE_`,
  SvelteKit/Astro `PUBLIC_`, Next `NEXT_PUBLIC_`, Nuxt `NUXT_PUBLIC_`).
- **Commands are verbatim, with the package manager** — `pnpm build`, not
  `build`. Take them from `scripts` in the manifest; if a script is missing,
  record `null` rather than inventing one.
- **Capabilities decide which checks run.** `serverComponents: false` on a SPA
  is correct and makes the server-first check skip instead of failing noise.
- **`notes[]` is for what the fields cannot say** — a non-standard layout, a
  deliberate deviation, a quirk you hit while detecting. Later agents read it.

## 3. Ask only what you genuinely cannot infer

Batch the questions; there should rarely be more than three. Worth asking:

- **No motion library installed.** Which binding — and may it be installed?
  Present the recommendation from `obsidian/frontend/motion-bindings.md` for this
  framework, and what it changes. Do not install anything before the answer.
- **Two plausible views/components layouts** already in use — pick theirs, but
  confirm which.
- **A convention genuinely conflicts** with the host project (e.g. the codebase
  is committed to default exports, or routes that already hold UI). Offer:
  keep the kit's convention and migrate gradually, or switch the flag off in
  `conventions` and log an ADR saying why.

Not worth asking: anything the repo already answers.

## 4. Write the profile

Write `.claude/stack.json`, set `"adapted": true` and `"adaptedAt"` to today's
date. Validate it parses:

```bash
node -e 'JSON.parse(require("fs").readFileSync(".claude/stack.json","utf8"));console.log("ok")'
```

## 5. Retarget the path-scoped rules

`.claude/rules/*.md` carry `paths:` globs in their frontmatter. They ship broad so
they work before adapting; **narrow them to this project now**, or they will fire
on the wrong files (or not at all).

| Rule | Point it at |
|------|-------------|
| `motion.md` | components, views, layouts — every extension in `extensions.component` |
| `design-tokens.md` | `paths.styles` and any other style entry |
| `routing-views.md` | `paths.routes`, `paths.views` |
| `api-env.md` | `paths.server`, `paths.env` |
| `engine-protected.md` | exactly `paths.protected` — **delete this rule if that list is empty**, an unmatched rule is dead weight |
| `data-layer.md` | wherever the CMS/DB client lives once one exists; leave broad until then |

Also fix the prose inside each rule where it names a path or a package —
they are written to be edited, and a rule that cites `src/app/**` in an Astro
project teaches the wrong thing.

## 6. Record it in the vault

- `obsidian/architecture/stack-profile.md` — fill in the **Resolved profile**
  section: framework, version, the path table, the bindings, and every judgement
  call you made.
- `obsidian/architecture/tech-stack.md` — the real dependency list.
- `obsidian/architecture/folder-structure.md` — the real tree.
- `obsidian/meta/changelog.md` — a dated "kit adapted to <framework>" entry.
- `obsidian/meta/decisions-log.md` — an ADR for any convention you switched off
  or any binding chosen over an alternative.

Do not rewrite the whole vault into framework-specific prose. The notes are
deliberately neutral so they stay true after an upgrade; the *profile* is where
the specifics live.

## 7. Prove it

```bash
.claude/scripts/verify.sh
```

Read the header line — it should name the framework and the real source root.
Then read the SKIPs: each one is a check that could not apply. A SKIP because the
stack genuinely lacks the concept is fine (no server components in a SPA). A SKIP
because a path is still `null` is unfinished work.

Run `commands.lint` and `commands.build` too — if the kit's arrival broke the
project, better to know now.

## 8. Report

State plainly:

- framework + version detected, and from what evidence
- the path table you wrote
- bindings chosen, and any that are still `null` (with what the user gains by
  filling them)
- conventions switched off and why
- what you created (a `views/` directory, a token file)
- what still needs the user: installing a motion binding, a design-token pass, a
  CMS decision

If the project has **no motion layer yet**, say so and point at `/motion` — the
kit's whole point is the motion system, and an unadapted-motion project gets
none of it.
