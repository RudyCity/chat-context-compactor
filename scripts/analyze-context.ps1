<#
.SYNOPSIS
    Antigravity Chat Transcript Auditor & Bloat Profiler.
.DESCRIPTION
    Scans transcript.jsonl for the active or target session to measure token
    bloat, tool call distribution, and mutated files, recommending optimal
    compaction strategies with zero state loss.
.PARAMETER TranscriptPath
    Absolute path to transcript.jsonl. If omitted, locates the latest active session in ~/.gemini/antigravity/brain.
.PARAMETER CopyToClipboard
    If specified, triggers automatic generation and copies the handoff brief to the Windows Clipboard.
.PARAMETER ExportMarkdown
    Target markdown output file path for the Handoff Brief.
.EXAMPLE
    .\analyze-context.ps1
    .\analyze-context.ps1 -CopyToClipboard
#>

[CmdletBinding()]
param (
    [string]$TranscriptPath = "",
    [switch]$CopyToClipboard,
    [string]$ExportMarkdown = ""
)

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " [CHAT CONTEXT AUDITOR & BLOAT PROFILER] (Antigravity) " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Locate transcript if omitted
if (-not $TranscriptPath -or -not (Test-Path $TranscriptPath)) {
    $brainDir = "$env:USERPROFILE\.gemini\antigravity\brain"
    if (Test-Path $brainDir) {
        $latestLog = Get-ChildItem -Path $brainDir -Recurse -Filter "transcript.jsonl" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        
        if ($latestLog) {
            $TranscriptPath = $latestLog.FullName
            Write-Host "[*] Using latest detected transcript:" -ForegroundColor Green
            Write-Host "    $TranscriptPath" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Error "No transcript.jsonl found in $brainDir"
            exit 1
        }
    } else {
        Write-Error "Antigravity brain directory not found at $brainDir"
        exit 1
    }
}

if (-not (Test-Path $TranscriptPath)) {
    Write-Error "Transcript file not found: $TranscriptPath"
    exit 1
}

# 2. Parse & Analyze JSONL
$lines = Get-Content -Path $TranscriptPath -Encoding UTF8
$totalSteps = $lines.Count
$userTurns = 0
$modelTurns = 0
$toolCallsCount = @{}
$modifiedFiles = [System.Collections.Generic.HashSet[string]]::new()
$truncatedSteps = 0
$totalChars = 0

foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $totalChars += $line.Length
    try {
        $obj = $line | ConvertFrom-Json
        if ($obj.source -eq "USER_EXPLICIT") {
            $userTurns++
        } elseif ($obj.source -eq "MODEL") {
            $modelTurns++
        }

        if ($obj.truncated_fields -and $obj.truncated_fields.Count -gt 0) {
            $truncatedSteps++
        }

        if ($obj.tool_calls) {
            foreach ($tc in $obj.tool_calls) {
                $tName = $tc.name
                if (-not $toolCallsCount.ContainsKey($tName)) {
                    $toolCallsCount[$tName] = 0
                }
                $toolCallsCount[$tName]++

                if ($tName -in @("write_to_file", "replace_file_content") -and $tc.args) {
                    $target = $tc.args.TargetFile
                    if ($target) {
                        [void]$modifiedFiles.Add($target.Trim('"'))
                    }
                }
            }
        }
    } catch {
        # ignore malformed entries
    }
}

$estTokens = [math]::Round($totalChars / 3.8)

# 3. Display Metrics Summary
Write-Host "[METRICS] Session Context Summary:" -ForegroundColor Yellow
Write-Host ("   - Total JSONL Steps      : {0} lines" -f $totalSteps)
Write-Host ("   - User Explicit Turns    : {0} turns" -f $userTurns)
Write-Host ("   - Model Response Turns   : {0} responses" -f $modelTurns)
Write-Host ("   - Truncated Steps        : {0} steps (truncated)" -f $truncatedSteps)
Write-Host ("   - Estimated Payload Size : {0} KB" -f [math]::Round($totalChars / 1024, 1))
Write-Host ("   - Estimated Total Tokens : ~{0} tokens" -f $estTokens)
Write-Host ""

Write-Host "[TOOLS] Tool Execution Distribution:" -ForegroundColor Yellow
if ($toolCallsCount.Count -gt 0) {
    $toolCallsCount.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        $name = $_.Key
        $count = $_.Value
        Write-Host ("   - {0,-26} : {1} calls" -f $name, $count) -ForegroundColor White
    }
} else {
    Write-Host "   (No tool calls detected)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "[FILES] Files Mutated in Session ([NEW] / [MODIFY]):" -ForegroundColor Yellow
if ($modifiedFiles.Count -gt 0) {
    foreach ($f in $modifiedFiles) {
        Write-Host ("   [+] {0}" -f $f) -ForegroundColor Green
    }
} else {
    Write-Host "   (No file mutations recorded yet)" -ForegroundColor Gray
}
Write-Host ""

# 4. Live Workspace Git Status
$gitExe = Get-Command git -ErrorAction SilentlyContinue
if ($gitExe) {
    $isGit = git rev-parse --is-inside-work-tree 2>$null
    if ($isGit -eq "true") {
        $branch = git branch --show-current 2>$null
        $dirty = (git status --porcelain 2>$null).Count
        Write-Host "[GIT] Active Workspace Status:" -ForegroundColor Yellow
        Write-Host ("   - Active Branch          : {0}" -f $branch) -ForegroundColor White
        Write-Host ("   - Uncommitted Changes    : {0} files" -f $dirty) -ForegroundColor White
        Write-Host ""
    }
}

# 5. Compaction Strategy Recommendation
Write-Host "[RECOMMENDATION] Compaction Strategy:" -ForegroundColor Cyan
if ($estTokens -gt 60000 -or $totalSteps -gt 35) {
    Write-Host "   [!] WARNING: MASSIVE CONTEXT DETECTED (>60k tokens / >35 steps)!" -ForegroundColor Red
    Write-Host "   Recommended: Execute Mode 1 (Clean Session Handoff Blueprint)." -ForegroundColor Yellow
    Write-Host "   Start a fresh chat session and paste the distilled brief for 100% responsiveness."
} elseif ($estTokens -gt 25000 -or $totalSteps -gt 15) {
    Write-Host "   [!] WARNING: Context growth accelerating (>25k tokens / >15 steps)." -ForegroundColor Yellow
    Write-Host "   Recommended: Use Mode 2 (Inline Working Memory Ledger) to refresh attention focus."
} else {
    Write-Host "   [OK] Context volume is healthy (<25k tokens)." -ForegroundColor Green
    Write-Host "   Session can continue without urgent compaction."
}
Write-Host ""

# 6. Automatic Generator & Clipboard Execution
if ($ExportMarkdown -or $CopyToClipboard) {
    $compressorScript = Join-Path $PSScriptRoot "context_compressor.py"
    if (Test-Path $compressorScript) {
        Write-Host "[AUTOMATION] Executing Handoff Brief generator..." -ForegroundColor Cyan
        $pyArgs = @("`"$compressorScript`"", "--transcript", "`"$TranscriptPath`"")
        if ($ExportMarkdown) {
            $pyArgs += @("--output", "`"$ExportMarkdown`"")
        }
        if ($CopyToClipboard) {
            $pyArgs += "--clipboard"
        }
        
        $pyCmd = "python " + ($pyArgs -join " ")
        Invoke-Expression $pyCmd
    } else {
        Write-Warning "context_compressor.py script not found at $compressorScript"
    }
}
