<#
.SYNOPSIS
    Unified One-Shot Runner untuk Pemadatan Konteks Sesi Antigravity (with Mention by ID).
.DESCRIPTION
    Menjalankan audit profil konteks, mengekstrak seluruh state invariants
    dengan ID Dokumen (DOC-ID) dan Anchor ID unik, menyimpannya ke Dual Storage
    (.checkpoints/ dan ~/.gemini/checkpoints/), serta menyalinnya ke Clipboard.
.PARAMETER DocId
    Custom Document ID opsional (misal: CTX-001).
.PARAMETER Clipboard
    Menyalin hasil handoff brief langsung ke clipboard (default: True).
.PARAMETER Output
    Path file markdown opsional untuk menyimpan snapshot state.
.EXAMPLE
    .\compact-session.ps1
    .\compact-session.ps1 -DocId "CTX-MAIN-001"
#>

[CmdletBinding()]
param (
    [string]$DocId = "",
    [switch]$Clipboard = $true,
    [string]$Output = ""
)

$scriptDir = $PSScriptRoot
$compressor = Join-Path $scriptDir "context_compressor.py"

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " [ONE-SHOT CHAT CONTEXT COMPACTOR (ID-MENTIONABLE)]      " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""

$pyArgs = @("`"$compressor`"")
if ($DocId) {
    $pyArgs += @("--doc-id", "`"$DocId`"")
}
if ($Output) {
    $pyArgs += @("--output", "`"$Output`"")
}
if ($Clipboard) {
    $pyArgs += "--clipboard"
}

$cmd = "python " + ($pyArgs -join " ")
Invoke-Expression $cmd

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " [OK] CHECKPOINT DOKUMEN BERHASIL DISIMPAN & DIREKONSILIASI!" -ForegroundColor Green
Write-Host "      - Global Store   : ~/.gemini/checkpoints/" -ForegroundColor White
Write-Host "      - Workspace Store: .checkpoints/" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
