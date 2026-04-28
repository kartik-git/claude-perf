# PageSpeed Insights extension

Pulls live Lighthouse scores plus CrUX field data from Google's PageSpeed Insights API.

## Setup

1. Get a free API key at
   https://developers.google.com/speed/docs/insights/v5/get-started
2. Export it: `export PAGESPEED_API_KEY=...`
3. Run the extension installer: `bash extensions/pagespeed/install.sh`

## Commands

| Command | Description |
|---|---|
| `/perf pagespeed <url>` | Full PSI report (lab + field, mobile + desktop) |
| `/perf pagespeed field <url>` | Field-only (CrUX p75 LCP/INP/CLS) |
| `/perf pagespeed compare <a> <b>` | Side-by-side PSI scores |

## Rate limits

PageSpeed API is rate-limited per key (default ~25,000 queries/day). Cache results
locally if you're auditing many URLs.
