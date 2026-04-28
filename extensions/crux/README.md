# Chrome UX Report (CrUX) extension

Pulls 28-day rolling real-user Web Vitals percentiles. Field data — what users actually
experience — at URL or origin granularity, optionally filtered by country and form factor.

## Setup

1. Get a free API key at https://developer.chrome.com/docs/crux/api/
2. Export it: `export CRUX_API_KEY=...`
3. Run the extension installer: `bash extensions/crux/install.sh`

## Commands

| Command | Description |
|---|---|
| `/perf crux <url>` | Origin-level CrUX data |
| `/perf crux url <url>` | URL-level CrUX data (only available for high-traffic URLs) |
| `/perf crux trend <url>` | 12-month trend via CrUX History API |

## Coverage

- URL-level data is only available for URLs with sufficient traffic to anonymize.
- Falls back to origin-level data when a URL is below the threshold.
- Results are aggregated globally; pass `--country=us` (or another ISO code) for
  country-scoped percentiles.
