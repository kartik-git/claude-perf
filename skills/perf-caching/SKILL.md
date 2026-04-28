---
name: perf-caching
description: Caching strategy audit — Cache-Control coherence, immutable hashed assets, CDN TTL alignment, stale-while-revalidate, service worker precaching, and ETag/Last-Modified validation.
type: skill
parent: perf
---

# `perf-caching` — Caching Strategy

## Scope

Browser cache, CDN edge cache, and service worker precache — three layers, each with its
own rules. This sub-skill audits all three and verifies they cooperate.

## When to invoke

- `/perf cache <url>` — explicit
- During `/perf audit` — covered by `perf-agent-network` (delegates here)
- Mentions of: "Cache-Control", "max-age", "immutable", "stale-while-revalidate",
  "service worker", "Workbox", "PWA cache", "ETag", "Last-Modified"

## The three layers

| Layer | Where | Lifetime control |
|---|---|---|
| Browser | User's machine | `Cache-Control` from origin/CDN |
| CDN edge | POPs near user | `s-maxage`, `surrogate-control`, CDN UI |
| Service worker | App-controlled JS | Workbox routes / cache-first / network-first |

## Analysis checklist

### Browser cache (Cache-Control)
1. **Hashed/fingerprinted assets** (e.g., `main.abc123.js`):
   - `Cache-Control: public, max-age=31536000, immutable`
   - `immutable` tells modern browsers to skip revalidation entirely.
2. **Unhashed assets** (logos, manifest, sitemap):
   - `Cache-Control: public, max-age=86400, must-revalidate` is reasonable.
   - Always include either `ETag` or `Last-Modified` for revalidation.
3. **HTML documents:**
   - `Cache-Control: no-cache` (revalidate every visit) for SSR'd pages.
   - Or short `s-maxage=60, stale-while-revalidate=86400` for ISR/edge-cached HTML.
4. **API responses:**
   - Default to `Cache-Control: no-store` unless data is genuinely shareable.
   - For shareable: short `s-maxage` + `stale-while-revalidate`.

### CDN cache
1. **`s-maxage`** controls CDN TTL specifically; pair it with browser `max-age` for
   the right split (e.g., `Cache-Control: public, max-age=0, s-maxage=86400` —
   browser revalidates every visit, CDN holds for a day).
2. **`stale-while-revalidate`** lets the CDN serve stale content instantly while
   fetching a fresh copy in the background. Huge TTFB win at the edge.
3. **`stale-if-error`** serves cached content if the origin is down — resilience win.
4. **Cache-hit rate** — confirm via the CDN's debug header (`cf-cache-status`,
   `x-cache`, etc.). Aim for >90% on static assets.

### Service worker
1. **Detection:** check for `navigator.serviceWorker.register(...)` or a
   `service-worker.js` / `sw.js` at the root.
2. **Precache** — list of critical assets cached on install. Should be:
   - The app shell (HTML, critical CSS, critical JS)
   - Offline fallback page
   - Logo / favicon
3. **Runtime caching strategies:**
   - `CacheFirst` — fonts, images, hashed assets
   - `StaleWhileRevalidate` — CSS/JS that may rev between deploys
   - `NetworkFirst` — HTML, API
   - `NetworkOnly` — login, payments, mutations
4. **Versioning** — service workers must invalidate stale caches on activate. Check
   for a versioned cache name and a cleanup loop in the `activate` event.

### Validators
- **ETag** vs **Last-Modified** — use one or the other; both is fine but redundant.
- **Strong vs weak ETags** — weak (`W/"abc"`) is fine for most CDNs.

## Common findings

| Finding | Fix |
|---|---|
| Hashed JS without `immutable` | Add `immutable` |
| HTML with `max-age=86400` (day-long browser cache) | Switch to `no-cache` or short `s-maxage` |
| API with no `Cache-Control` | Add explicit `no-store` or a deliberate policy |
| Service worker without cache-cleanup | Add an `activate` handler that deletes stale cache versions |
| `Vary: User-Agent` on the CDN | Almost always wrong — fragments the cache catastrophically |

## Output format

```markdown
# Caching Audit — <url>

**Browser-cacheable bytes:** … KB / … KB total  •  **CDN cache-hit rate:** …%  •  **SW:** present/absent

## Cache-Control matrix
| Resource group | Sample header | Verdict |
|----------------|---------------|---------|
| Hashed JS      | public, max-age=31536000 | missing `immutable` |
| Hashed CSS     | public, max-age=31536000, immutable | good |
| Images         | public, max-age=86400 | could be longer |
| HTML           | (none) | should set no-cache |
| API /api/*     | public, max-age=300 | recheck — looks shareable, ok |

## CDN
- Provider: Cloudflare
- Cache hit (sample): 87% (target ≥95% on static)
- `Vary` headers: `Accept-Encoding` only — good

## Service worker
- Registered: yes
- Precached: 12 files (180 KB)
- Strategies: CacheFirst (fonts/images), NetworkFirst (HTML), SWR (CSS/JS)
- Cache cleanup on activate: missing

## Recommendations (tiered)
### Critical
- …
### High / Medium / Low
- …
```

## Tools

- **Bash:** `curl -I` for live header capture; repeated requests to detect cache hits.
- **WebFetch** for the page and `Service-Worker` header.
- **Playwright** to inspect `caches.keys()` and `caches.match(...)` runtime state.

## References

- web.dev — HTTP cache: https://web.dev/articles/http-cache
- web.dev — Service Worker caching: https://web.dev/articles/service-worker-caching
- RFC 9111 — HTTP Caching: https://www.rfc-editor.org/rfc/rfc9111.html
- Workbox: https://developer.chrome.com/docs/workbox/
