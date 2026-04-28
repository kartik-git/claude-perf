#!/usr/bin/env bash
# claude-perf — Chrome UX Report extension installer
#
# Pulls 28-day rolling real-user CWV percentiles by URL/origin.
#
# Requirements:
#   CRUX_API_KEY environment variable (get one from
#   https://developer.chrome.com/docs/crux/api/)

set -euo pipefail

if [[ -z "${CRUX_API_KEY:-}" ]]; then
  echo "CRUX_API_KEY is not set."
  echo "Get a key at https://developer.chrome.com/docs/crux/api/"
  echo "Then: export CRUX_API_KEY=..."
  exit 1
fi

echo "CrUX extension: API key detected."
echo "Try: /perf crux https://example.com"
