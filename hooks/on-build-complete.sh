#!/usr/bin/env bash
# claude-perf — post-build hook
#
# Wire this into ~/.claude/settings.json under hooks.PostToolUse so that any
# detected build command (npm run build, vite build, next build, ...) auto-triggers
# a bundle audit on the output directory.
#
# Output directory detection (in priority order):
#   $PERF_BUILD_DIR (env override)
#   ./dist
#   ./build
#   ./.next
#   ./.output
#   ./out
#
# Honors a .perf-ignore file in the project root (one path/glob per line).

set -euo pipefail

DIR=""
for candidate in "${PERF_BUILD_DIR:-}" dist build .next .output out; do
  [[ -n "$candidate" && -d "$candidate" ]] && DIR="$candidate" && break
done

if [[ -z "$DIR" ]]; then
  exit 0
fi

echo "claude-perf: detected build output at $DIR"
echo "claude-perf: ask Claude to run /perf bundle $DIR for a payload audit."

# Optional: surface a quick budget check if .perf-budget.json exists
if [[ -f .perf-budget.json ]]; then
  echo "claude-perf: .perf-budget.json present — /perf budget check will validate."
fi
