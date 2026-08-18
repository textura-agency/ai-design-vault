#!/usr/bin/env bash
# Gathers the evidence /adapt needs to fill in .claude/stack.json.
# It reports facts; it does not decide. The stack-adapt skill reads this output
# and writes the profile.
#
# Usage: .claude/scripts/detect-stack.sh

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

hdr() { printf '\n== %s\n' "$1"; }
have() { [ -e "$1" ] && printf '  %s\n' "$1"; }

hdr "manifest"
if [ -f package.json ]; then
  if command -v node >/dev/null 2>&1; then
    node -e '
      const p=require("./package.json");
      const pick=o=>Object.entries(o||{}).map(([k,v])=>`  ${k}@${v}`).sort().join("\n");
      console.log("  name: "+(p.name||"(unnamed)")+"  packageManager: "+(p.packageManager||"(unset)")+"  type: "+(p.type||"commonjs"));
      console.log("\n  -- scripts --"); console.log(Object.entries(p.scripts||{}).map(([k,v])=>`  ${k}: ${v}`).join("\n")||"  (none)");
      console.log("\n  -- dependencies --"); console.log(pick(p.dependencies)||"  (none)");
      console.log("\n  -- devDependencies --"); console.log(pick(p.devDependencies)||"  (none)");
    ' 2>/dev/null || cat package.json
  else
    cat package.json
  fi
else
  echo "  no package.json — this may be a non-JS stack (Hugo, Eleventy via other means, plain HTML). Check below."
fi

hdr "lockfiles (→ package manager)"
for f in package-lock.json yarn.lock pnpm-lock.yaml bun.lock bun.lockb deno.lock; do have "$f"; done

hdr "framework & build config"
for f in \
  next.config.js next.config.mjs next.config.ts \
  astro.config.mjs astro.config.ts \
  nuxt.config.ts nuxt.config.js \
  svelte.config.js vite.config.js vite.config.ts vite.config.mjs \
  remix.config.js react-router.config.ts \
  app.config.ts angular.json project.json \
  qwik.config.ts gatsby-config.js \
  eleventy.config.js .eleventy.js hugo.toml config.toml \
  tailwind.config.js tailwind.config.ts postcss.config.js postcss.config.mjs \
  tsconfig.json jsconfig.json deno.json \
  vercel.json vercel.ts netlify.toml wrangler.toml \
  ; do have "$f"; done

hdr "top-level layout"
ls -d */ 2>/dev/null | sed 's/^/  /' | head -30

hdr "source layout (2 levels)"
for root in src app source lib routes pages components islands; do
  [ -d "$root" ] && find "$root" -maxdepth 2 -type d -not -path '*/node_modules/*' 2>/dev/null | sed 's/^/  /' | head -40
done

hdr "route-ish entry files (first 25)"
find . -maxdepth 5 \
  \( -name node_modules -o -name .git -o -name dist -o -name build -o -name .next -o -name .svelte-kit -o -name .nuxt -o -name .output \) -prune -o \
  \( -name 'page.tsx' -o -name 'page.jsx' -o -name '+page.svelte' -o -name 'index.astro' -o -name 'route.ts' -o -name '+server.ts' -o -name 'App.vue' -o -name 'app.vue' -o -name 'index.html' \) -print 2>/dev/null | sed 's/^/  /' | head -25

hdr "style entry candidates"
find . -maxdepth 4 \
  \( -name node_modules -o -name .git -o -name dist -o -name build \) -prune -o \
  \( -name 'globals.css' -o -name 'global.css' -o -name 'app.css' -o -name 'index.css' -o -name 'main.css' -o -name 'style.css' -o -name 'tailwind.css' \) -print 2>/dev/null | sed 's/^/  /' | head -15

hdr "existing motion / scroll packages in source"
grep -rhoE "from ['\"](@react-spring/[a-z]+|spring-text-engine|motion-v|@vueuse/motion|motion|framer-motion|gsap|animejs|@motionone/[a-z]+|lenis|locomotive-scroll|three|@react-three/[a-z]+|ogl|@theatre/[a-z]+)" \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.vue' --include='*.svelte' --include='*.astro' \
  . 2>/dev/null | sed "s/from ['\"]//" | sort -u | sed 's/^/  /' | head -20

hdr "env"
for f in .env.example .env.sample .env.local .env; do have "$f"; done
grep -rhoE '\b(NEXT_PUBLIC_|VITE_|PUBLIC_|NUXT_PUBLIC_|REACT_APP_|GATSBY_|ASTRO_)[A-Z0-9_]+' \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.vue' --include='*.svelte' --include='*.astro' --include='.env*' \
  . 2>/dev/null | sort -u | sed 's/^/  /' | head -15

hdr "git"
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "  repo: yes   branch: $(git branch --show-current 2>/dev/null)"
  echo "  tracked files: $(git ls-files 2>/dev/null | wc -l | tr -d ' ')"
else
  echo "  repo: no (verify.sh cannot check protected paths without git)"
fi

printf '\n== done — hand this to the stack-adapt skill\n'
