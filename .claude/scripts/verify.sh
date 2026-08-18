#!/usr/bin/env bash
# Mechanical verification of the hard rules in AGENTS.md /
# obsidian/workflows/ai-agent-guide.md — for whatever framework this kit was
# dropped into.
#
# Everything stack-specific (paths, file extensions, motion binding, env prefix,
# which conventions apply) is read from .claude/stack.json. Checks whose
# preconditions are not met are SKIPPED, not failed — an honest skip beats a
# meaningless pass.
#
# Only objectively decidable rules live here. Judgement calls (visual fidelity,
# "is this token named well", is this the right motion primitive) belong to the
# qa-verify skill, which a model runs. This script is the floor, not the ceiling.
#
# Usage:  .claude/scripts/verify.sh [path ...]     (default scope: paths.source)
# Exit:   0 = no FAILs, 1 = one or more FAILs. WARNs never fail the run.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=/dev/null
. "$(dirname "$0")/stack.sh"

RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'
[ -t 1 ] || { RED=""; YEL=""; GRN=""; DIM=""; OFF=""; }

fails=0; warns=0; skips=0

report() {  # report LEVEL "rule" "why" "output"   — empty output means it passed
  local level="$1" rule="$2" why="$3" out="${4:-}"
  [ -z "$out" ] && return 0
  if [ "$level" = FAIL ]; then
    fails=$((fails+1)); printf '%s\n' "${RED}FAIL${OFF}  ${rule}"
  else
    warns=$((warns+1)); printf '%s\n' "${YEL}WARN${OFF}  ${rule}"
  fi
  printf '%s\n' "${DIM}      ${why}${OFF}"
  printf '%s\n' "$out" | head -20 | sed 's/^/      /'
  echo
}
skip() { skips=$((skips+1)); printf '%s\n' "${DIM}SKIP  $1 — $2${OFF}"; }

# ── profile ───────────────────────────────────────────────────────────────────
FRAMEWORK="$(stack_get framework.id unknown)"
SRC="$(stack_get paths.source src)"
ROUTES="$(stack_get paths.routes)"
VIEWS="$(stack_get paths.views)"
STYLES="$(stack_get paths.styles)"
ENVFILE="$(stack_get paths.env)"
PROTECTED="$(stack_get paths.protected)"
ROUTE_GLOB="$(stack_get paths.routeEntryGlob)"
LANG="$(stack_get language ts)"
STYLING="$(stack_get bindings.styling)"
MOTION="$(stack_get bindings.motion)"
TEXTMOTION="$(stack_get bindings.textMotion)"
SCROLL="$(stack_get bindings.smoothScroll)"
IMAGEB="$(stack_get bindings.image native)"
LINKB="$(stack_get bindings.link native)"
PUBPREFIX="$(stack_get bindings.envPublicPrefix)"
EXTS="$(stack_get extensions.component)"

SCOPE=("$@"); [ "$#" -eq 0 ] && SCOPE=("$SRC")

# Which files under paths.routes are route entries. Frameworks where *any* file
# in the routes directory is a route need the broad pattern.
if [ -z "$ROUTE_GLOB" ]; then
  case "$FRAMEWORK" in
    astro)             ROUTE_GLOB="*.astro" ;;
    nuxt)              ROUTE_GLOB="*.vue" ;;
    sveltekit)         ROUTE_GLOB="+page.*" ;;
    nextjs|react-router|remix|tanstack-start|solid-start|qwik)
                       ROUTE_GLOB="page.* index.*" ;;
    *)                 ROUTE_GLOB="page.* +page.* index.astro index.vue" ;;
  esac
fi

# Extensions to scan. Defaults cover a JS/TS project of any framework.
[ -z "$EXTS" ] && EXTS=".tsx .ts .jsx .js .vue .svelte .astro"
INCLUDES=()
for e in $EXTS; do INCLUDES+=(--include="*${e}"); done
# always scan plain script files too — logic lives there in every stack
for e in .ts .tsx .js .jsx .mjs; do
  case " $EXTS " in *" $e "*) ;; *) INCLUDES+=(--include="*$e") ;; esac
