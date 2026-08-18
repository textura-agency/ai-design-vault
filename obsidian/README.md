---
tags: [moc, home]
updated: 2026-08-18
---

# 🧠 AI Design Vault — Project Brain

This vault is the **single source of truth for conventions** — how work is done
in this project, and why. It is written to be **framework-neutral on purpose**,
so it stays true when the framework moves under it.

> [!important] Two sources of truth, different jobs
> **This vault** = *how* (conventions, decisions, playbooks) — neutral, portable.
> **`.claude/stack.json`** = *where and with what* (paths, packages, commands) —
> specific to this project, written by `/adapt`.
>
> Never take a path or an import from an example in these notes. Resolve it from
> `stack.json`. Examples here are illustrations, not addresses.

> [!info] What is this?
> The AI Design Vault is a portable build system for **immersive,
> animation-heavy websites** — spring-based motion, a strict three-tier token
> system, semantic SEO-correct markup, and an agent harness that enforces all of
> it. Drop it into any framework; `/adapt` fits it to the codebase.

## 🗺️ Map of Content

### 00 — Meta
- [[meta/README|Meta overview]] — how to use and maintain this vault
- [[changelog]] — log of notable changes to **this** project (starts fresh per project)
- [[decisions-log]] — Architecture Decision Records: why the conventions are what they are

### 01 — Architecture
- [[stack-profile]] — **start here** — what `stack.json` is, and this project's resolved profile
- [[system-overview]] — the big picture, request lifecycle, mental model
- [[tech-stack]] — every dependency and why it is here
- [[folder-structure]] — where everything lives and what belongs where
- [[data-flow]] — how state, scroll and motion data move through the app
- [[environment-variables]] — config & secrets handling

### 02 — Frontend
- [[routing-views]] — route → view delegation, server-first rendering
- [[design-system]] — the three-tier token system and styling rules
- [[motion-system]] — the primitive contract (the core of this kit)
- [[motion-bindings]] — which spring library per framework, and the invariant
- [[text-motion]] — split-text animation, its traps, and the recipe
- [[text-engine-reference]] — full `spring-text-engine` API reference (React stacks)
- [[smooth-scroll]] — smooth scrolling and the scroll store
- [[component-conventions]] — how to write & place components
- [[html-semantics]] — semantic, accessible, SEO-correct markup rules
- [[seo-metadata]] — metadata, sitemap, robots, structured data
- [[components]] — component catalog (fill in per project)
- [[hooks]] — hooks/composables catalog
- [[utils]] — utility catalog

### 03 — Backend
- [[backend/README|Backend overview]] — API layer, CMS, database, auth
- [[api-architecture]] — endpoint convention, secrets, the response envelope
- [[cms]] — headless CMS: choosing one, wiring it the same way regardless
- [[database]] — database: connections, keys, RLS, migrations

### 04 — Workflows
- [[ai-agent-guide]] — rules of engagement for AI agents working in this repo
- [[adapt-stack]] — fitting the kit to a framework, and re-fitting after an upgrade
- [[agent-harness]] — the `.claude/` execution layer: commands, rules, skills, agents
- [[new-page]] — playbook for implementing a new page/section
- [[generic-layout-prompt]] — fill-in prompt template for a new page/section
- [[figma-to-code]] — turning a Figma frame into components
- [[qa-verification]] — how work is checked before it is called done
- [[ship]] — the pre-launch gate and deployment
- [[seo-aeo]] — SEO & answer-engine visibility as an ongoing practice
- [[site-migration]] — protecting rankings when rebuilding a live site
- [[optimize-3d-scene]] — performance work on a three.js/WebGL scene

### Templates
- [[templates/component-note|Component note template]]
- [[templates/hook-note|Hook note template]]
- [[templates/adr-note|ADR template]]

## 🏷️ Tag legend

| Tag | Meaning |
|-----|---------|
| `#stable` | Documented and reliable — safe to depend on |
| `#wip` | Work in progress / partially documented |
| `#todo` | Needs attention or is unfinished |
| `#decision` | Records or relates to an architectural decision |
| `#do-not-modify` | Code that must not be edited (a vendored engine) |
| `#stack-specific` | Content that is true only for this project's framework |

## 🔌 Obsidian setup

Open this folder (`obsidian/`) as an Obsidian vault. Recommended:
- **Graph view** — see how conventions, components and decisions connect
- **Dataview plugin** — query notes (e.g. list all `#wip` pages)
- **Templates core plugin** — point it at the `templates/` folder
