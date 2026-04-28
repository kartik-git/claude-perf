# claude-perf uninstaller (Windows PowerShell)
#
# Removes the master skill, sub-skills, and agents from $env:USERPROFILE\.claude\.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ClaudeHome = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE '.claude' }
$SkillsDir = Join-Path $ClaudeHome 'skills'
$AgentsDir = Join-Path $ClaudeHome 'agents'

Write-Host "==> Uninstalling claude-perf from $ClaudeHome" -ForegroundColor Cyan

$removed = 0
function Remove-Path($p) {
    if (Test-Path $p) {
        Remove-Item -Recurse -Force $p
        Write-Host "  removed $p" -ForegroundColor Green
        $script:removed += 1
    }
}

Remove-Path (Join-Path $SkillsDir 'perf')
Get-ChildItem -Path $SkillsDir -Filter 'perf-*' -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Path $_.FullName
}
Get-ChildItem -Path $AgentsDir -Filter 'perf-agent-*.md' -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Path $_.FullName
}

if ($removed -eq 0) {
    Write-Host "  nothing to remove" -ForegroundColor Yellow
} else {
    Write-Host "claude-perf uninstalled ($removed items removed)" -ForegroundColor Green
}
