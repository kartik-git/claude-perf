---
name: perf-mobile
description: Mobile performance audit — throttled CPU/network simulation, touch event passiveness, viewport correctness, input latency, and battery-aware optimizations.
type: skill
parent: perf
---

# `perf-mobile` — Mobile Performance

## Scope

Most users are on mobile. Mobile devices are slower (CPU and network), have smaller
caches, run on radios that wake up expensively, and are running 8 other apps in the
background. This sub-skill audits everything specifically through that lens.

## When to invoke

- `/perf mobile <url>` — explicit
- During `/perf audit` — fan-out via `perf-agent-mobile`
- Mentions of: "mobile", "throttling", "Slow 4G", "Fast 3G", "scroll jank",
  "passive touch", "viewport", "responsive"

## Default test profile

Match Lighthouse's mobile profile:
- **CPU:** 4× slowdown
- **Network:** Slow 4G (1.6 Mbps down, 750 Kbps up, 150 ms RTT)
- **Viewport:** 360 × 640, DPR 2.625 (Moto G4 emulation)
- **User agent:** mobile Chrome

Optional secondary profiles:
- **Fast 3G** (1.6 Mbps / 750 Kbps / 562 ms RTT) for emerging markets
- **Slow 3G** (400 Kbps / 400 Kbps / 2000 ms RTT) for the worst case

## Analysis checklist

### Viewport
1. **`<meta name="viewport" content="width=device-width, initial-scale=1">`** is
   non-negotiable.
2. Avoid `user-scalable=no` and `maximum-scale=1` — accessibility regression for low
   vision users.
3. **`viewport-fit=cover`** if the design uses notched-device safe areas.

### Touch events
1. **Passive listeners** — `addEventListener('touchstart', fn, { passive: true })`.
   Without `passive`, the browser can't start scrolling until the handler returns.
2. **`touch-action`** CSS — `touch-action: manipulation` removes the 300 ms tap delay
   on legacy browsers (mostly historical now, but still recommend).
3. **No `wheel` listener attached to `document`** without `passive`.

### CPU-bound work
1. **Long tasks** — anything > 50 ms blocks input on mobile. Aim for **no task >
   200 ms** even with 4× throttling.
2. **Hydration cost** is amplified on mobile — a 200 ms hydration on M2 MacBook is
   800–1200 ms on Moto G4. Flag.
3. **Animation cost** — only `transform` and `opacity` are GPU-composited. Animating
   layout properties (`top`, `left`, `width`) on mobile is jank-on-arrival.

### Network-bound work
1. **First-load payload** — aim for ≤ 170 KB compressed on mobile (Slow 4G can deliver
   that in ~1 s).
2. **Image weight per page** — aim for ≤ 500 KB on mobile.
3. **Preload only critical** — preloading too aggressively eats limited radio budget.

### Battery / motion
1. **`prefers-reduced-motion`** — respect it; disable big animations.
2. **`prefers-reduced-data`** — if set, skip auto-playing videos and high-DPR images.
3. **Avoid wake-lock APIs** unless genuinely needed (foreground video, navigation).
4. **Web push** — confirm registration is gated behind explicit user opt-in.

### Form-factor specifics
1. **Input fields** — use `inputmode` (`numeric`, `email`, `tel`, `decimal`) to load
   the right keyboard immediately.
2. **Buttons** — minimum 44×44 px tap target.
3. **Sticky headers** — measure CLS impact when the URL bar collapses on scroll.

## Output format

```markdown
# Mobile Performance Audit — <url>

**Profile:** Moto G4, Slow 4G, 4× CPU  •  **LCP (mobile):** … s  •  **INP (mobile):** … ms

## Viewport & touch
- Viewport meta: ok
- Passive listeners: 8 / 12 (3 non-passive `touchmove` handlers)
- `touch-action`: not set on .carousel — recommend `touch-action: pan-y`

## CPU
- Longest task (4× CPU): … ms
- Hydration time: … ms
- Top 3 long tasks: react-dom render (430 ms), GTM init (220 ms), modal init (180 ms)

## Network (Slow 4G)
- HTML+critical CSS+JS reach: … s (target < 1.5 s)
- LCP image arrival: … s
- Total transfer to first paint: … KB

## Mobile-specific issues
- Hero image served at 2400×1600 to a 360×240 viewport (decoded waste)
- `prefers-reduced-motion` ignored — large auto-rotating carousel
- Sticky header changes height on scroll → CLS spike

## Recommendations (tiered)
### Critical
- …
### High / Medium / Low
- …
```

## Tools

- **Lighthouse mobile preset** (default for `lighthouse` CLI).
- **Playwright** with `device.iPhone13` or `device.MotoG4` emulation.
- **Bash:** `lighthouse <url> --preset=mobile --form-factor=mobile`.
- **WebFetch** for the page HTML — confirm viewport meta and inputmode attributes.

## References

- web.dev — Mobile performance: https://web.dev/explore/mobile-performance
- web.dev — Passive event listeners: https://web.dev/articles/uses-passive-event-listeners
- MDN — `prefers-reduced-motion`: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion
