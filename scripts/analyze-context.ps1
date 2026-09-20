<#
.SYNOPSIS
    Audit & Analyzer untuk Transkrip Sesi Chat Antigravity.
.DESCRIPTION
    Membaca transcript.jsonl sesi aktif atau sesi tertentu untuk mendeteksi
    token bloat, distribusi tool calls, mutasi berkas, dan menyarankan strategi
    compacting konteks yang optimal tanpa kehilangan state.
.PARAMETER TranscriptPath
    Path absolut ke file transcript.jsonl. Jika kosong, akan mencari sesi aktif terbaru di .gemini/antigravity/brain.
.PARAMETER CopyToClipboard
    Jika diaktifkan, hasil handoff brief terkompresi akan disalin langsung ke clipboard Windows.
.PARAMETER ExportMarkdown
    Path berkas tujuan untuk mengekspor Markdown Handoff Brief (misal: session_handoff.md).
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

# 1. Cari file transcript jika tidak ditentukan
if (-not $TranscriptPath -or -not (Test-Path $TranscriptPath)) {
    $brainDir = "$env:USERPROFILE\.gemini\antigravity\brain"
    if (Test-Path $brainDir) {
        $latestLog = Get-ChildItem -Path $brainDir -Recurse -Filter "transcript.jsonl" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        
        if ($latestLog) {
            $TranscriptPath = $latestLog.FullName
            Write-Host "[*] Menggunakan transkrip sesi terbaru yang terdeteksi:" -ForegroundColor Green
            Write-Host "    $TranscriptPath" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Error "Tidak ditemukan file transcript.jsonl di $brainDir"
            exit 1
        }
    } else {
        Write-Error "Direktori brain Antigravity tidak ditemukan di $brainDir"
        exit 1
    }
}

if (-not (Test-Path $TranscriptPath)) {
    Write-Error "File transkrip tidak ditemukan: $TranscriptPath"
    exit 1
}

# 2. Parsing dan Analisis JSONL
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
        # abaikan baris rusak
    }
}

$estTokens = [math]::Round($totalChars / 3.8)

# 3. Tampilkan Ringkasan Metrik
Write-Host "[METRICS] Ringkasan Metrik Konteks Sesi:" -ForegroundColor Yellow
Write-Host ("   - Total JSONL Steps      : {0} baris" -f $totalSteps)
Write-Host ("   - User Explicit Turns    : {0} giliran" -f $userTurns)
Write-Host ("   - Model Response Turns   : {0} respon" -f $modelTurns)
Write-Host ("   - Langkah Terpotong      : {0} steps (truncated)" -f $truncatedSteps)
Write-Host ("   - Estimasi Ukuran Teks   : {0} KB" -f [math]::Round($totalChars / 1024, 1))
Write-Host ("   - Estimasi Total Token   : ~{0} token" -f $estTokens)
Write-Host ""

Write-Host "[TOOLS] Distribusi Pemanggilan Tools:" -ForegroundColor Yellow
if ($toolCallsCount.Count -gt 0) {
    $toolCallsCount.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        $name = $_.Key
        $count = $_.Value
        Write-Host ("   - {0,-26} : {1} kali" -f $name, $count) -ForegroundColor White
    }
} else {
    Write-Host "   (Tidak ada pemanggilan tool yang terdeteksi)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "[FILES] Berkas yang Termutasi dalam Sesi ([NEW] / [MODIFY]):" -ForegroundColor Yellow
if ($modifiedFiles.Count -gt 0) {
    foreach ($f in $modifiedFiles) {
        Write-Host ("   [+] {0}" -f $f) -ForegroundColor Green
    }
} else {
    Write-Host "   (Belum ada modifikasi berkas tercatat)" -ForegroundColor Gray
}
Write-Host ""

# 4. Status Git Real-Time (jika ada)
$gitExe = Get-Command git -ErrorAction SilentlyContinue
if ($gitExe) {
    $isGit = git rev-parse --is-inside-work-tree 2>$null
    if ($isGit -eq "true") {
        $branch = git branch --show-current 2>$null
        $dirty = (git status --porcelain 2>$null).Count
        Write-Host "[GIT] Status Workspace Aktif:" -ForegroundColor Yellow
        Write-Host ("   - Branch Aktif           : {0}" -f $branch) -ForegroundColor White
        Write-Host ("   - Berkas Berubah di Disk : {0} berkas" -f $dirty) -ForegroundColor White
        Write-Host ""
    }
}

# 5. Rekomendasi Strategi Compacting
Write-Host "[RECOMMENDATION] Strategi Compacting:" -ForegroundColor Cyan
if ($estTokens -gt 60000 -or $totalSteps -gt 35) {
    Write-Host "   [!] PERINGATAN: KONTEKS SANGAT BESAR (>60k token / >35 steps)!" -ForegroundColor Red
    Write-Host "   Rekomendasi: Eksekusi Mode 1 (Clean Session Handoff Blueprint)." -ForegroundColor Yellow
    Write-Host "   Buka sesi chat baru dan tempelkan Handoff Brief lengkap agar agen kembali responsif 100%."
} elseif ($estTokens -gt 25000 -or $totalSteps -gt 15) {
    Write-Host "   [!] PERINGATAN: Konteks mulai membengkak (>25k token / >15 steps)." -ForegroundColor Yellow
    Write-Host "   Rekomendasi: Gunakan Mode 2 (Inline Working Memory Ledger) untuk menyegarkan fokus agen."
} else {
    Write-Host "   [OK] Konteks masih tergolong sehat (<25k token)." -ForegroundColor Green
    Write-Host "   Sesi masih aman dijalankan tanpa perlu pemadatan drastis."
}
Write-Host ""

# 6. Eksekusi Ekspor & Clipboard jika diminta
if ($ExportMarkdown -or $CopyToClipboard) {
    $compressorScript = Join-Path $PSScriptRoot "context_compressor.py"
    if (Test-Path $compressorScript) {
        Write-Host "[AUTOMATION] Menjalankan generator Handoff Brief..." -ForegroundColor Cyan
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
        Write-Warning "Skrip context_compressor.py tidak ditemukan di $compressorScript"
    }
}
