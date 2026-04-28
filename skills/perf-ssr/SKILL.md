---
name: perf-ssr
description: SSR / hydration audit — TTFB by rendering mode, streaming SSR, hydration cost, selective hydration, islands, partial prerendering, and edge rendering tradeoffs.
type: skill
parent: perf
---

# `perf-ssr` — Server-Side Rendering & Hydration

## Scope

How the HTML is generated and how it becomes interactive. Covers SSR, SSG, ISR, CSR,
streaming, hydration, islands, and partial prerendering — and the tradeoffs each makes
between TTFB, LCP, and INP.

## When to invoke

- `/perf ssr <url>` — explicit
- During `/perf audit` — covered by `perf-agent-render`
- Mentions of: "SSR", "SSG", "ISR", "hydration", "Suspense", "streaming",
  "selective hydration", "islands", "PPR", "Astro", "Qwik", "edge runtime"

## Rendering modes (cheat sheet)

| Mode | TTFB | LCP | INP | Best for |
|---|---|---|---|---|
| **CSR** (client-side render) | fast (cached HTML) | slow (waits on JS) | varies | App-like dashboards behind auth |
| **SSR** (per-request) | medium-slow | fast | depends on hydration cost | Personalized pages |
| **SSG** (build-time) | very fast | very fast | depends on hydration cost | Marketing, docs, blogs |
| **ISR** (revalidate at edge) | very fast | very fast | depends on hydration cost | E-commerce category pages |
| **Streaming SSR** | fast first byte, progressive | fast | depends on hydration cost | Pages with slow data |
| **PPR** (partial prerender) | very fast | very fast | depends on hydration cost | Mostly-static pages with dynamic islands |
| **Islands** (Astro, Marko) | fast | fast | very low | Content-heavy sites |
| **Resumability** (Qwik) | fast | fast | very low | Interactive content sites |

## Analysis checklist

### Detect the rendering mode
1. **Framework signal** — Next.js, Remix, SvelteKit, Nuxt, Astro, Qwik, Gatsby — each
   has a default mode and per-route overrides.
2. **Headers** — `x-vercel-cache: HIT`, `cache-control: s-maxage=...`, custom CDN
   headers.
3. **HTML signals:**
   - Long inline `__NEXT_DATA__` / `__remixContext` blob → SSR or SSG
   - Single empty `<div id="root">` → CSR shell
   - `<!--$-->` Suspense boundary comments → React streaming
   - `data-qwik` attributes → Qwik resumability

### TTFB by mode
- SSG / ISR / PPR cached: **<200 ms** target.
- SSR cold serverless: **<800 ms** target; investigate if higher.
- SSR warm: **<400 ms** target.
- Streaming first-byte: **<200 ms** target — first chunk should be the HTML head with
  preloads/preconnects.

### Hydration cost
1. **Hydration JS payload** — measure JS that *must* run before the page is interactive.
2. **Time to Interactive (TTI)** — measure with Lighthouse.
3. **Selective hydration opportunities:**
   - React 18: `<Suspense>` boundaries + `lazy()` for below-fold content
   - Next.js: `next/dynamic` with `{ ssr: false }` for client-only widgets
   - Astro: `client:idle`, `client:visible`, `client:media` directives
4. **Islands check** — if 80%+ of the page is static, the right architecture might be
   islands (Astro), not full hydration.

### Streaming SSR
1. Confirm the framework supports it (`renderToPipeableStream` in React 18+).
2. Confirm `<Suspense>` boundaries wrap async data fetches.
3. Confirm critical above-the-fold content is **outside** any Suspense boundary so
   it streams first.
4. Confirm CDN/edge does not buffer the entire response (some default to buffering).

### Edge rendering
1. **Edge runtime** (Cloudflare Workers, Vercel Edge, Fastly Compute, Deno Deploy)
   moves SSR closer to the user — usually a 100–300 ms TTFB win.
2. **Cold start** — edge runtimes typically warm in <50 ms; serverless functions
   200–800 ms. If cold-start TTFB is the problem, edge usually fixes it.
3. **Compatibility** — edge runtimes have a smaller API surface than Node. Check that
   used npm packages work on edge.

### Partial prerendering (PPR)
- Next.js App Router supports PPR: static shell prerendered, dynamic holes streamed
  in. Confirm `experimental.ppr` is enabled and `unstable_noStore()` is used in the
  truly dynamic parts.

## Output format

```markdown
# SSR / Hydration Audit — <url>

**Rendering mode:** SSR (Next.js, App Router)  •  **Runtime:** Node serverless  •  **TTFB:** … ms

## Hydration cost
- JS required before interactive: … KB (Brotli)
- Hydration time (4× CPU): … ms
- TTI (lab): … s
- Components hydrated above fold: …
- Components hydrated below fold but eagerly: … (move to `client:visible` / `next/dynamic`)

## Streaming
- `<Suspense>` boundaries detected: N
- First chunk size: … KB
- Critical content streamed first: yes/no

## Edge
- Runtime: Node serverless (edge available — recommend)
- Cold-start TTFB hit: ~600 ms — every minute or two
- Cache hit ratio at edge: …

## Recommendations (tiered)
### Critical
- …
### High / Medium / Low
- …
```

## Tools

- **WebFetch** for the rendered HTML (look for hydration-data blobs, framework hints).
- **Bash:** `curl -I` for cache headers; repeated `curl -w '%{time_starttransfer}'`
  for TTFB distribution.
- **Read** for the project's `next.config.*` / `astro.config.*` / `nuxt.config.*` /
  `svelte.config.*`.

## References

- web.dev — Rendering on the web: https://web.dev/articles/rendering-on-the-web
- React 18 streaming: https://react.dev/reference/react-dom/server/renderToPipeableStream
- Next.js PPR: https://nextjs.org/docs/app/api-reference/config/next-config-js/ppr
- Astro Islands: https://docs.astro.build/en/concepts/islands/
- Qwik resumability: https://qwik.dev/docs/concepts/resumable/
