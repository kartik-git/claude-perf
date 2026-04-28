---
name: perf-network
description: Network and protocol audit — HTTP/2 vs HTTP/3, TTFB, compression (Brotli/gzip), Cache-Control coherence, CDN config, preconnect, TLS, and Vary correctness.
type: skill
parent: perf
---

# `perf-network` — Network & Protocol

## Scope

Everything between the user's browser and the bytes leaving the origin. Protocol version,
compression, headers, TLS, CDN cache-hit rate, edge config.

## When to invoke

- `/perf network <url>` — explicit
- During `/perf audit` — fan-out via `perf-agent-network`
- Mentions of: "TTFB", "HTTP/2", "HTTP/3", "QUIC", "Brotli", "gzip", "Vary",
  "Cache-Control", "CDN", "edge", "preconnect"

## Analysis checklist

### Protocol
1. **HTTP version** — confirm HTTP/2 or HTTP/3 on the main document and key resources
   (use `curl -I --http3`).
2. **HTTP/3 / QUIC readiness** — if origin supports HTTP/3, confirm `Alt-Svc` header
   advertises it.
3. **Origin connection reuse** — count distinct origins on the critical path. Each
   one is a TCP+TLS handshake. >4 is usually a smell.

### TTFB
1. **Measure** — repeated `curl -w "%{time_starttransfer}"` to avoid first-shot
   variance. Or use Playwright's `responseStart - requestStart`.
2. **Targets:** TTFB < 200 ms for static, < 600 ms for SSR'd pages, < 800 ms upper
   bound.
3. **Causes of high TTFB:**
   - Origin not behind a CDN (or CDN cache miss)
   - Cold serverless function
   - Sequential DB queries on the request path
   - Heavy SSR work (e.g., synchronous data fetching)
4. **Early Hints (103)** — recommend if origin can emit them. Lets the browser start
   preconnecting/preloading before the full response arrives.

### Compression
1. **Confirm Brotli** on `text/html`, `text/css`, `application/javascript`,
   `application/json`, `application/manifest+json`, `image/svg+xml`, `font/woff2`
   (woff2 is already self-compressed; double-compression is fine but a no-op).
2. **gzip** is acceptable fallback; never serve uncompressed text.
3. **Compression ratio sanity check** — Brotli should beat gzip by ~17% on JS/CSS.
   If the ratio is suspiciously low, the CDN is probably re-compressing at quality 4
   instead of 11.

### Cache-Control coherence
1. **HTML:** `Cache-Control: no-cache` or short `s-maxage` with `stale-while-revalidate`.
2. **Hashed assets** (`/assets/main.abc123.js`): `Cache-Control: public, max-age=31536000, immutable`.
3. **Unhashed assets** (`/logo.svg`): a few hours, with revalidation.
4. **API responses:** explicit policy or `no-store`.

### CDN config
1. **Cache-hit rate** — use the CDN's debug header (`x-cache`, `cf-cache-status`,
   `x-amz-cf-pop`). Aim for ≥95% on static assets.
2. **Origin shield** — recommend if not enabled and the CDN supports it.
3. **Vary header correctness** — `Vary: Accept-Encoding` is mandatory if any
   compression negotiation happens. `Vary: Accept` for image format negotiation.
4. **`Strict-Transport-Security`** — confirm HSTS is on (mostly security, but it
   eliminates the HTTP-to-HTTPS redirect on first visit, saving an RTT).

### Resource hints from the network angle
- `<link rel="preconnect">` for any cross-origin in the critical path. Each
  preconnect costs DNS + TCP + TLS up front; >4 is wasteful.
- `dns-prefetch` is the cheaper, less effective alternative — use as a fallback in
  addition to (not instead of) preconnect for older browsers.

## Output format

```markdown
# Network Audit — <url>

**TTFB:** … ms  •  **Protocol:** HTTP/3  •  **Encoding:** br  •  **CDN:** cloudflare

## Origin
- TTFB (p50/p75/p95): … / … / …
- Origin region(s): …
- Edge POP: …
- Cache status: hit / miss

## Headers
| Header | Value | Note |
|--------|-------|------|
| Cache-Control | public, max-age=31536000, immutable | good |
| Content-Encoding | br | good |
| Vary | Accept-Encoding | ok |
| Strict-Transport-Security | … | … |
| Alt-Svc | h3=":443"; ma=86400 | HTTP/3 advertised |

## Compression coverage
| Type | Total | Compressed | Avg ratio |
|------|-------|------------|-----------|
| JS   | 8     | 8 (br)     | 4.1×      |
| CSS  | 3     | 3 (br)     | 5.6×      |
| HTML | 1     | 1 (gzip)   | 3.2× — should be Brotli |

## Issues
- HTML uses gzip while assets use Brotli (CDN config mismatch)
- 6 third-party origins — recommend preconnect for the 2 in critical path
- TLS handshake adds ~120 ms (no session resumption)

## Recommendations (tiered)
### Critical
- …
### High / Medium / Low
- …
```

## Tools

- **Bash:** `curl -I -L --http2 / --http3` for protocol probing.
- **Bash:** `curl -w '%{time_namelookup}|%{time_connect}|%{time_appconnect}|%{time_pretransfer}|%{time_starttransfer}|%{time_total}'` for waterfall measurement.
- **WebFetch** for header capture.

## References

- web.dev — TTFB: https://web.dev/articles/ttfb
- web.dev — Brotli: https://web.dev/articles/codelab-text-compression-brotli
- RFC 9114 — HTTP/3: https://www.rfc-editor.org/rfc/rfc9114.html
- RFC 9111 — HTTP Caching: https://www.rfc-editor.org/rfc/rfc9111.html
