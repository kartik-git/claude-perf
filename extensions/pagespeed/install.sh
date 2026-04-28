#!/usr/bin/env bash
# claude-perf — PageSpeed Insights extension installer
#
# This extension lets /perf pull live Lighthouse + CrUX data from Google's
# PageSpeed Insights API.
#
# Requirements:
#   PAGESPEED_API_KEY environment variable (get one from
#   https://developers.google.com/speed/docs/insights/v5/get-started)

set -euo pipefail

if [[ -z "${PAGESPEED_API_KEY:-}" ]]; then
  echo "PAGESPEED_API_KEY is not set."
  echo "Get a key at https://developers.google.com/speed/docs/insights/v5/get-started"
  echo "Then: export PAGESPEED_API_KEY=..."
  exit 1
fi

echo "PageSpeed Insights extension: API key detected."
echo "Try: /perf pagespeed https://example.com"
