---
tags: [meta, stable]
updated: 2026-08-18
---

# Meta — How this vault works

Documentation *about* the documentation.

## Purpose

The vault is the project's **second brain**. It exists so that any contributor —
human or AI — can understand how this project is built without reverse-engineering
the codebase. The code is the *what*; this vault is the *why* and *how*.

## Structure

```
obsidian/
├── README.md       ← vault home / Map of Content
├── meta/           ← docs about the docs, changelog, decisions
├── architecture/   ← system-level: the stack profile, structure, data flow
├── frontend/       ← everything UI: routing, styling, motion, components
├── backend/        ← API layer, CMS, database, auth
├── workflows/      ← repeatable playbooks & AI agent rules
└── templates/      ← note templates for new components/hooks/ADRs
```

## The neutrality rule

> [!important] Keep these notes framework-neutral
> The notes describe **conventions**, which outlive framework majors. Project
> specifics — paths, package names, commands — live in `.claude/stack.json` and
> are summarised in [[stack-profile]].
>
> When a note genuinely needs a framework-specific passage, mark it
> `#stack-specific` and keep it short. Rewriting a general note into one
> framework's idiom is how this vault stops being portable — and how it starts
> lying after an upgrade.

## Conventions

- **Wikilinks** — link generously with `[[note-name]]`. A link to a not-yet-written
  note is fine; it marks something worth documenting later.
- **Frontmatter** — every note carries `tags` and an `updated` date.
- **One concept per note** — keep notes focused and linkable.

## Maintenance rules

1. Dependency changes → update [[tech-stack]] and add a [[changelog]] entry.
2. An architectural choice → add an ADR to [[decisions-log]], continuing the
   existing numbering.
3. A component/hook added → document it in the relevant catalog note.
4. A path, package or command changed → update **`.claude/stack.json`** as well.
   A stale profile silently disables checks in `verify.sh`; that is worse than a
   stale paragraph.
5. Keep [[motion-system]] in sync with the actual primitives in the code — that
   contract is the heart of the kit.

The `vault-librarian` agent does this pass on request.

## Inherited vs. project content

- **[[decisions-log]]** ships **populated**. ADR-0001 … explain why the kit's
  conventions exist, and notes link them by number — so keep the numbers stable.
  Add your project's decisions on top. Amending an inherited decision is fine:
  write a new ADR saying so rather than editing the old one.
- **[[changelog]]** ships **empty**, with a baseline entry. It logs *this*
  project's history, not the kit's.
- **[[stack-profile]]**, [[tech-stack]] and [[folder-structure]] are filled in by
  `/adapt` and edited in place as the project diverges.
