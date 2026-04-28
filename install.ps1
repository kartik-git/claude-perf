# claude-perf installer (Windows PowerShell)
#
# Copies the master skill, sub-skills, and agents into $env:USERPROFILE\.claude\.
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Dev
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Force

[CmdletBinding()]
param(
    [switch]$Dev,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg)  { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "  ok $msg" -ForegroundColor Green }
function Write-WarnMsg($m) { Write-Host "  warn $m" -ForegroundColor Yellow }
function Write-ErrMsg($m)  { Write-Host "  err $m" -ForegroundColor Red }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeHome = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE '.claude' }
$SkillsDir = Join-Path $ClaudeHome 'skills'
$AgentsDir = Join-Path $ClaudeHome 'agents'

Write-Step "claude-perf installer"
Write-Host "  source : $ScriptDir"
Write-Host "  target : $ClaudeHome"
$mode = if ($Dev) { 'dev/symlink' } else { 'copy' }
Write-Host "  mode   : $mode"

# Prerequisites
$claude = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claude) {
    Write-WarnMsg "Claude Code CLI ('claude') not found on PATH. Install: https://docs.claude.com/claude-code"
}

New-Item -ItemType Directory -Force -Path $SkillsDir, $AgentsDir | Out-Null

function Install-Dir($Source, $Destination) {
    if (Test-Path $Destination) {
        if ($Force) { Remove-Item -Recurse -Force $Destination }
        else { Write-WarnMsg "exists, skipping: $Destination (use -Force to overwrite)"; return }
    }
    if ($Dev) {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
    } else {
        Copy-Item -Recurse -Force -Path $Source -Destination $Destination
    }
    Write-Ok (Split-Path $Destination -Leaf)
}

function Install-File($Source, $Destination) {
    if (Test-Path $Destination) {
        if (-not $Force) { Write-WarnMsg "exists, skipping: $(Split-Path $Destination -Leaf)"; return }
    }
    if ($Dev) {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
    } else {
        Copy-Item -Force -Path $Source -Destination $Destination
    }
    Write-Ok (Split-Path $Destination -Leaf)
}

# Master skill
Write-Step "Installing master skill"
Install-Dir (Join-Path $ScriptDir 'perf') (Join-Path $SkillsDir 'perf')

# Sub-skills
Write-Step "Installing sub-skills"
Get-ChildItem -Directory (Join-Path $ScriptDir 'skills') -Filter 'perf-*' | ForEach-Object {
    Install-Dir $_.FullName (Join-Path $SkillsDir $_.Name)
}

# Agents
Write-Step "Installing subagents"
Get-ChildItem -File (Join-Path $ScriptDir 'agents') -Filter 'perf-agent-*.md' | ForEach-Object {
    Install-File $_.FullName (Join-Path $AgentsDir $_.Name)
}

if (Test-Path (Join-Path $ScriptDir 'hooks')) {
    Write-Step "Hooks available (not auto-enabled). See docs/INSTALLATION.md."
}

Write-Host ""
Write-Host "claude-perf installed." -ForegroundColor Green
Write-Host "Try it:"
Write-Host "  claude"
Write-Host "  /perf audit https://example.com"
