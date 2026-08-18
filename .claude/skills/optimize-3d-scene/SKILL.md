---
name: optimize-3d-scene
description: Optimise a three.js **or raw WebGL** scene in a project for mobile and low-end devices — device tiering, prewarm-everything-at-load so nothing compiles mid-scroll, in-view-only render loops, DPR and particle/bloom budgets, GPU-side scroll transforms, compressed textures, and stripping the scene from the bundle for bots. Use when the user says "optimise the 3D", "the scene lags on mobile", "micro freezes / jank on scroll", "make the scene mobile-friendly", "reduce the WebGL cost", or before shipping any project that carries a WebGL scene.
---

# Optimise a 3D scene

Any project carrying a three.js scene pays the same tax: a phone renders the
same fragments as a workstation, the first frame after a shader appears compiles
mid-scroll, and the render loop keeps running behind three sections of copy
nobody is looking at. This skill fixes those in a fixed order — cheapest and
highest-impact first.

Every step applies to a **raw WebGL** scene as much as a three.js one; only §0's
measurement primitives differ (three.js hands you `renderer.info`, a raw scene
you instrument yourself — which you must do *before* you can begin).

None of it is framework-specific: a scene is a canvas, a render loop and a GPU
budget in any stack. Where the fix does touch the framework (code-splitting the
scene chunk, skipping it for bots, mounting it as an island), resolve the
mechanism from `.claude/stack.json` rather than assuming.

**Do not invent new shapes — port the reference implementations.** Full,
working code for every pattern below is in `references/patterns.md`:

| pattern | section in `references/patterns.md` |
|---|---|
| device tiering, clamped DPR, frame budget | device tiering |
| one shared rAF for the whole page | ticker |
| in-view + hidden-tab render gate | visibility gating |
| visibility-gated loop, plain (non-framework) | vanilla scene loop |
| scroll lerp on touch, snap on jumps | scroll smoothing |
| per-tier particle counts | particles |
| canvas sizing that survives the iOS URL bar | canvas sizing |
| bot detection | bots |
| composer that skips a pass contributing nothing | post-processing |

The unoptimised shape to recognise: a single large vanilla file using raw
`devicePixelRatio`, an unconditional rAF, no device tiering, mouse tracking
always on, and a debug GUI shipped to production. If the scene you are handed
looks like that, this list is the order to fix it in.

## 0. Audit before you touch anything

Never optimise blind. Establish the baseline:

```sh
# what's actually in the scene
grep -rn "setPixelRatio\|requestAnimationFrame\|new THREE\..*Light\|UnrealBloom\|Points\|InstancedMesh" src/ --include=*.ts --include=*.tsx --include=*.js
```

Then in the running page's console:

```js
renderer.info.render      // { calls, triangles, points } — per frame
renderer.info.programs.length   // shader programs; each one is a compile stall if it appears late
renderer.info.memory      // { geometries, textures }
```

**Raw WebGL (no three.js).** `renderer.info` only exists on
`THREE.WebGLRenderer`. A hand-written scene has no equivalent — hook the context
before app code runs and count it yourself, or you cannot start:

```js
// page.evaluateOnNewDocument — counts passes, vertices, and *when* programs link
const gc = HTMLCanvasElement.prototype.getContext;
HTMLCanvasElement.prototype.getContext = function (kind, attrs) {
  const ctx = gc.call(this, kind, attrs);
  if (ctx && kind === "webgl") {
    window.__gl = ctx;
    window.__p = { draws: 0, verts: 0, frames: 0, links: [], attrs };
    const draw = ctx.drawArrays.bind(ctx);
    ctx.drawArrays = (m, f, c) => { window.__p.draws++; window.__p.verts += c; return draw(m, f, c); };
    const clear = ctx.clear.bind(ctx);          // one clear = one frame
    ctx.clear = (m) => { window.__p.frames++; return clear(m); };
    const link = ctx.linkProgram.bind(ctx);     // §3/§14: these must all precede the loader handoff
    ctx.linkProgram = (p) => { window.__p.links.push(Math.round(performance.now())); return link(p); };
  }
  return ctx;
};
```

