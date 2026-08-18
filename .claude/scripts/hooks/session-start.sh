#!/usr/bin/env bash
# SessionStart hook — points the agent at the vault, or at /adapt if the kit has
# not been fitted to this project yet.
set -uo pipefail
cd "$(dirname "$0")/../../.." 2>/dev/null || exit 0
. .claude/scripts/stack.sh 2>/dev/null || true

emit() { printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"; }

if ! stack_is_adapted 2>/dev/null; then
  emit "AI DESIGN VAULT — NOT YET ADAPTED. This project carries the kit (.claude/ + obsidian/) but .claude/stack.json has adapted:false, so no path, binding or convention is fitted to this codebase yet. Before doing project work, run the /adapt command (skill: stack-adapt). It detects the framework, writes the stack profile, and every rule, skill and verify check then applies correctly. Do not guess paths from the docs in the meantime — the docs describe conventions, stack.json describes THIS project."
  exit 0
fi

FW="$(stack_get framework.name "$(stack_get framework.id this project)" | tr -d '\\"')"
emit "PROJECT GUIDE — AI Design Vault on ${FW}. All project documentation lives in the obsidian/ vault, which is the single source of truth for conventions; .claude/stack.json is the single source of truth for THIS project's paths, packages and commands — read a path from stack.json, never from an example in the docs. Before doing project work this session read obsidian/README.md (the Map of Content) and obsidian/workflows/ai-agent-guide.md (the hard rules), then open the topic note relevant to the task before writing code."
