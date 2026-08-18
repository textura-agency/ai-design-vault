---
tags: [frontend, motion, stable]
updated: 2026-08-18
---

# Text Motion

All **text animation** goes through `stack.json → bindings.textMotion`. Do not
build a bespoke text animator per section. For non-text motion see
[[motion-system]]. ADR: [[decisions-log]] ADR-0009.

| Binding | When |
|---|---|
| `spring-text-engine` | any React stack. Full API: [[text-engine-reference]] |
| `recipe` | everything else — the implementation below, built **once** as a shared component |

## How split-text motion works

The text is split into **line / word / letter** slots, and each slot gets its own
spring with a stagger between them. Layers nest:

```
wrapLine → line → wrapWord → word → wrapLetter → letter
```

Each layer has an **in** (visible destination) and **out** (hidden resting) state.
The `wrap*` layers are the clip boxes: they carry `overflow: hidden` so a slot can
slide in from outside its own box.

## The three traps

These bite every implementation. They are hard rule 3.

### 1. Never use a manual/imperative mode for scroll-driven text

Use the declarative modes — `once`, `always`, `forward`, or scroll `progress`.
An imperative `play()` called from an effect re-introduces exactly the timing
bugs the trigger modes exist to prevent.

| Mode | Behaviour |
|---|---|
| `always` | plays in on enter, out on leave; repeats |
| `once` | plays in once, never replays |
| `forward` | plays in on downward scroll only |
| `progress` | driven by scroll between `start`/`end` — `interpolate` (smooth) or `toggle` (snap) |

### 2. The container is flex — `text-align` alone does nothing

Slots are laid out as **flex items with wrapping**, so `text-align` does not
position them; `justify-content` does. A lone `text-center` silently does
nothing.

Always set **both** on the container: `justify-*` does the real work, `text-*`
keeps plain-text fallbacks, the hidden crawler copy and nested inline content
aligned.

| Intent | Class pair |
|---|---|
| Left *(default)* | `text-left justify-start` |
| Centre | `text-center justify-center` |
| Right | `text-right justify-end` |

Because the container wraps, `justify-content` applies **per wrapped line** —
which is what you want for a multi-line heading.

> [!warning] Never `justify-between`
> The flex items are **words**, not lines. It spreads every line's words
> edge-to-edge, including the last one — that reads as broken justified text.

### 3. Clipping cuts to the line-height box — keep leading ≥ 1.1

With clipping on, the wrap layers are inline-block boxes whose height comes from
`line-height`. Tight leading makes that box shorter than the glyphs, so
descenders (`g y p j`) and accented caps get shaved. The clip is required — it is
what hides the text before it slides in — so the fix is the leading.

- **Never `leading-none` (1) with clipping.** It is the single most common cause
  of shaved text.
- **Use `leading-display` (1.1) as the floor.** The token exists for this.
- Set it **on the container**; `line-height` inherits to every wrap layer.
- Watch size utilities: many `text-*` scales above `text-4xl` ship
  `line-height: 1` and clip.

If a design genuinely needs tighter visual leading, do not shrink the container's
leading — give the clip box room and pull the layout back with a matching
negative margin on the wrap layer (`py-[0.15em] -my-[0.15em]`).

## The recipe (non-React stacks)

Build this once, as one shared component, on `bindings.motion`:

1. **Split** the text content into slots — lines, words or letters — preserving
   nested inline elements (`<strong>`, `<em>`, links, icons) rather than
   flattening to a string. Splitting into *lines* requires measuring after layout,
   so re-split on resize and on font load.
2. **Keep a plain-text copy in the DOM** for crawlers and assistive tech —
   visually hidden, textually complete. Split text is a pile of spans to a
   screen reader otherwise.
3. **Wrap** each slot in a clip box when the motion slides in.
4. **Spring per slot**, staggered by index (`delayIn + index * stagger`), all
   driven from the shared ticker.
5. **Trigger** with the same modes as above, using the scroll grammar from
   [[motion-system]].
6. **Reduced motion** → render the plain text at its final state; skip the split
   entirely. This is the cheapest correct path, and the fastest.
7. **Restore on unmount** so the DOM is left as it was found.

## Common patterns

**Line-by-line heading reveal** — the workhorse. Lines slide up from their clip
box, staggered ~100ms, on `once`. Leading `1.1` or looser, `justify-*` matched to
`text-*`.

**Word-by-word fade-up for body copy** — words rise a few px with opacity,
staggered ~60ms. No clipping needed, so leading is free.

**Scroll-driven progress** — `progress` mode with `interpolate` between
`start`/`end` positions, for text that resolves as the reader scrolls through it.

Match value types across in/out states (`y: '0%'` / `y: '100%'`, or `y: 0` /
`y: 60` — never one of each).

## Related

[[motion-system]] · [[text-engine-reference]] · [[html-semantics]] · [[design-system]]
