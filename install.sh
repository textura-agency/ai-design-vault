#!/usr/bin/env bash
# Install the AI Design Vault kit into an existing project.
#
#   ./install.sh /path/to/your/project
#
# Copies .claude/, obsidian/ and the three root entry points. Never overwrites an
# existing file without telling you — collisions are reported and skipped, so an
# existing AGENTS.md survives and you merge it by hand.
#
# After installing, open the project in Claude Code and run /adapt.

set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-}"

if [ -z "$DEST" ]; then
  echo "usage: ./install.sh /path/to/your/project" >&2; exit 1
fi
if [ ! -d "$DEST" ]; then
  echo "error: $DEST is not a directory" >&2; exit 1
fi
DEST="$(cd "$DEST" && pwd)"
if [ "$DEST" = "$SRC" ]; then
  echo "error: source and destination are the same directory" >&2; exit 1
fi

copied=(); skipped=()

copy_path() {                       # copy_path <relative path>
  local rel="$1"
  if [ -e "$DEST/$rel" ]; then skipped+=("$rel"); return; fi
  cp -R "$SRC/$rel" "$DEST/$rel"
  copied+=("$rel")
}

copy_path ".claude"
copy_path "obsidian"
copy_path "AGENTS.md"
copy_path "CLAUDE.md"
copy_path ".cursorrules"

echo "installed into $DEST"
[ ${#copied[@]}  -gt 0 ] && printf '  copied:  %s\n' "${copied[*]}"
if [ ${#skipped[@]} -gt 0 ]; then
  printf '  skipped (already present): %s\n' "${skipped[*]}"
  echo
  echo "  Merge those by hand. An existing AGENTS.md usually wants the kit's"
  echo "  'Rule zero' and 'Hard rules' sections appended to it."
fi

cat <<'NEXT'

Next:
  1. Open the project in Claude Code.
  2. Run /adapt — it detects the framework and writes .claude/stack.json.
  3. Run /motion if the project has no motion layer yet.
NEXT
