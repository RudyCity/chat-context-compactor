<#
.SYNOPSIS
    Universal Windows Installer untuk Skill 'chat-context-compactor'.
.DESCRIPTION
    Mengunduh dan memasang skill chat-context-compactor dari GitHub public (RudyCity/chat-context-compactor)
    ke direktori global Antigravity (~/.gemini/config/skills/) atau workspace aktif (.agents/skills/).
.PARAMETER Workspace
    Jika diaktifkan, skill akan dipasang ke workspace lokal (./.agents/skills/) bukan global.
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

# Tentukan target instalasi
if ($Workspace) {
    $TargetDir = Join-Path (Get-Location) ".agents\skills\$SkillName"
    Write-Host "[*] Mode: Workspace Installation" -ForegroundColor Yellow
} else {
    $TargetDir = Join-Path $env:USERPROFILE ".gemini\config\skills\$SkillName"
    Write-Host "[*] Mode: Global Configuration (~/.gemini/config/skills/)" -ForegroundColor Yellow
}

Write-Host "[*] Target Direktori: $TargetDir" -ForegroundColor Gray

# Buat direktori induk jika belum ada
$ParentDir = Split-Path -Parent $TargetDir
if (-not (Test-Path $ParentDir)) {
    New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
}

# Instalasi via Git Clone atau Update jika folder sudah ada
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (Test-Path $TargetDir) {
    Write-Host "[!] Folder tujuan sudah ada. Memperbarui berkas..." -ForegroundColor Yellow
    if (Test-Path (Join-Path $TargetDir ".git")) {
        git -C "$TargetDir" pull origin main
    } else {
        # Timpa dengan kloning bersih
        Remove-Item -Path $TargetDir -Recurse -Force
        git clone "$RepoUrl" "$TargetDir"
    }
} else {
    Write-Host "[*] Mengunduh skill dari GitHub: $RepoUrl ..." -ForegroundColor Cyan
    if ($gitCmd) {
        git clone "$RepoUrl" "$TargetDir"
    } else {
        # Fallback tanpa git: unduh zip dari GitHub
        $zipUrl = "https://github.com/RudyCity/chat-context-compactor/archive/refs/heads/main.zip"
        $tmpZip = Join-Path $env:TEMP "chat-context-compactor.zip"
        Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip
        Expand-Archive -Path $tmpZip -DestinationPath $env:TEMP -Force
        Move-Item -Path (Join-Path $env:TEMP "chat-context-compactor-main") -Destination $TargetDir -Force
        Remove-Item -Path $tmpZip -Force -ErrorAction SilentlyContinue
    }
}

# Verifikasi pemasangan
$SkillFile = Join-Path $TargetDir "SKILL.md"
if (Test-Path $SkillFile) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " [OK] INSTALASI BERHASIL!" -ForegroundColor Green
    Write-Host " Skill 'chat-context-compactor' kini aktif di sistem Anda." -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Cara Menggunakan:" -ForegroundColor Yellow
    Write-Host "1. Cukup katakan di obrolan: 'compact context sesi ini secara detail'" -ForegroundColor White
    Write-Host "2. Atau sebutkan ID di sesi baru: 'Lanjutkan dari checkpoint CTX-...'" -ForegroundColor White
    Write-Host "3. Atau jalankan CLI runner: powershell -File `"$TargetDir\scripts\compact-session.ps1`"" -ForegroundColor White
    Write-Host ""
} else {
    Write-Error "Gagal memverifikasi berkas SKILL.md di $TargetDir"
}
