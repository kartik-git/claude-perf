---
name: perf-bundle
description: JavaScript and CSS bundle analysis — payload size, duplicates, tree-shaking gaps, code-splitting opportunities, compression ratios, and build-tool config review.
type: skill
parent: perf
---

# `perf-bundle` — Bundle Analysis

## Scope

Analyze every byte of JavaScript and CSS the page sends to the browser. Identify what is
unused, duplicated, oversized, or shippable as a smaller chunk. Works against either a
local build directory (`./dist`, `./build`, `.next/`) or a deployed URL.

## When to invoke

- `/perf bundle [path|url]` — explicit
- During `/perf audit` — fan-out via `perf-agent-bundle`
- Mentions of: "bundle size", "JS payload", "tree shaking", "code splitting",
  "webpack-bundle-analyzer", "Vite analyze", "chunk", "vendor.js"

## Inputs

| Input | Behavior |
|---|---|
| Directory path with build output | Read `stats.json` if present; otherwise scan `*.js` and `*.css` files. |
| URL | Fetch the page, list every `<script>` and `<link rel="stylesheet">`, download each, measure raw + gzip + Brotli sizes. |
| Source repo | Look for `webpack.config.*`, `vite.config.*`, `rollup.config.*`, `next.config.*`, `tsconfig.json`. |

## Analysis checklist

### Payload measurement
1. **Total JS** delivered on first load (transfer size, decoded size, parsed time).
2. **Total CSS** delivered on first load.
3. **Per-route JS** if a routing manifest is detectable (Next.js `_buildManifest.js`,
   Remix, SvelteKit).
4. **Compression ratio** — confirm Brotli (preferred) or gzip on every text resource.
   Flag any uncompressed JS/CSS.

### Duplication
1. **Duplicate dependencies** across chunks. Look for the same package version appearing
   in multiple chunks (often `react`, `lodash`, `moment`).
2. **Multiple versions of the same package** — typically caused by transitive deps with
   strict version ranges. Recommend `resolutions` (Yarn) or `overrides` (npm).
3. **Polyfills shipped to modern browsers** — confirm `browserslist` is set, and the
   build is producing a modern bundle (no `core-js` for `fetch`, `Promise`, etc.).

### Tree-shaking gaps
1. **Top 10 packages by size** — flag any whose used surface is small (e.g., importing
   `lodash` for one function instead of `lodash/get`).
2. **Side-effect declarations** — confirm `package.json` has `"sideEffects": false` on
   pure libraries; without it, tree-shaking is conservative.
3. **Barrel files** (`index.ts` re-exporting everything) — these defeat tree-shaking
   for some bundlers. Recommend deep imports.
4. **CommonJS in the dependency graph** — CJS dependencies block static analysis. Flag
   them as conversion candidates.

### Code splitting
1. **Routes** — every route should have its own chunk loaded async.
2. **Heavy components** below the fold — recommend `React.lazy` / `import()`.
3. **Modal / dialog code** — load on first open, not on first paint.
4. **Vendor chunk strategy** — single vendor chunk vs split-by-package. Recommend
   `splitChunks.cacheGroups` with reasonable size thresholds.

### CSS-specific
1. **Unused CSS** — measure with Coverage tool / PurgeCSS.
2. **Critical CSS extraction** — if the framework supports it (Next, Astro, SvelteKit,
   Nuxt), confirm it's enabled.
3. **Specificity bloat** — flag selectors deeper than 3 levels or with `!important`.
4. **Long CSS files** — anything > 50 KB raw is a candidate for splitting by route.

### Build-tool review
1. **Webpack:** check `mode: 'production'`, `optimization.minimize`,
   `optimization.runtimeChunk`, `optimization.splitChunks`, `output.chunkFilename`.
2. **Vite / Rollup:** check `build.target`, `build.minify`, `build.rollupOptions.output`.
3. **esbuild:** check `--target`, `--minify`, `--splitting`, `--format=esm`.
4. **Next.js:** check `experimental.optimizePackageImports`, `compiler.removeConsole`,
   `swcMinify`, `output: 'standalone'` for serverless.

## Output format

```markdown
# Bundle Analysis — <target>

**Total transferred:** <KB>  •  **JS:** <KB>  •  **CSS:** <KB>  •  **Compression:** <gzip|br|none>

## Treemap (top contributors)
| Chunk           | Size (Brotli) | Decoded | Notes |
|-----------------|---------------|---------|-------|
| vendor.abc.js   | 142 KB        | 480 KB  | react-dom, lodash (full) |
| main.def.js     |  38 KB        | 110 KB  | route entry |
| …               | …             | …       | … |

## Duplicates
- `lodash@4.17.21` appears in 3 chunks (savings: ~14 KB Brotli)
- `react@18.2.0` and `react@17.0.2` both present (resolve to one)

## Tree-shaking gaps
- `import { format } from 'date-fns'` ships entire pkg (~70 KB) — use `date-fns/format`
- `moment.js` detected — replace with `date-fns` or `dayjs` (savings ~60 KB Brotli)

## Code-splitting opportunities
- `Editor` component (180 KB) loaded synchronously — wrap in `React.lazy`
- Modal stack always loaded — defer until trigger

## Build-config notes
- `next.config.js` missing `experimental.optimizePackageImports` for `lucide-react`
- `webpack.config.js` has `mode: 'development'` (looks like a copy/paste from a script)

## Recommendations (tiered)
### Critical
- …
### High
- …
### Medium / Low
- …
```

## Tools to use

- **Read / Glob** for build configs and stats files.
- **Bash** to invoke `npx source-map-explorer`, `npx webpack-bundle-analyzer`,
  `npx vite-bundle-visualizer` if available.
- **WebFetch** for live URL fetches; capture `Content-Encoding` header.
- **Playwright** with `page.coverage.startJSCoverage()` / `startCSSCoverage()` for
  unused-byte analysis.

## References

- web.dev — Reduce JavaScript payloads: https://web.dev/articles/reduce-javascript-payloads-with-tree-shaking
- bundlephobia.com for size deltas of any npm package
- Webpack `splitChunks`: https://webpack.js.org/plugins/split-chunks-plugin/
