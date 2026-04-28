#!/usr/bin/env bash
# claude-perf installer (Unix / macOS / Linux / WSL)
#
# Copies the master skill, sub-skills, and agents into ~/.claude/.
# Usage:
#   bash install.sh           # standard install (copy)
#   bash install.sh --dev     # symlink instead of copy (for development)
#   bash install.sh --force   # overwrite existing files without prompting

set -euo pipefail

# ---------- color helpers ----------
if [[ -t 1 ]]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
  C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'; C_CYAN='\033[36m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''
fi
log()    { printf "${C_CYAN}==>${C_RESET} %s\n" "$*"; }
ok()     { printf "${C_GREEN}  ok${C_RESET} %s\n" "$*"; }
warn()   { printf "${C_YELLOW}  warn${C_RESET} %s\n" "$*"; }
err()    { printf "${C_RED}  err${C_RESET} %s\n" "$*" >&2; }

# ---------- args ----------
DEV=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --dev) DEV=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) err "unknown flag: $arg"; exit 2 ;;
  esac
done

# ---------- paths ----------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_HOME/skills"
AGENTS_DIR="$CLAUDE_HOME/agents"

log "claude-perf installer"
printf "${C_DIM}  source : %s${C_RESET}\n" "$SCRIPT_DIR"
printf "${C_DIM}  target : %s${C_RESET}\n" "$CLAUDE_HOME"
printf "${C_DIM}  mode   : %s${C_RESET}\n" "$([[ $DEV -eq 1 ]] && echo dev/symlink || echo copy)"

# ---------- prerequisites ----------
if ! command -v claude >/dev/null 2>&1; then
  warn "Claude Code CLI ('claude') not found on PATH. Install: https://docs.claude.com/claude-code"
fi

mkdir -p "$SKILLS_DIR" "$AGENTS_DIR"

# ---------- copy or link ----------
install_dir() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" ]]; then
    if [[ $FORCE -eq 1 ]]; then
      rm -rf "$dst"
    else
      warn "exists, skipping: $dst (use --force to overwrite)"
      return 0
    fi
  fi
  if [[ $DEV -eq 1 ]]; then
    ln -s "$src" "$dst"
  else
    cp -R "$src" "$dst"
  fi
  ok "$(basename "$dst")"
}

install_file() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" && $FORCE -ne 1 ]]; then
    warn "exists, skipping: $(basename "$dst")"
    return 0
  fi
  if [[ $DEV -eq 1 ]]; then
    ln -sf "$src" "$dst"
  else
    cp "$src" "$dst"
  fi
  ok "$(basename "$dst")"
}

# Master skill
log "Installing master skill"
install_dir "$SCRIPT_DIR/perf" "$SKILLS_DIR/perf"

# Sub-skills
log "Installing sub-skills"
for sub in "$SCRIPT_DIR/skills/"perf-*; do
  [[ -d "$sub" ]] || continue
  install_dir "$sub" "$SKILLS_DIR/$(basename "$sub")"
done

# Agents
log "Installing subagents"
for agent in "$SCRIPT_DIR/agents/"perf-agent-*.md; do
  [[ -f "$agent" ]] || continue
  install_file "$agent" "$AGENTS_DIR/$(basename "$agent")"
done

# Hooks (optional — user opts in)
if [[ -d "$SCRIPT_DIR/hooks" ]]; then
  log "Hooks available (not auto-enabled). See docs/INSTALLATION.md to wire them into settings.json."
fi

# ---------- summary ----------
printf "\n${C_BOLD}claude-perf installed.${C_RESET}\n"
printf "Try it:\n"
printf "  ${C_CYAN}claude${C_RESET}\n"
printf "  ${C_CYAN}/perf audit https://example.com${C_RESET}\n"
