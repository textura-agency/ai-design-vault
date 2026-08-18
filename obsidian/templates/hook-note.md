---
tags: [frontend, hook, wip]
updated: 2026-08-18
---

# Hook — {{title}}

> Template — duplicate this note when documenting a new hook / composable /
> store, and link it from [[hooks]].

- **File:** `<source>/hooks/<domain>/<name>.<ext>`
- **Status:** #wip

## Purpose

What state or behaviour this encapsulates, and why it is not just inline code.

## Signature

```
function {{title}}(/* args */): /* return */
```

| Param | Type | Default | Description |
|---|---|---|---|
| | | | |

**Returns:** …

## Usage

```
// example
```

## Notes

- **Server safety** — what happens when there is no `window`.
- **Cleanup** — what it unsubscribes, and when.
- **Per-frame work** — subscribes to the shared ticker, never its own rAF
  ([[motion-system]]).
- **Dependencies** on stores or other hooks.

## Related

[[hooks]] ·