`draws`/`verts` replace `info.render`, `links.length` replaces
`programs.length` (and `links` timestamps are what §3 is actually measured
against), `gl.drawingBufferWidth/Height` is the §6 check, and the captured
`attrs` is the §7 renderer-flags check. Full harness in `references/patterns.md`.

### The measurement environment (get this wrong and every number below is a lie)

- **Measure a production build, never the dev server.** Dev invalidates §1 (the
  bundler serves chunks eagerly, so the bot path looks broken when it isn't) and
  §4/§5 (a dev-mode double-mount doubles listener counts and halves the apparent
  frame rate). Run `commands.build` then `commands.start` from `stack.json` — and
  **kill the old server before rebuilding**, or it holds the port and serves a stale manifest,
  and you spend an hour debugging 404s and 500s that aren't yours.
- **Use `waitUntil: "load"` plus a fixed settle.** `networkidle0` never fires
  against `next start`.
- **SwiftShader is not a GPU.** Absolute fps out of headless Chrome is
  meaningless (a desktop measured 14 fps). Only *counted* quantities transfer:
  draw calls, vertices, drawing-buffer pixels, listener counts, program-link
  timestamps, main-thread block duration.
- To observe a §5 frame **cap** at all, the GPU has to stop being the limiter:
  shrink the viewport to ~320×240 and re-measure. If rAF fires 120×/s and the
  scene draws 26×/s, the cap is working.

Write the before/after numbers down. A change you cannot measure is a change you
cannot defend, and every item below costs something in look.

## 1. Never ship the scene to a robot

A crawler or Lighthouse run gets **no scene at all** — not a hidden canvas, not
a lazily-idle module. The three.js bundle must never be fetched, parsed or
evaluated, because script evaluation time is what the audit is measuring.

- Server-side, read the UA (the bot-detection helper in `references/patterns.md`) and render
  a static poster instead of the scene component.
- The scene mounts through the stack's own lazy/client-only boundary (a dynamic
  import with SSR off, a `client:visible` island, a lazy route chunk) so `three`
  lands in its own chunk and only that chunk is skipped.
- Plain-HTML projects: `import()` the scene module behind the same UA check.

This applies to desktop and mobile equally.

**What the poster is actually for.** Not layout stability — an
`absolute inset-0` background canvas shifts nothing either way, so don't justify
it that way. It exists for (a) crawler and social-preview screenshots, which
otherwise capture an empty box, and (b) the no-WebGL / context-lost fallback.
Two details:

- If the camera fits to the tighter axis (per-tier framing), one landscape
  poster re-crops the subject on portrait — the head goes off-frame. Export
  **two crops** and pick with a `<picture>` media query.
- `isBot()` reads `headers()`, which opts the whole route out of static
  prerendering (`○` → `ƒ` in the build output). That is a real trade-off, not a
  free win: state it. If the route must stay static, do the branch in
  middleware (rewrite bots to a `/poster` route) instead.

## 2. Tier the device once, at construction

One module decides what "mobile" means. Everything — DPR, particle counts,
bloom, frame budget, whether the pointer is even listened to — reads from it, so
the values can never drift apart. Read once at construction: a device does not
change tier mid-session, and rebuilding buffers on resize costs more than the
mismatch is worth.

`mobile` = `innerWidth < 768 || matchMedia("(hover: none) and (pointer: coarse)")`.
The coarse-pointer clause is what catches tablets and large phones.

Also expose, from the same module:
- `prefersReducedMotion()` — an accessibility promise, honoured on every tier.
- `isEnergySaver()` — `navigator.connection.saveData` or `deviceMemory <= 2`;
  the nearest web-exposed proxy for iOS Low Power Mode, which has no API.
- `sceneShouldFreeze()` — reduced motion on any device, or a mobile flagged
  energy-constrained. Play the entrance, then stop drawing on a settled frame.
  WebGL keeps the last frame on the canvas, so a frozen scene costs zero.

## 3. Precompute and prewarm *everything* during the loader

This is the rule that kills micro-freezes. After the loader hands off, the frame
loop must allocate nothing, compile nothing and upload nothing. A stall on
scroll — or a frozen loader — is always one of five things. The first four are
GPU-shaped, which is why the fifth is the one that gets missed:

