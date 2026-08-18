---
tags: [frontend, seo, a11y, stable]
updated: 2026-08-18
---

# Semantic HTML & SEO Markup

How to lay out markup. Every page must be **semantic, accessible, and
SEO-correct** — this note is the canonical rulebook. `AGENTS.md` hard rule 10,
ADR-0014. Framework-neutral: the element names below are HTML, not a library.

## Principles

1. **The tag carries meaning; the class carries looks.** Choose elements for
   what they *are*, never for how they render. Visual size comes from Tailwind
   utilities / tokens — never from picking a different heading level.
2. **Native first.** A real `<button>` / `<a>` / `<nav>` beats a `<div>` plus
   ARIA. Reach for ARIA only to fill a genuine gap.
3. **No `<div>` soup.** Every wrapper should earn its place; prefer a semantic
   element or no element at all.
4. **DOM order = reading order.** Source order is what crawlers and screen
   readers follow — don't reorder meaningful content with CSS.

## Document landmarks

One landmark set per page:

| Element | Use |
|---------|-----|
| `<header>` | Site/page header (logo, primary nav) |
| `<nav>` | Navigation blocks — give each an `aria-label` if there are several |
| `<main>` | The page's primary content — **exactly one**, not nested. Views render it. |
| `<section>` | A thematic grouping — **must have an accessible name** (a heading + `aria-labelledby`, or `aria-label`) |
| `<article>` | Self-contained, independently distributable content |
| `<aside>` | Tangential content |
| `<footer>` | Site/page footer |

Add a skip link (`<a href="#main">Skip to content</a>`) when site navigation
precedes `<main>`.

## Headings

- **Exactly one `<h1>` per page**, describing the page.
- **Never skip levels** (`h2` → `h4`). The heading outline is the document's
  table of contents.
- Section order: each `<section>` opens with the next-level heading.
- Need a small-looking heading or a large-looking sub-label? Keep the correct
  level and restyle with utilities — never downgrade the tag.

## Content elements

Use the element that fits — don't default to `<div>`/`<span>`:

`<ul>`/`<ol>`/`<li>` lists · `<figure>`/`<figcaption>` captioned media ·
`<time dateTime="…">` dates · `<address>` contact info · `<blockquote>`/`<cite>`
quotes · `<dl>`/`<dt>`/`<dd>` term–definition pairs · `<strong>`/`<em>` for
real emphasis (not bolding).

## Interactive elements

- **`<button>` does something on the page; `<a href>` goes somewhere.** Never a
  click-handler `<div>`/`<span>`.
- `<button type="button">` unless it submits a form (avoids accidental submit).
- A link styled as a button is still an `<a>`; a button styled as a link is
  still a `<button>`.
- Navigation uses `bindings.link` from [[stack-profile]] — see [[routing-views]].

## Images & media

- Informative images: concise, meaningful `alt`. Decorative images: `alt=""`.
- Use `bindings.image` with explicit `width`/`height` (prevents CLS); mark the
  LCP image as priority/eager; give responsive images a `sizes`. Where the stack
  has no image component, a plain `<img>` with dimensions and `loading="lazy"` is
  correct. See [[seo-metadata]].
- `<video>`: provide `<track kind="captions">`; don't autoplay with sound.

## Forms

- `<form>` + every control labelled (`<label htmlFor>` or wrapping `<label>`).
- Group related controls with `<fieldset>`/`<legend>`.
- Correct `type`, `name`, `autoComplete`, `inputMode`, `required`.
- Errors: `aria-invalid` on the field + message linked via `aria-describedby`.

## Accessibility & ARIA

- Name icon-only / ambiguous controls (`aria-label` or visually-hidden text).
- Name unlabelled landmarks (`aria-label` / `aria-labelledby`).
- `aria-current="page"` on the active nav link.
- Visible focus everywhere — use `focus-visible:` utilities; never remove
  outlines without a replacement.
- All interactive elements keyboard-operable.
- `<html lang>` is set in the root layout.

## SEO markup

- One descriptive `<h1>`; a clean heading outline; descriptive internal-link
  anchor text (never "click here").
- Page metadata (title, description, canonical, OG) → the metadata generator,
  [[seo-metadata]]. Don't hand-write `<meta>`/`<title>` in components.
- **Structured data → JSON-LD only.** Use the structured-data helper
  ([[seo-metadata]]) for `Article` / `Product` / `BreadcrumbList` / `FAQPage`
  etc. **Do not** sprinkle microdata (`itemscope`/`itemprop`) or RDFa in markup.
- Breadcrumbs: `<nav aria-label="Breadcrumb">` + `<ol>`, paired with
  `BreadcrumbList` JSON-LD.
- External links: `rel="noopener"`; add `nofollow`/`sponsored`/`ugc` where
  appropriate.
- In-page anchor targets get a stable `id` (also powers hash-link scrolling —
  see [[smooth-scroll]]).

## `data-*` attributes

`data-*` is for **non-visual tooling hooks only**:

- ✅ test selectors (`data-testid`), analytics (`data-analytics-event`), JS
  behaviour / animation markers.
- ❌ never styling (use utilities/tokens) and never content (use props/hooks).
- Naming: kebab-case, prefixed by purpose — `data-analytics-*`, `data-testid`.

`data-*` attributes are **SEO-neutral** — search engines ignore them. SEO comes
from semantic tags, metadata, and JSON-LD, not from data attributes.

## Animation components & semantics

The [[motion-system]] primitives (`Inview`, `SpringTrigger`, `Hover`, `Handle`)
and the text binding all accept a **semantic element** prop (`tag` / `as`) —
**always pass the correct one**. A motion wrapper must never erase semantics;
this is the default failure, because a wrapper renders a `div` unless told
otherwise:

```tsx
<Inview tag="section" aria-labelledby="features-title">…</Inview>
<TextEngine tag="h2" id="features-title">Features</TextEngine>
```

Never leave a heading or landmark as the default `<div>` because it is animated.

## Checklist

- [ ] Exactly one `<h1>`; no skipped heading levels
- [ ] `<main>` present once; sections/nav/header/footer used correctly
- [ ] Every `<section>` has an accessible name
- [ ] Buttons vs links correct; no click-handler `<div>`s
- [ ] All images have `alt`, and dimensions that prevent layout shift
- [ ] Forms fully labelled
- [ ] Icon-only controls named; focus visible; keyboard-operable
- [ ] Structured data as JSON-LD; metadata via the generator
- [ ] Motion wrappers pass a semantic element
- [ ] `data-*` only for tooling hooks

## Related

[[component-conventions]] · [[seo-metadata]] · [[motion-system]] · [[design-system]] · [[new-page]]
