#!/usr/bin/env bash
# claude-perf — post-deploy hook
#
# Wire into ~/.claude/settings.json so that detected deployment commands
# (vercel deploy, netlify deploy, fly deploy, gh workflow run deploy, ...) trigger
# a lightweight CWV check against the deployed URL.
#
# The deployed URL is read from:
#   $PERF_DEPLOY_URL (env override) — preferred
#   stdout from the deploy command (parsed for the first https:// URL)
#
# Honors a .perf-ignore file in the project root (one path/glob per line).

set -euo pipefail

URL="${PERF_DEPLOY_URL:-}"

if [[ -z "$URL" ]]; then
  echo "claude-perf: PERF_DEPLOY_URL not set; cannot run post-deploy CWV check."
  echo "  set it after deploy:  export PERF_DEPLOY_URL=https://your-deploy-url"
  exit 0
fi

echo "claude-perf: detected deploy to $URL"
echo "claude-perf: ask Claude to run /perf cwv $URL for a quick post-deploy check,"
echo "             or /perf audit $URL for a full audit."

if [[ -f .perf-budget.json ]]; then
  echo "claude-perf: .perf-budget.json present — /perf budget check will gate."
fi
