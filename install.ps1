<#
.SYNOPSIS
    Universal Windows Installer for 'chat-context-compactor' AI Skill.
.DESCRIPTION
    Downloads and installs chat-context-compactor from public GitHub (RudyCity/chat-context-compactor)
    into the global Antigravity configuration (~/.gemini/config/skills/) or active workspace (.agents/skills/).
.PARAMETER Workspace
    If specified, installs the skill into the local workspace (./.agents/skills/) rather than globally.
.EXAMPLE
    irm https://raw.githubusercontent.com/RudyCity/chat-context-compactor/main/install.ps1 | iex
    .\install.ps1 -Workspace
#>

[CmdletBinding()]
param (
    [switch]$Workspace
)

$RepoUrl = "https://github.com/RudyCity/chat-context-compactor.git"
$SkillName = "chat-context-compactor"

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🧠 CHAT CONTEXT COMPACTOR - UNIVERSAL SKILL INSTALLER    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Determine target directory
if ($Workspace) {
    $TargetDir = Join-Path (Get-Location) ".agents\skills\$SkillName"
    Write-Host "[*] Target Mode: Workspace Installation" -ForegroundColor Yellow
} else {
    $TargetDir = Join-Path $env:USERPROFILE ".gemini\config\skills\$SkillName"
    Write-Host "[*] Target Mode: Global Configuration (~/.gemini/config/skills/)" -ForegroundColor Yellow
}

Write-Host "[*] Target Directory: $TargetDir" -ForegroundColor Gray

# Ensure parent directory exists
$ParentDir = Split-Path -Parent $TargetDir
if (-not (Test-Path $ParentDir)) {
    New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
}

# Install via Git Clone or Update
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (Test-Path $TargetDir) {
    Write-Host "[!] Target directory already exists. Pulling latest updates..." -ForegroundColor Yellow
    if (Test-Path (Join-Path $TargetDir ".git")) {
        git -C "$TargetDir" pull origin main
    } else {
        Remove-Item -Path $TargetDir -Recurse -Force
        git clone "$RepoUrl" "$TargetDir"
    }
} else {
    Write-Host "[*] Cloning skill from GitHub: $RepoUrl ..." -ForegroundColor Cyan
    if ($gitCmd) {
        git clone "$RepoUrl" "$TargetDir"
    } else {
        # Fallback without git: download zip archive
        $zipUrl = "https://github.com/RudyCity/chat-context-compactor/archive/refs/heads/main.zip"
        $tmpZip = Join-Path $env:TEMP "chat-context-compactor.zip"
        Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip
        Expand-Archive -Path $tmpZip -DestinationPath $env:TEMP -Force
        Move-Item -Path (Join-Path $env:TEMP "chat-context-compactor-main") -Destination $TargetDir -Force
        Remove-Item -Path $tmpZip -Force -ErrorAction SilentlyContinue
    }
}

# Verify installation
$SkillFile = Join-Path $TargetDir "SKILL.md"
if (Test-Path $SkillFile) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " [OK] INSTALLATION SUCCESSFUL!" -ForegroundColor Green
    Write-Host " Skill 'chat-context-compactor' is now active on your system." -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "How to Use:" -ForegroundColor Yellow
    Write-Host "1. In any chat prompt: 'compact context of this session in detail'" -ForegroundColor White
    Write-Host "2. In a new chat session: 'Resume work from checkpoint CTX-...'" -ForegroundColor White
    Write-Host "3. CLI Runner: powershell -File `"$TargetDir\scripts\compact-session.ps1`"" -ForegroundColor White
    Write-Host ""
} else {
    Write-Error "Verification failed: SKILL.md not found in $TargetDir"
}
