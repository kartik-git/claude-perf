# WebPageTest extension

Triggers WebPageTest runs and surfaces filmstrip, waterfall, and metric data. WPT is the
gold standard for filmstrip-based visual completeness analysis.

## Setup

1. Get an API key at https://product.webpagetest.org/api
2. Export it: `export WPT_API_KEY=...`
3. Run the extension installer: `bash extensions/webpagetest/install.sh`

## Commands

| Command | Description |
|---|---|
| `/perf wpt run <url>` | Schedule a run (default: Dulles, Chrome, Cable) |
| `/perf wpt filmstrip <url>` | Visual filmstrip (paint progression) |
| `/perf wpt waterfall <url>` | Full request waterfall |
| `/perf wpt compare <a> <b>` | A/B waterfall comparison |

## Default profile

- Location: Dulles (us-east-1 equivalent)
- Browser: Chrome
- Network: Cable (5 Mbps / 1 Mbps / 28 ms RTT)

Override with `--location=...`, `--browser=...`, `--network=...`.

## Cost

Public WPT shares a quota across all users. Private WPT instances bill per run. See your
WPT account settings for budget/quota.