1. **Shader compile / link.** `renderer.compile(scene, camera)` (or
   `await renderer.compileAsync(scene, camera)`, which does not block the main
   thread) while the loader is still on screen. Every material must be in the
   scene graph at that moment, including ones that are `visible = false`.
2. **Program variants.** Three compiles a *new* program when a define changes —
   `USE_INSTANCING`, `transparent`, a different light count, `fog`. Never flip a
   define, a light count, `material.transparent` or `blending` at runtime. Set
   the final variant at construction and drive change through uniforms only.
3. **Texture upload.** The first `render` that samples a texture uploads it,
   which for a 2K PNG is a visible hitch. `renderer.initTexture(tex)` for every
   texture during the loader.
4. **Render-target and post-pass warmup.** Each `EffectComposer` /
   `WebGLRenderTarget` allocates and compiles on its first use. Render one
   throwaway frame through the *complete* chain before handoff.
5. **CPU decode / parse.** Geometry decode, normal estimation, PCA fits, buffer
   building — pure work, no GPU involved, and the one most often missed because
   the other four are all shader-shaped. On a throttled phone it blocks for
   *seconds* (a measured 3.9 s for 50k plane fits), and it lands while the
   loader is animating, so the counter freezes and the page ignores input.
   Chunking across frames keeps the loader alive; a **Worker** removes it from
   the main thread entirely and is the better answer whenever the work is pure.
   Transfer the buffers (`postMessage(msg, [buf])`) in *both* directions so
   nothing is copied, and keep an inline fallback for environments without
   Workers.

On top of that, precompute CPU-side:

- All `BufferGeometry` attributes, all particle buffers, all noise/glyph
  textures — built during the loader, never on a scroll boundary.
- If a build loop is long enough to block (say > 8 ms), chunk it across frames
  and feed the loader percentage from it. The loader is *for* this.
- Drive the whole timeline from a single scroll-progress uniform whose value
  range is fully covered during warmup, so no branch in the shader is reached
  for the first time mid-scroll.

Then: **render one frame at each keyframe of the scroll timeline during warmup**
(progress 0, 0.25, 0.5, 0.75, 1) into a 1×1 scratch target. Any lazily-created
program, any conditional branch, any texture bound only in the finale gets
touched while the loader still owns the screen.

The vanilla scene loop in `references/patterns.md` does step 1 after the GLB
resolves — copy the shape, extend it to all five.

