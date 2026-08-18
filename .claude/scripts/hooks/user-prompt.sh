#!/usr/bin/env bash
# UserPromptSubmit hook — one short reminder, before every request.
set -uo pipefail
cd "$(dirname "$0")/../../.." 2>/dev/null || exit 0
. .claude/scripts/stack.sh 2>/dev/null || true

emit() { printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$1"; }

if ! stack_is_adapted 2>/dev/null; then
  emit "REMINDER: .claude/stack.json is still unadapted. If this request involves project code, run /adapt first — otherwise every path and package you write will be a guess."
  exit 0
fi

emit "VAULT REMINDER: consult the relevant obsidian/ guide before acting — obsidian/frontend/motion-system.md for motion, obsidian/workflows/new-page.md to build a page, obsidian/frontend/component-conventions.md for components, obsidian/frontend/design-system.md for styling. Resolve every path and package name from .claude/stack.json, not from memory of another framework. If your work changes code, behaviour, dependencies or architecture, update the matching vault docs in the SAME turn: catalog notes under obsidian/frontend/, obsidian/meta/changelog.md, and obsidian/meta/decisions-log.md."
