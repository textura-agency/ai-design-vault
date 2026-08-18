#!/usr/bin/env bash
# Stop hook — blocks at most once per turn to confirm the vault was updated.
# The TMPDIR marker keyed by session id guarantees termination.
set -uo pipefail
cd "$(dirname "$0")/../../.." 2>/dev/null || exit 0

payload="$(cat 2>/dev/null || true)"
sid=""
if command -v jq >/dev/null 2>&1; then
  sid="$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null)"
fi
[ -z "$sid" ] && sid="$(printf '%s' "$payload" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
[ -z "$sid" ] && sid="nosession"

M="${TMPDIR:-/tmp}/claude-aidv-stop-${sid}"
if [ -f "$M" ]; then rm -f "$M"; exit 0; fi
touch "$M"

printf '%s\n' '{"decision":"block","reason":"Before finishing this turn: if you changed code, behaviour, dependencies or architecture, update the matching obsidian/ vault docs now — catalog notes under obsidian/frontend/ for components, hooks and utils; obsidian/meta/changelog.md for notable changes; obsidian/meta/decisions-log.md for new architectural decisions; and .claude/stack.json if a path, binding or command changed. If the vault already reflects everything done this turn, stop."}'
