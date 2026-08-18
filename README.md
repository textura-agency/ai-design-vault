# AI Design Vault

A **framework-agnostic build system for immersive websites** — the documentation,
conventions and agent harness that make AI coding tools produce clean,
production-ready, animation-heavy sites on the first pass.

Drop it into **any** project — Next, Astro, SvelteKit, Nuxt, a Vite SPA, Remix,
plain HTML — run `/adapt`, and the whole system fits itself to that codebase.

> Built by [Textura](https://textura.agency). The framework-locked sibling is
> [`next16-claude-starter`](https://github.com/textura-agency/next16-claude-starter);
> this is the same way of working, without the framework.

---

## ⚡ Install in one prompt

From the project you want to add it to, paste this into **Claude Code**:

```text
Clone https://github.com/textura-agency/ai-design-vault into a temp folder, copy its .claude/, obsidian/, AGENTS.md, CLAUDE.md and .cursorrules into this project (don't overwrite an existing AGENTS.md — merge it), delete the temp folder, then run /adapt to fit the kit to this codebase.
```

Or by hand:

```bash
git clone https://github.com/textura-agency/ai-design-vault /tmp/aidv
cp -R /tmp/aidv/.claude /tmp/aidv/obsidian /tmp/aidv/AGENTS.md /tmp/aidv/CLAUDE.md /tmp/aidv/.cursorrules .
rm -rf /tmp/aidv
```

Then open Claude Code in the project and run **`/adapt`**. It detects the
framework, writes the stack profile, retargets the rules and records the result.
There is a helper script too — `./install.sh /path/to/your/project`.

---

## What you actually get

Not boilerplate. **A way of working, and the machinery that enforces it.**

| Piece | What it does |
|---|---|
| `obsidian/` | An Obsidian vault: every convention, decision and playbook — framework-neutral, so it survives upgrades |
| `.claude/stack.json` | **The stack profile** — this project's paths, packages and commands, machine-readable |
| `.claude/rules/` | Path-scoped rules that auto-load when a matching file is read |
| `.claude/skills/` | 13 procedures: adapt, motion, QA, Figma→section, SEO, AEO, schema, migration, ship, CMS, database, auth, 3D perf |
| `.claude/agents/` | 4 subagents: section builder, motion reviewer, vault librarian, SEO auditor |
| `.claude/commands/` | `/adapt` `/motion` `/new-page` `/section` `/qa` `/ship` `/seo` `/cms` `/data` `/migrate-site` |
| `.claude/scripts/verify.sh` | A stack-aware mechanical gate — the rules a script *can* check |
| Hooks | Session start / every prompt / end of turn — the workflow runs without being asked for |

## The idea

Two sources of truth, doing different jobs:

- **The vault says *how*** — springs not keyframes, three-tier tokens, routes
  delegate to views, server-first, semantic markup. Written framework-neutral on
  purpose.
- **`stack.json` says *where and with what*** — `src/routes` or `src/app`,
  `svelte/motion` or `@react-spring/web`, `PUBLIC_` or `NEXT_PUBLIC_`, `pnpm
  build` or `yarn build`.

Every rule, skill and check reads the profile instead of hardcoding a framework.
That is the whole trick: **one system, any stack.**

## The hard rules it enforces

1. All real motion is spring-based, through **one** binding. No keyframes, no
   second animation library.
2. Design tokens in three strict tiers — nothing hardcoded.
3. Routes delegate to views, so the UI outlives the framework.
4. Ship the least client JavaScript that works.
5. Semantic, SEO-correct HTML — content in the DOM regardless of motion state.
6. Verify before reporting done: `verify.sh`, lint, build, and a judgement pass.

Full list: [`AGENTS.md`](./AGENTS.md) ·
[`obsidian/workflows/ai-agent-guide.md`](./obsidian/workflows/ai-agent-guide.md)

## The motion system

The kit ships **no code** — it ships a **contract**. `Inview`, `SpringTrigger`,
`Hover`, `Handle`, a shared render loop, a scroll-position grammar, and a
split-text recipe, with identical names and props in every framework. `/motion`
builds them on whichever spring library fits the stack:

| Stack | Binding |
|---|---|
| Any React | `@react-spring/web` + `spring-text-engine` |
| Svelte 5 | `svelte/motion` (built in) |
| Vue / Nuxt | `motion-v` |
| Vanilla / Astro | `motion` |

A page written against the contract reads the same in any of them.

## Hooks do the enforcement for you

`.claude/settings.json` ships **three hooks** — you don't have to ask for any of
this in your prompt:

| Hook | Fires | Effect |
|---|---|---|
| `SessionStart` | new chat / resume | Points at the vault — or at `/adapt` if the kit isn't fitted yet |
| `UserPromptSubmit` | every request | Reminds the agent to read the right guide and resolve paths from the profile |
| `Stop` | end of every turn | Blocks **once** to confirm the docs and profile were updated |

Inspect, edit or disable them anytime with `/hooks`.

## How to write a good request

Because the conventions live in the vault, your prompts focus on **what** you
want, not **how** to write it:

- **Say what to build, not how.** *"Add a testimonials section with a horizontal
  scroll carousel"* — not *"use a scrub trigger with a parallel spring…"*.
- **Name the page or view clearly.** Routes delegate to views; reference the view
  when iterating.
- **Cite a vault note only to *override* a convention.** Rare — the hooks pull in
  the right guide on their own.
- **Trust the hard rules.** They are enforced; you don't need to repeat them.

## 💸 Cost expectations

This kit is **token-intensive by design**. Every prompt fans out into the vault,
and the hooks re-inject context on every turn. That bought-clean code costs
tokens.

> **Minimum recommended plan: [Claude Max (5×)](https://www.anthropic.com/pricing).**
> A standard Pro plan will hit usage limits quickly on a real session.

## Removing it

Delete `.claude/`, `obsidian/`, `AGENTS.md`, `CLAUDE.md` and `.cursorrules`.
Nothing else in the project depends on it — the kit never touches application
code except the files you asked it to write.

## License

[Unlicense](./LICENSE.md) — public domain. Copy it, change it, ship client work
with it, sell it. No attribution required.

## Documentation

Start at [`obsidian/README.md`](./obsidian/README.md) — the Map of Content. Open
the `obsidian/` folder in [Obsidian](https://obsidian.md) for the linked,
navigable version.
