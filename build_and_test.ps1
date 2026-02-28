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
$RootDir = Resolve-Path $ScriptDir
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

function Get-OptionalConfigValue {
    param([string]$Path, [string]$Key)
    if (-not (Test-Path $Path)) { return "" }
    return Get-IniValue -Path $Path -Key $Key
}

function Get-VersionFromCompilerPath {
    param([string]$Path)
    if (-not $Path) { return "" }
    $base = [System.IO.Path]::GetFileName($Path)
    if ($base -match '^(.*)_stage1(\.exe)?$') {
        if ($matches[1]) { return $matches[1] }
    }
    return ""
}

function Find-DefaultCompiler {
    param(
        [string]$Root,
        [string]$VersionHint
    )

    if ($env:BPP_COMPILER -and (Test-Path $env:BPP_COMPILER)) {
        return (Resolve-Path $env:BPP_COMPILER).Path
    }

    $candidates = New-Object System.Collections.Generic.List[string]
    if ($VersionHint) {
        $candidates.Add((Join-Path $Root "bin\${VersionHint}_stage1.exe"))
        $candidates.Add((Join-Path $Root "bin\${VersionHint}_stage1"))
        $candidates.Add((Join-Path $Root "bin\${VersionHint}_base.exe"))
    }
    $candidates.Add((Join-Path $Root "bin\bootstrap.exe"))
    $candidates.Add((Join-Path $Root "bin\bootstrap"))
    $candidates.Add((Join-Path $Root "bin\stage1.exe"))
    $candidates.Add((Join-Path $Root "bin\stage1"))

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    $glob = Get-ChildItem -Path (Join-Path $Root "bin") -Filter "*_stage1*" -File -ErrorAction SilentlyContinue |
        Sort-Object Name
    if ($glob) {
        return $glob[-1].FullName
    }

    return ""
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

$ConfigVersion = Get-OptionalConfigValue -Path $ConfigPath -Key "VERSION"
$VersionHint = if ($env:BPP_VERSION) { $env:BPP_VERSION } elseif ($ConfigVersion) { $ConfigVersion } else { "" }

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

if (-not $CompilerPath) {
    $CompilerPath = Find-DefaultCompiler -Root $RootDir -VersionHint $VersionHint
}

$Version = Get-VersionFromCompilerPath -Path $CompilerPath
if (-not $Version) {
    if ($VersionHint) {
        $Version = $VersionHint
    } else {
        $Version = "bpp"
    }
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

if (-not (Test-Path $CompilerPath)) {
    $fallbackFound = Find-DefaultCompiler -Root $RootDir -VersionHint $VersionHint
    if ($fallbackFound) {
        $CompilerPath = $fallbackFound
    } else {
        throw @"
Windows hosted compiler binary was not found.
Tried: BPP_COMPILER, bin/\${BPP_VERSION}_stage1(.exe), bin/bootstrap(.exe), bin/stage1(.exe), bin/*_stage1*

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
