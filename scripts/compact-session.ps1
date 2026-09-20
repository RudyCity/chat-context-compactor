<#
.SYNOPSIS
    Unified One-Shot Runner for Antigravity Chat Context Compactor (ID-Mentionable).
.DESCRIPTION
    Profiles conversation bloat, extracts all state invariants with an official
    Document ID (DOC-ID) and item-level anchor IDs, persists to Dual Storage
    (.checkpoints/ and ~/.gemini/checkpoints/), and auto-copies to the Windows Clipboard.
.PARAMETER DocId
    Optional custom Document ID (e.g., CTX-MAIN-001).
.PARAMETER Clipboard
    Auto-copies distilled handoff brief to clipboard (default: True).
.PARAMETER Output
    Optional markdown file path to save snapshot state.
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
Write-Host " [OK] CHECKPOINT DOCUMENT PERSISTED & RECONCILED!" -ForegroundColor Green
Write-Host "      - Global Store   : ~/.gemini/checkpoints/" -ForegroundColor White
Write-Host "      - Workspace Store: .checkpoints/" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
