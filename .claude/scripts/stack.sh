#!/usr/bin/env bash
# Shared reader for .claude/stack.json — sourced by verify.sh and usable ad hoc.
#
#   source .claude/scripts/stack.sh
#   stack_get paths.routes src/app        # dotted path, optional default
#   stack_get paths.protected             # arrays come back space-separated
#   stack_is_adapted && echo "profile ready"
#
# Uses jq if present, else node, else python3. One of the three exists on any
# machine that can run the project.

STACK_FILE="${STACK_FILE:-.claude/stack.json}"

stack_get() {
  local key="$1" def="${2:-}" out=""
  if [ -f "$STACK_FILE" ]; then
    if command -v jq >/dev/null 2>&1; then
      out="$(jq -r --arg k "$key" '
        (try getpath($k | split(".")) catch null)
        | if . == null then empty
          elif type == "array" then join(" ")
          else tostring end' "$STACK_FILE" 2>/dev/null)"
    elif command -v node >/dev/null 2>&1; then
      out="$(node -e '
        const fs=require("fs");
        let s; try { s=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); } catch { process.exit(0); }
        const v=process.argv[2].split(".").reduce((a,k)=>(a==null?a:a[k]),s);
        if(v==null) process.exit(0);
        console.log(Array.isArray(v)?v.join(" "):String(v));
      ' "$STACK_FILE" "$key" 2>/dev/null)"
    elif command -v python3 >/dev/null 2>&1; then
      out="$(python3 -c '
import json,sys
try: s=json.load(open(sys.argv[1]))
except Exception: sys.exit(0)
v=s
for k in sys.argv[2].split("."):
    if isinstance(v,dict) and k in v: v=v[k]
    else: sys.exit(0)
if v is None: sys.exit(0)
print(" ".join(map(str,v)) if isinstance(v,list) else (str(v).lower() if isinstance(v,bool) else str(v)))
' "$STACK_FILE" "$key" 2>/dev/null)"
    fi
  fi
  if [ -z "$out" ]; then printf '%s' "$def"; else printf '%s' "$out"; fi
}

stack_is_adapted() { [ "$(stack_get adapted false)" = "true" ]; }
stack_true()       { [ "$(stack_get "$1" false)" = "true" ]; }