**§1 and §3 pull against each other — check the gap, every time.**
Code-splitting the scene (§1) means it cannot mount, and therefore cannot
compile or allocate, until after hydration. On a slow connection that lands
*after* the loader has handed off, which is exactly the stall §3 exists to
prevent — measured on Regular 3G + 4× CPU, programs linked at 5.0 s against a
curtain that lifted at 2.36 s. Neither section warns you on its own. Measure it
(§0's `linkProgram` timestamps vs the handoff time) and close it deliberately:
`<link rel="preload">` the scene's data from the HTML so it is in flight during
parse, and if the gap survives that, gate the loader on **scene-ready** rather
than on a fixed duration. A time-based preloader is a promise about the network
you cannot keep.

> [!warning] The `as="fetch"` preload credentials trap
> An `as="fetch"` preload is only reused when its credentials mode matches the
> `fetch()` **exactly**. `crossorigin="anonymous"` + `credentials: "omit"` does
> *not* match, and neither does no-attribute + default — both silently download
> the asset a second time, with nothing but a console warning ("…not used
> because the request credentials mode does not match"), and the page looks
> fine either way. The pair that dedupes is `crossorigin="use-credentials"` +
> `credentials: "include"`. Verify by counting **network** requests
> (`page.on("request")`), not `fetch` calls.

## 4. Render only when visible — the loop is on-demand

The single largest saving in a scroll site. Three WebGL scenes each running
their own forever-rAF is a documented cause of whole-page scroll jank.

Gate on all three:

- `document.hidden` — a background tab paints nothing.
- The section is on (or near) screen — `IntersectionObserver` with a
  `rootMargin` of about one viewport so it is already warm when it arrives, or
  a scroll-range test like `isSceneVisible()`.
- The canvas is actually visible (not faded to 0 by a wrapper).

Prewarm (§3) is the deliberate exception: it runs once, before any of this.

Subscribe to **one app-wide rAF ticker** rather than starting a loop per scene
(the ticker in `references/patterns.md`, and hard rule 1's shared loop). It reference-counts, so an idle page
costs nothing, and each subscriber is throttled independently.

## 5. Budget the frame rate per tier

`mobile: 1000/30`, `tablet: 1000/45`, `desktop: 0` (every tick). These scenes
are fill-bound, not motion-bound — the noise fields evolve slowly enough that
halving the frame rate on a phone is genuinely hard to see, and it is the single
biggest win available there. Throttle per subscriber so capping the scene does
not slow the springs and DOM animation sharing the loop.

**`1000/30` does not produce 30 fps.** The canonical ticker skips while
`time - last <= framerate`, so with rAF free-running at ~120 Hz the first tick
that clears 33.3 ms lands at ~41.7 ms — 26 fps measured, not 30. It errs cheap,
so it is harmless and the budget still works; just don't quote 30 as measured
truth. If you want the stated number to match reality, fix it in one place:
budget `1000/30 - ε`, or change the ticker's comparison to `<`. (And see §0 —
you can only observe the cap once the GPU isn't the limiter.)

## 6. Pixel ratio: clamp hard, and clamp the composer too

```
mobile   → min(dpr, 0.85)     // 0.75–1.0; below 1.0 is fine for soft sprites
tablet   → min(max(dpr, 0.75), 1.25)
desktop  → min(max(dpr, 0.75), 1.5)
```

A 3× phone renders **9×** the fragments of a 1× screen, for no perceptible gain
on a point cloud or a soft-edged shader. Go to 1.0 (not below) when the scene
has hard-edged geometry — warp streaks, thin lines, crisp text in the shader —
because those alias visibly.

**`EffectComposer` owns its own render targets.** If you clamp the renderer and
leave the composer at raw `devicePixelRatio`, you throw the entire saving away
on the post pass. Set both from the same function.

## 7. Cut fill, not detail — the phone dies on fill rate

In order of what actually costs:

- **Particle counts, per tier.** Roughly a third of desktop on mobile
  (`vortex.ts`: 460×420 desktop → 170×190 mobile). Cut the *sparse* end of the
  distribution first — the rim of a disc, the outer shell of a cloud — where it
  shows least. Never cut uniformly.

  **On a pre-baked point buffer that advice has no lever** — your only knob is
  truncating `drawArrays`, and whether that is safe depends on the buffer's
  point ordering, which is documented nowhere. **Check it before you cut:**
  bucket the positions into deciles and compare mean coordinates. If they drift
  monotonically, the points are spatially ordered and drawing the first N
  deletes a *region*, not a sample (one measured file was sorted left→right —
  truncating would have removed half the head). In that case the only real
  reduction is re-sampling the asset offline into a `points-lite.bin`, not a
  smaller `drawArrays`. Say that rather than shipping a hole. Script in
  `references/patterns.md`.
- **Bloom.** Halve strength and radius on mobile, and **skip the pass entirely
  when it contributes nothing**: `bloomPass.enabled = bloomPass.strength > 0.001`
  saves a full-screen chain per frame. Scale bloom by viewport height too — a
  look tuned on a 1440p screen blows out on a short window.
- **Additive/transparent overdraw.** Every additive halo is pure fill. Prefer
  fewer, larger sprites over many small ones; cap `gl_PointSize`; keep
  `depthWrite: false` on transparents so you at least skip the depth write.
- **Post-processing chains that render nothing.** Audit them. The classic
  failure is three chained composers where two render empty layers and the final
  pass samples stale targets. That was both a flicker *and* two
  wasted full-screen passes per frame. Read the note in
  the post-processing section of `references/patterns.md`; this dead chain is
  common in scenes that grew a pass at a time.
- **Renderer flags.** `antialias: false` on mobile (the DPR clamp and soft edges
  hide it; MSAA on a phone is expensive), `alpha: false` when the canvas is
  opaque, `stencil: false`, `depth: false` when nothing depth-tests,
  `powerPreference: "high-performance"` on desktop only.
- **Shadow maps off on mobile.** `VSMShadowMap` is the most expensive type there is. If the scene needs grounding, bake it into a texture.

## 8. Lights: as few as the look survives

Every real-time light multiplies the fragment cost of every lit material, and
changing the light *count* recompiles every program. Target:

- **One** directional key + an environment map (IBL). A PMREM'd
  `RoomEnvironment` (see `references/patterns.md`) replaces three or
  four fills and looks better than any of them.
- Bake rim/fill into the material — a fresnel term in `onBeforeCompile` costs a
  few ALU ops and reads as a light. Do this *instead of* the fills, not on top
  of them — the common mistake is shipping both.
- No point/spot lights on mobile unless the scene is literally about them.
- Never add or remove a light at runtime.

## 9. Do transforms on the GPU, not the CPU — especially scroll

Any per-object transform that scroll drives should be a **uniform feeding the
vertex shader**, not a JS loop mutating `position`/`rotation` per frame.

- Positions computed in the vertex shader from `aOffset`/`aRandom` attributes +
  a `uProgress` uniform. Scroll then costs one uniform write per frame, and the
  work scales on the GPU instead of the main thread. The particles section of `references/patterns.md`
  shows the shape (`aRandomPosition`, `aDelay`, `uProgress`).
- Set `frustumCulled = false` on anything whose positions the shader computes,
  or Three culls against a stale bounding sphere.
- Where a whole group moves, move the `Group` (one matrix), never the children.
- Instancing / merged geometry for anything repeated: one draw call, per-instance
  data in attributes.
- CPU-side per-frame `Vector3`/`Matrix4` allocation is a GC stall. Reuse
  module-scope scratch objects (a module-scope `_scratchVec` reused everywhere,
  never a `new Vector3()` inside the loop).
- Read `window.scrollY` **once per frame inside the ticker**. Never in a scroll
  handler that also writes styles — that is a forced layout every event.

## 10. Smooth the scroll progress on touch

On mobile the OS owns momentum scrolling, so `window.scrollY` arrives in
discrete steps and every derived value jitters — worst on a fixed, scroll-driven
scene, and compounded when the scene runs at 30 fps.

Low-pass the scroll position once, upstream, so every downstream value inherits
the easing:

```js
smoothed += (raw - smoothed) * k;
```

- **Retention 0.75 ⇒ `k = 0.25`.** That is the same thing said two ways, and a tuned `SMOOTH_LERP` of ~0.22 is a good
  starting point — keep mobile in the 0.2–0.3 band. Lower than that reads as disconnected from the thumb once the 30 fps cap
  is stacked on top.
- Desktop still wants a gentle `k ≈ 0.3` — a smooth-scroll library eases the
  wheel, but the scene
  samples `scrollY` raw and steppy wheel input shows up as camera jitter.
- **Snap, don't crawl**, on a page jump: if `|raw - smoothed| > 1.5vh`, assign
  directly. Otherwise an anchor link takes two seconds to arrive.
- Make it frame-rate independent when the tier caps fps:
  `k = 1 - Math.pow(1 - kBase, dt * 60)`.

## 11. Kill cursor interactivity on mobile

Unless the user explicitly asks for it. On a touch device pointer effects are
either dead weight or actively wrong:

- Don't attach the `mousemove` listener at all on the mobile tier — not
  "attach and ignore".
- Gate every pointer-driven effect on `hasPointer()` (has the pointer *ever*
  moved). Ungated, an unmoved cursor resolves to NDC (0,0) — dead centre — so a
  repulsion field punches a hole through the middle of the scene on every touch
  device and every untouched page. The particles section of `references/patterns.md`
  shows the gate plus the ease-in.
- Drop the uniform and the branch from the mobile shader variant where it is
  more than a couple of ops — but set it at construction (§3.2), never toggle.
- If the user does want it on touch: drive it from `touchmove`, and keep the
  same lerp so it doesn't snap.

## 12. Compress the assets

- **Geometry**: Draco. Keep the decoder local (served from the project's static
  root), not on a CDN — a third-party fetch on the critical path costs a
  round-trip before anything can decode.
- **Textures**: KTX2 / Basis (`KTX2Loader`), not PNG/JPEG. This is the one that
  matters for GPU pressure: a compressed texture stays compressed *in VRAM*, so
  it costs a fraction of the memory and bandwidth of an equivalent PNG, which is
  decoded to raw RGBA on upload. On a phone that is the difference between a
  smooth pan and a texture-thrash stutter.

  ```sh
  npx @gltf-transform/cli optimize in.glb out.glb --texture-compress ktx2
  ```
- Cap texture size per tier (2048 desktop / 1024 mobile), `anisotropy = 1` on
  mobile, `generateMipmaps` on for anything minified, `LinearFilter` for
  procedurally-drawn canvas textures.
- Resize the model itself: decimate before you optimise the renderer.

## 13. The details that cause "flicker on iOS"

- **No `resize` listener on touch.** iOS Safari fires `resize` every time the URL
  bar collapses during scroll; handling it rebuilds the WebGL framebuffer
  mid-scroll and reads as a whole-scene flash. Size the canvas once on load and
  accept that rotation won't reflow it. Desktop keeps an rAF-coalesced resize.
  (See the canvas-sizing section of `references/patterns.md`.)
- Size the **canvas** against the largest viewport — `h-lvh w-lvw`, not `100vh`
  — so a collapsing URL bar never re-allocates the framebuffer. **`lvh` is for
  the canvas, not the layout.** Applying it to the content is a different bug
  (the bottom of the layout hides behind the URL bar), and it is the naive
  reading of this line: canvas `lvh`, content `dvh`. The extra canvas bleed is
  clipped and invisible.
- Promote the canvas wrapper to its own compositor layer —
  `transform-gpu backface-hidden will-change-transform`. Without it a
  neighbouring fixed element repainting during scroll invalidates the WebGL
  composite on WebKit and the whole scene flickers.
- All scroll/pointer listeners `{ passive: true }`.
- Clamp `dt`: `Math.min(0.05, t - last)`. A tab-switch return otherwise hands the
  scene a two-second delta and everything teleports.
- Dispose on unmount: geometries, materials, textures, render targets,
  `renderer.dispose()`, and remove every listener.

## 14. Verify, then write it down

Re-measure the §0 numbers and report the delta honestly:

- `renderer.info.render.calls` and `.programs.length` before vs after (raw
  WebGL: `window.__p.draws` and `window.__p.links.length`); the program count
  must be **stable after the loader** — if it grows during scroll, §3 is
  incomplete and the micro-freezes are still there. On a raw scene the
  `links` *timestamps* say more than the count: every one must precede the
  loader handoff, or §1 has pushed compilation past it (see §3).
- Re-measure on the same footing as the baseline — production build, fresh
  server, counted quantities only (§0). A dev-mode "after" number proves
  nothing.
- Frame timings on a throttled CPU (DevTools 4×/6× slowdown) across a full
  scroll, looking for long tasks.
- Lighthouse mobile before/after — with §1 in place the bot path should show no
  three.js in the JS bundle at all.
- Look at it on a real phone. Fill-rate wins are invisible in a profiler and
  obvious in the hand.

Then, in the same turn, update the project's Obsidian vault (in this repo:
`obsidian/meta/…` — check the casing in the vault you are actually in):

- behaviour or measurable performance change → `changelog.md`, with the
  before/after numbers;
- a trade-off you chose (a look sacrificed for a tier, a pass dropped) → an ADR
  in `decisions-log.md`, **with the reasoning**;
- something you could not measure → note it in the changelog entry (this vault
  has no `open-questions.md`);
- a new module (`device.ts`, scene util, hook) → the matching catalog note;
  `three` and any loaders → `architecture/tech-stack.md`.

## What not to do

- Don't drop the scene on mobile wholesale. The scene is the product; tier it.
- Don't tune by feel on a desktop. Every number here was measured on a phone.
- Don't hand-roll another `device.ts`. Port the one in `references/patterns.md`.
- Don't ship `lil-gui`. Hiding it does not help — it is still downloaded, parsed
  and evaluated. Tree-shake it behind a dev flag.
- Don't leave `console.log`, `Stats`, or an `OrbitControls` you disabled in the
  production path.
