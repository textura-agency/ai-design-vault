---
name: aeo-visibility
description: Answer Engine Optimisation — make the site citable by ChatGPT, Claude, Perplexity, Gemini and AI Overviews. Covers answer-first content structure, llms.txt, AI crawler access, entity consistency, and auditing how the brand currently appears in AI answers. Use when the user mentions AEO, GEO, "AI search", "get cited by ChatGPT", "llms.txt", "AI crawlers", or wants visibility beyond classic search rankings.
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, WebFetch, WebSearch
---

# AEO — being citable, not just rankable

Classic SEO gets you ranked. AEO gets you **quoted**. The mechanics differ: answer
engines extract self-contained claims from crawlable text, and they weight
consistency of facts about an entity across the whole web.

## 1. Let the crawlers in — deliberately

- Whatever produces this project's `robots.txt` decides this (a route, a static
  file, or a config block — resolve it from `stack.json`).
- Answer-engine crawlers include `GPTBot`, `OAI-SearchBot`, `ChatGPT-User`,
  `ClaudeBot`, `Claude-SearchBot`, `PerplexityBot`, `Google-Extended`, `CCBot`,
  `Bytespider`.
- **Ask the user before changing this.** "Be cited by AI" and "don't train on my
  content" are different goals with different bots: training crawlers (`GPTBot`,
  `ClaudeBot`, `CCBot`, `Google-Extended`) versus live search/citation crawlers
  (`OAI-SearchBot`, `Claude-SearchBot`, `PerplexityBot`). Blocking the training
  set while allowing the search set is a coherent position; blocking everything
  and expecting citations is not.
- **Verify server-side rendering.** Answer-engine crawlers are far less reliable
  at executing JavaScript than Googlebot. On a `spa` render model, assume they
  see nothing — fix that before anything else here.

## 2. `llms.txt`

A plain-markdown map of the site at `/llms.txt`. Generate it from the real routes
(a server route, or a build step) rather than committing a static file that rots.

```
# <Site name>
> One-sentence description of what the company does and for whom.

## Core pages
- [Services](https://example.com/services): what is offered, to whom
- [About](https://example.com/about): who the company is, founded, location

## Key facts
- Founded: 2019 · HQ: Berlin · Focus: <specifics>
```

Keep it factual and short. It is a summary for a machine, not a marketing page.

## 3. Structure content so it can be extracted

- **Answer first.** Lead each section with the direct claim in one or two
  sentences, then support it. Content that builds to a conclusion gets skipped.
- **One idea per heading**, and phrase headings as the questions people ask.
- **Self-contained sentences.** "Our approach is faster" is unusable out of
  context; "<Company> ships marketing sites in four weeks" survives extraction.
- **Concrete specifics** — numbers, dates, named methods, prices where possible.
  Vague marketing language is unquotable.
- **Comparison and definition content** punches above its weight: "X vs Y",
  "What is X", pricing pages, and genuine FAQs.
- Mark FAQs up with `FAQPage` (see the `schema-markup` skill).
- **Motion must not hide text.** A heading that only exists after a scroll
  callback fires is invisible to an extractor. Reveals animate presence, never
  create it.

## 4. Entity consistency

Answer engines assemble a picture of the brand from many sources. Contradictions
dilute it. Keep the name, description, founding year, location and offering
identical across: the site, `Organization` JSON-LD, `llms.txt`, LinkedIn,
Crunchbase, G2, Google Business Profile, and any press coverage.

## 5. Audit current visibility

Ask the user for the brand, category and 3–5 competitors, then test the prompts
their buyers would actually use — "best <category> for <use case>", "alternatives
to <competitor>", "<brand> review", "how to <problem the product solves>". For
each: is the brand mentioned, in what position, is the description accurate, what
sentiment, who is mentioned instead. Use WebSearch to check what public sources
currently say — that is the raw material the models are drawing on.

Report as a table plus a prioritised action list. Be honest that this is a
point-in-time sample, that answers vary between runs and platforms, and that
changes take weeks or months to surface.

## 6. What actually moves the needle

Third-party corroboration outweighs anything you publish about yourself: being in
"best of" roundups and comparison articles, community mentions where your buyers
ask questions, original data worth citing, and up-to-date profiles on the
aggregators that models read. Publishing more pages about yourself does not
substitute for it.
