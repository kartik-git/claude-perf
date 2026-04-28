#!/usr/bin/env bash
# claude-perf — WebPageTest extension installer
#
# Triggers WebPageTest runs and pulls filmstrip / waterfall / metric data.
#
# Requirements:
#   WPT_API_KEY environment variable (get one from
#   https://product.webpagetest.org/api)

set -euo pipefail

if [[ -z "${WPT_API_KEY:-}" ]]; then
  echo "WPT_API_KEY is not set."
  echo "Get a key at https://product.webpagetest.org/api"
  echo "Then: export WPT_API_KEY=..."
  exit 1
fi

echo "WebPageTest extension: API key detected."
echo "Try: /perf wpt run https://example.com"
