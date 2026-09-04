[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$TimingJsonPath,
    [string]$Title = "Windows verification timing"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TimingJsonPath)) { exit 0 }
$summaryPath = $env:GITHUB_STEP_SUMMARY
if (-not $summaryPath) { exit 0 }

$timing = Get-Content -LiteralPath $TimingJsonPath -Raw | ConvertFrom-Json
"## $Title" | Out-File $summaryPath -Append
"" | Out-File $summaryPath -Append
"| Cases | Passed | Failed | Jobs | Elapsed |" | Out-File $summaryPath -Append
"|---:|---:|---:|---:|---:|" | Out-File $summaryPath -Append
"| $($timing.total) | $($timing.passed) | $($timing.failed) | $($timing.jobs) | $([Math]::Round($timing.elapsedMs / 60000, 2)) min |" | Out-File $summaryPath -Append

$compilerTimingDir = "$TimingJsonPath.compiler"
$compilerFiles = @(Get-ChildItem -LiteralPath $compilerTimingDir -Filter "*.json" -File -ErrorAction SilentlyContinue)
if ($compilerFiles.Count -gt 0) {
    $phaseNames = @(
        "preprocessMs", "parseMs", "loweringMs", "ssaGenerationMs",
        "optimizationMs", "regallocMs", "validationMs", "codegenMs"
    )
    $phaseTotals = @{}
    foreach ($phase in $phaseNames) { $phaseTotals[$phase] = [double]0 }
    foreach ($file in $compilerFiles) {
        $compilerTiming = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        foreach ($phase in $phaseNames) {
            $value = $compilerTiming.phases.$phase
            if ($null -ne $value) { $phaseTotals[$phase] += [double]$value }
        }
    }

    "" | Out-File $summaryPath -Append
    "Compiler phase totals across $($compilerFiles.Count) cases:" | Out-File $summaryPath -Append
    "" | Out-File $summaryPath -Append
    "| Phase | Total |" | Out-File $summaryPath -Append
    "|---|---:|" | Out-File $summaryPath -Append
    foreach ($phase in $phaseNames) {
        "| $phase | $([Math]::Round($phaseTotals[$phase] / 1000, 2)) s |" | Out-File $summaryPath -Append
    }
}

$slowest = @($timing.cases | Sort-Object { [double]$_.timing.totalMs } -Descending | Select-Object -First 10)
if ($slowest.Count -gt 0) {
    "" | Out-File $summaryPath -Append
    "Slowest cases:" | Out-File $summaryPath -Append
    "" | Out-File $summaryPath -Append
    "| Case | Total | Compile | Peak working set |" | Out-File $summaryPath -Append
    "|---|---:|---:|---:|" | Out-File $summaryPath -Append
    foreach ($case in $slowest) {
        $compileMs = if ($null -ne $case.timing.compile) { [double]$case.timing.compile.wallMs } else { 0 }
        $peakBytes = if ($null -ne $case.timing.compile) { [double]$case.timing.compile.peakWorkingSetBytes } else { 0 }
        "| $($case.id) | $([Math]::Round([double]$case.timing.totalMs / 1000, 2)) s | $([Math]::Round($compileMs / 1000, 2)) s | $([Math]::Round($peakBytes / 1MB, 1)) MiB |" | Out-File $summaryPath -Append
    }
}
