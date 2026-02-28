[CmdletBinding()]
param(
    [string]$CompilerPath = "",
    [string]$NasmPath = "",
    [string]$LinkerPath = "",
    [switch]$ToolchainOnly,
    [switch]$SkipTests
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Resolve-Path (Join-Path $ScriptDir "..")
$ConfigPath = Join-Path $ScriptDir "config.ini"

function Get-IniValue {
    param(
        [string]$Path,
        [string]$Key
    )

    $line = Get-Content $Path | Where-Object { $_ -match "^${Key}=" } | Select-Object -First 1
    if (-not $line) { return "" }
    return ($line -split "=", 2)[1].Trim()
}

function Resolve-Tool {
    param(
        [string]$ExplicitPath,
        [string[]]$Candidates,
        [string]$Description
    )

    if ($ExplicitPath) {
        if (Test-Path $ExplicitPath) { return (Resolve-Path $ExplicitPath).Path }
        throw "$Description not found at explicit path: $ExplicitPath"
    }

    foreach ($candidate in $Candidates) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }

    throw "$Description not found."
}

if (-not (Test-Path $ConfigPath)) {
    throw "config.ini not found: $ConfigPath"
}

$Version = Get-IniValue -Path $ConfigPath -Key "VERSION"
$PrevVersion = Get-IniValue -Path $ConfigPath -Key "PREV_VERSION"
if (-not $Version) {
    throw "VERSION is missing in config.ini"
}

if (-not $NasmPath -and $env:BPP_NASM_EXECUTABLE) {
    $NasmPath = $env:BPP_NASM_EXECUTABLE
}
if (-not $LinkerPath -and $env:BPP_LINKER_EXECUTABLE) {
    $LinkerPath = $env:BPP_LINKER_EXECUTABLE
}

try {
    $ResolvedNasm = Resolve-Tool -ExplicitPath $NasmPath -Candidates @("nasm.exe", "nasm") -Description "NASM"
} catch {
    throw "NASM not found. Re-run CMake with -DBPP_BOOTSTRAP_NASM=ON or install from https://www.nasm.us/pub/nasm/releasebuilds/"
}

$linkCandidates = @("link.exe", "lld-link.exe", "lld-link")
try {
    $ResolvedLinker = Resolve-Tool -ExplicitPath $LinkerPath -Candidates $linkCandidates -Description "Windows linker"
} catch {
    throw "No Windows linker found. Install Visual Studio Build Tools (https://aka.ms/vs/17/release/vs_BuildTools.exe) or LLVM lld-link (https://releases.llvm.org/)"
}

Write-Host "========================================="
Write-Host "$Version Windows Build & Test"
Write-Host "========================================="
Write-Host "[INFO] NASM   : $ResolvedNasm"
Write-Host "[INFO] Linker : $ResolvedLinker"

if ($ToolchainOnly) {
    Write-Host "[INFO] Toolchain-only mode complete."
    exit 0
}

if (-not $CompilerPath) {
    $CompilerPath = Join-Path $RootDir "bin\${Version}_stage1.exe"
}

if (-not (Test-Path $CompilerPath)) {
    $fallbackCandidates = @(
        (Join-Path $RootDir "bin\${Version}_base.exe"),
        (Join-Path $RootDir "bin\${PrevVersion}_stage1.exe"),
        (Join-Path $RootDir "bin\${PrevVersion}.exe")
    )

    $fallbackFound = $fallbackCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($fallbackFound) {
        $CompilerPath = $fallbackFound
    } else {
        throw @"
Windows hosted compiler binary was not found.
Expected: $(Join-Path $RootDir "bin\${Version}_stage1.exe")
Fallback: $(($fallbackCandidates -join ", "))

Current repository contains Linux stage binaries only.
Provide a Windows stage compiler binary first, then rerun this script.
"@
    }
}

Write-Host "[INFO] Compiler: $CompilerPath"

if ($SkipTests) {
    Write-Host "[INFO] SkipTests requested."
    exit 0
}

$TestRunner = Join-Path $ScriptDir "test\run_tests.ps1"
if (-not (Test-Path $TestRunner)) {
    throw "Windows test runner not found: $TestRunner"
}

& $TestRunner -CompilerPath $CompilerPath -NasmPath $ResolvedNasm -LinkerPath $ResolvedLinker
exit $LASTEXITCODE