done

echo "── profile ───────────────────────────────────────────────────"
if stack_is_adapted; then
  printf '  %s · source=%s · motion=%s · styling=%s\n' \
    "${FRAMEWORK}" "${SRC}" "${MOTION:-unset}" "${STYLING:-unset}"
else
  printf '%s\n' "${YEL}  stack.json is not adapted — running universal checks with defaults.${OFF}"
  printf '%s\n' "${DIM}  Run /adapt so the path, convention and binding checks apply to this project.${OFF}"
fi
echo

# ── helpers ───────────────────────────────────────────────────────────────────
# All in-scope source.
SRCG() { grep -rEn "${INCLUDES[@]}" "$1" "${SCOPE[@]}" 2>/dev/null; }
# App source only — excludes any vendored/protected engine.
APP() {
  local out; out="$(SRCG "$1")"
  for p in $PROTECTED; do out="$(printf '%s' "$out" | grep -v "${p%/**}" )"; done
  printf '%s' "$out"
}
CSS() { grep -rEn --include='*.css' --include='*.scss' --include='*.pcss' "$1" "${SCOPE[@]}" 2>/dev/null; }
exists() { [ -n "$1" ] && [ -e "$1" ]; }

echo "── Motion ────────────────────────────────────────────────────"

report FAIL "CSS keyframes are banned" \
  "All real motion is spring-based. Long enough to need keyframes = long enough to deserve a spring." \
  "$(SRCG '@keyframes'; CSS '@keyframes')"

# Any animation library that is not this project's configured binding is banned.
KNOWN="framer-motion|gsap|animejs|anime\.js|velocity-animate|popmotion|aos|wowjs|wow\.js|motion-v|@vueuse/motion|@motionone/[a-z-]+|locomotive-scroll|scrollmagic|motion/react|react-transition-group"
BANNED="$KNOWN"
for allowed in $MOTION $TEXTMOTION $SCROLL; do
  esc="$(printf '%s' "$allowed" | sed 's/[.[\*^$\/]/\\&/g')"
  BANNED="$(printf '%s' "$BANNED" | sed -E "s#(^|\|)${esc}(\||$)#\1\2#g; s#\|\|#|#g; s#^\|##; s#\|\$##")"
done
if [ -n "$BANNED" ]; then
  report FAIL "animation library that is not this project's binding" \
    "Motion goes through ${MOTION:-the configured binding} (+ ${TEXTMOTION:-text recipe}). Adding a second animation system is how a codebase ends up with three motion languages." \
    "$(SRCG "from ['\"](${BANNED})" ; SRCG "require\(['\"](${BANNED})")"
fi

if [ "$MOTION" = "@react-spring/web" ] || [ -z "$MOTION" ]; then
  report FAIL 'text motion mode="manual"' \
    "Use always / once / forward / progress — see obsidian/frontend/text-motion.md." \
    "$(SRCG 'mode=["'"'"']manual["'"'"']')"
fi

report FAIL "tight leading combined with clipped overflow" \
  "A clip box is the line-height box; leading must stay >= 1.1 or descenders get shaved." \
  "$(SRCG 'leading-none' | grep -E 'overflow')"

if [ "${STYLING#tailwind}" != "$STYLING" ]; then
  report FAIL "duration-fast / duration-normal used as a bare utility" \
    "Tailwind has no --duration-* namespace — the class compiles to nothing. Use duration-[var(--duration-fast)]." \
    "$(SRCG '\bduration-(fast|normal|slow)\b')"

  report WARN "CSS transition without token-backed timing" \
    "The narrow CSS-transition exception requires duration-[var(--duration-*)] and a token ease." \
    "$(APP 'transition-(colors|opacity|all|transform|shadow)' | grep -vE 'duration-\[var\(--duration-')"
fi

report WARN "raw CSS animation shorthand" \
  "If it is not a token-driven Tailwind utility, it is a keyframe animation by another name." \
  "$(CSS '^\s*animation:')"

echo "── Tokens ────────────────────────────────────────────────────"

report FAIL "hardcoded colour in a class or inline style" \
  "Add a --raw-* primitive + a semantic token in the style entry, then use the generated utility." \
  "$(APP '(class|className|style)=[^>]*#[0-9a-fA-F]{3,8}')"

report WARN "hex literal in source (outside the style entry)" \
  "Config values (theme colour, canvas/WebGL material colours) are acceptable; anything in markup must be a token." \
  "$(APP '#[0-9a-fA-F]{3,8}\b' | grep -vE '(class|className|style)=' | grep -vE '\s*(//|/\*|\*)')"

report WARN "arbitrary px/rem value in a class name" \
  "Prefer a spacing token; arbitrary values are for var() references and genuine one-offs." \
  "$(APP '(class|className)=[^>]*\[[0-9.]+(px|rem)\]')"

if exists "$STYLES" && [ "${STYLING#tailwind}" != "$STYLING" ]; then
  report FAIL "literal bound directly in @theme inline" \
    "Every entry must be --<namespace>-<role>: var(--<role>), or theming freezes at build time." \
    "$(awk '/@theme inline/,/^}/' "$STYLES" \
       | grep -nE '^\s*--[a-z-]+:\s*(#|[0-9]|cubic-bezier|calc)' \
       | grep -vE '(--leading-|--ease-|--text-|--spacing-|--radius-|--breakpoint-|--container-)')"

  report FAIL "literal in a Tier 2 semantic token" \
    "Only Tier 1 (--raw-*) may contain literals — see obsidian/frontend/design-system.md." \
    "$(awk '/TIER 2/,/THEME BINDINGS/' "$STYLES" \
       | grep -nE '^\s*--[a-z][a-z0-9-]*:\s*(#[0-9a-fA-F]|[0-9]+(px|ms|rem))')"
elif [ -z "$STYLES" ]; then
  skip "token-tier checks" "paths.styles is unset — run /adapt"
fi

echo "── Architecture ──────────────────────────────────────────────"

if stack_true conventions.routesDelegateToViews && exists "$ROUTES" && [ -n "$VIEWS" ]; then
  vseg="$(basename "$VIEWS")"
  route_violations=""
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    case "$(basename "$p")" in
      layout.*|+layout.*|error.*|+error.*|loading.*|not-found.*|template.*|default.*) continue ;;
    esac
    bad="$(grep -nE "^\s*import .*from ['\"]" "$p" 2>/dev/null \
      | grep -vE "['\"][^'\"]*/${vseg}/" \
      | grep -vE "['\"](@|~|\\\$lib|\\.{1,2})?/?${vseg}[/'\"]" \
      | grep -vE "from ['\"](next|react|react-dom|vue|svelte|@sveltejs|astro|solid-js|nuxt|@nuxt|@angular|qwik)(/|['\"])" || true)"
    [ -n "$bad" ] && route_violations="${route_violations}${p}: ${bad}"$'\n'
  done < <(
    findargs=()
    for pat in $ROUTE_GLOB; do findargs+=(-o -name "$pat"); done
    find "$ROUTES" -type f \( "${findargs[@]:1}" \) 2>/dev/null \
      | grep -vE '/(components|layouts|_[^/]*)/'
  )
  report FAIL "route file imports something other than a view" \
    "Route files delegate only — all UI logic lives in ${VIEWS}/." "$route_violations"
else
  skip "route→view delegation" "convention off, or paths.routes/paths.views unset"
fi

if stack_true capabilities.serverComponents && [ -n "$VIEWS" ]; then
  report WARN '"use client" on a layout, page or view' \
    "Server-first — push the boundary down to a leaf component." \
    "$(grep -rln '"use client"' "$ROUTES"/layout.* "$ROUTES"/page.* "$VIEWS" 2>/dev/null)"
fi

if [ "$LANG" = "ts" ]; then
  report FAIL "explicit any" \
    "Type it. If the shape is genuinely unknown use unknown + a schema parse." \
    "$(APP ':\s*any\b|<any>|as any|any\[\]')"
fi

if [ -n "$PUBPREFIX" ]; then
  envexcl="$PUBPREFIX|NODE_ENV|MODE|DEV|PROD|SSR|BASE_URL"
  out="$(APP 'process\.env\.|import\.meta\.env\.' | grep -vE "$envexcl")"
  [ -n "$ENVFILE" ] && out="$(printf '%s' "$out" | grep -v "$ENVFILE")"
  report FAIL "env var read outside the validated env module" \
    "Secrets are server-only and read through ${ENVFILE:-the env module}; anything without the ${PUBPREFIX} prefix must never reach the browser." \
    "$out"
else
  skip "env access check" "bindings.envPublicPrefix is unset — run /adapt"
fi

echo "── Markup & a11y ─────────────────────────────────────────────"

if [ "$IMAGEB" != "native" ] && [ -n "$IMAGEB" ]; then
  report WARN "raw <img> instead of ${IMAGEB}" \
    "The framework image component with explicit dimensions prevents CLS." "$(APP '<img\s')"
fi

report WARN "image without alt" \
  "Every image needs alt; decorative images take alt=\"\"." \
  "$(APP '<(Image|img|NuxtImg|enhanced:img)\s[^>]*/?>' | grep -v 'alt=')"

if [ "$LINKB" != "native" ] && [ -n "$LINKB" ]; then
  report WARN "raw <a> for an internal link" \
    "Use the ${LINKB} component so client-side navigation and prefetching work." "$(APP '<a\s+href=["'"'"']/')"
fi

report WARN "click handler on a non-interactive element" \
  "Use a real <button>." "$(APP '<(div|span)[^>]*(onClick|@click|on:click)=')"

if [ -n "$VIEWS" ] && [ -d "$VIEWS" ]; then
  report WARN "more than one <h1> in a view" \
    "Exactly one <h1> per page; never skip heading levels." \
    "$(grep -rc '<h1' "$VIEWS" 2>/dev/null | awk -F: '$2>1')"
fi

report WARN 'animation component rendering as a plain div' \
  "Pass the semantically correct element — section, h2, p, li …" \
  "$(APP '(tag|as|element)=["'"'"']div["'"'"']')"

echo "── Hygiene ───────────────────────────────────────────────────"

report WARN "console.log in source" "Remove before committing." "$(APP 'console\.(log|debug)')"
report WARN "TODO / FIXME marker" "Resolve, or move it to an issue." "$(APP '(TODO|FIXME)')"

if [ -n "$PROTECTED" ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    dirs=""; for p in $PROTECTED; do dirs="$dirs ${p%/**}"; done
    # shellcheck disable=SC2086
    report FAIL "protected path modified" \
      "paths.protected in stack.json is a vendored zone — changes there need explicit sign-off." \
      "$(git diff --name-only HEAD -- $dirs 2>/dev/null)"
  else
    skip "protected-path check" "not a git repository"
  fi
fi

echo "──────────────────────────────────────────────────────────────"
LINT="$(stack_get commands.lint)"; BUILD="$(stack_get commands.build)"
also="Also required: ${LINT:-the lint command}, ${BUILD:-the build command} (commands.* in stack.json), and the judgement checks in the qa-verify skill."
if [ "$fails" -gt 0 ]; then
  printf '%s\n' "${RED}${fails} FAIL${OFF} / ${YEL}${warns} WARN${OFF} / ${DIM}${skips} SKIP${OFF} — every FAIL must be fixed."
  echo "$also"; exit 1
fi
printf '%s\n' "${GRN}0 FAIL${OFF} / ${YEL}${warns} WARN${OFF} / ${DIM}${skips} SKIP${OFF} — mechanical rules pass."
echo "$also"; exit 0
