#!/usr/bin/env bash
# claude-perf uninstaller (Unix / macOS / Linux / WSL)
#
# Removes the master skill, sub-skills, and agents from ~/.claude/.
# Does NOT touch your settings.json or any other Claude Code state.

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_HOME/skills"
AGENTS_DIR="$CLAUDE_HOME/agents"

if [[ -t 1 ]]; then
  C_RESET='\033[0m'; C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_CYAN='\033[36m'
else
  C_RESET=''; C_GREEN=''; C_YELLOW=''; C_CYAN=''
fi

removed=0
remove_path() {
  local p="$1"
  if [[ -e "$p" || -L "$p" ]]; then
    rm -rf "$p"
    printf "${C_GREEN}  removed${C_RESET} %s\n" "$p"
    removed=$((removed + 1))
  fi
}

printf "${C_CYAN}==>${C_RESET} Uninstalling claude-perf from %s\n" "$CLAUDE_HOME"

remove_path "$SKILLS_DIR/perf"
for d in "$SKILLS_DIR/"perf-*; do
  [[ -e "$d" || -L "$d" ]] && remove_path "$d"
done
for f in "$AGENTS_DIR/"perf-agent-*.md; do
  [[ -e "$f" || -L "$f" ]] && remove_path "$f"
done

if [[ $removed -eq 0 ]]; then
  printf "${C_YELLOW}  nothing to remove${C_RESET}\n"
else
  printf "${C_GREEN}claude-perf uninstalled${C_RESET} (%d items removed)\n" "$removed"
fi
