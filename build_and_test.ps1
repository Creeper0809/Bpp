[CmdletBinding()]
param(
    [string]$CompilerPath = "",
    [string]$NasmPath = "",
    [string]$LinkerPath = "",
    [string]$BootstrapRepository = "Creeper0809/Bpp",
    [string]$BootstrapBaseUrl = "https://github.com",
    [string]$BootstrapReleaseTag = "",
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

function Get-BootstrapReleaseTag {
    param(
        [string]$Version,
        [string]$ExplicitTag
    )

    if ($ExplicitTag) { return $ExplicitTag }
    if ($Version) { return "bootstrap-$Version" }
    return "bootstrap-bpp"
}

function Get-WindowsBootstrapAssetName {
    param([string]$Version)
    if (-not $Version) { $Version = "bpp" }
    return "bpp-bootstrap-${Version}-windows-x86_64.exe"
}

function Download-BootstrapCompiler {
    param(
        [string]$Root,
        [string]$Version,
        [string]$Repository,
        [string]$BaseUrl,
        [string]$ReleaseTag
    )

    $assetName = Get-WindowsBootstrapAssetName -Version $Version
    $resolvedTag = Get-BootstrapReleaseTag -Version $Version -ExplicitTag $ReleaseTag
    $downloadUrl = "$BaseUrl/$Repository/releases/download/$resolvedTag/$assetName"
    $toolsDir = Join-Path $Root "build-win\_tools"
    $downloadPath = Join-Path $toolsDir $assetName

    New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

    if (Test-Path $downloadPath) {
        return (Resolve-Path $downloadPath).Path
    }

    Write-Host "[INFO] Downloading Windows bootstrap compiler: $downloadUrl"
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing
    } catch {
        if (Test-Path $downloadPath) {
            Remove-Item -Force $downloadPath -ErrorAction SilentlyContinue
        }
        return ""
    }

    if (Test-Path $downloadPath) {
        return (Resolve-Path $downloadPath).Path
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

function Invoke-Link {
    param(
        [string]$Linker,
        [string]$ObjectFile,
        [string]$OutputExe,
        [string]$ErrorFile
    )

    $args = @(
        "/nologo",
        "/subsystem:console",
        "/entry:mainCRTStartup",
        "/out:$OutputExe",
        $ObjectFile,
        "kernel32.lib"
    )

    & $Linker @args 2> $ErrorFile
    return $LASTEXITCODE
}

function Invoke-CompileToAsm {
    param(
        [string]$Compiler,
        [string]$SourceFile,
        [string]$AsmFile,
        [string]$ErrorFile
    )

    if (Test-Path $AsmFile) { Remove-Item $AsmFile -Force }
    if (Test-Path $ErrorFile) { Remove-Item $ErrorFile -Force }

    & $Compiler --target windows-x86_64 -asm $SourceFile > $AsmFile 2> $ErrorFile
    return $LASTEXITCODE
}

function Invoke-StageBuild {
    param(
        [string]$Compiler,
        [string]$SourceFile,
        [string]$StageName,
        [string]$BuildDir,
        [string]$BinDir,
        [string]$Nasm,
        [string]$Linker
    )

    $asmFile = Join-Path $BuildDir "${StageName}.asm"
    $objFile = Join-Path $BuildDir "${StageName}.obj"
    $exeFile = Join-Path $BinDir "${StageName}.exe"
    $errFile = Join-Path $BuildDir "${StageName}.err"

    Write-Host "[INFO] Building ${StageName}.exe with $Compiler"
    $compileCode = Invoke-CompileToAsm -Compiler $Compiler -SourceFile $SourceFile -AsmFile $asmFile -ErrorFile $errFile
    if ($compileCode -ne 0) {
        $errText = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { "" }
        throw "Compiler failed while building ${StageName}.asm (exit=$compileCode)`n$errText"
    }

    & $Nasm -f win64 -O1 $asmFile -o $objFile 2> $errFile
    if ($LASTEXITCODE -ne 0) {
        $errText = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { "" }
        throw "NASM failed while building ${StageName}.obj`n$errText"
    }

    $linkCode = Invoke-Link -Linker $Linker -ObjectFile $objFile -OutputExe $exeFile -ErrorFile $errFile
    if ($linkCode -ne 0) {
        $errText = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { "" }
        throw "Linker failed while building ${StageName}.exe`n$errText"
    }

    return $exeFile
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
        $downloadedCompiler = Download-BootstrapCompiler `
            -Root $RootDir `
            -Version $Version `
            -Repository $BootstrapRepository `
            -BaseUrl $BootstrapBaseUrl `
            -ReleaseTag $BootstrapReleaseTag
        if ($downloadedCompiler) {
            $CompilerPath = $downloadedCompiler
        } else {
            throw @"
Windows hosted compiler binary was not found.
Tried: BPP_COMPILER, bin/\${BPP_VERSION}_stage1(.exe), bin/bootstrap(.exe), bin/stage1(.exe), bin/*_stage1*

Attempted bootstrap asset download:
  Repository : $BootstrapRepository
  Release tag: $(Get-BootstrapReleaseTag -Version $Version -ExplicitTag $BootstrapReleaseTag)
  Asset      : $(Get-WindowsBootstrapAssetName -Version $Version)

Current repository contains Linux stage binaries only.
Provide or publish a Windows stage compiler binary first, then rerun this script.
"@
        }
    }
}

Write-Host "[INFO] Compiler: $CompilerPath"

$SourceFile = Join-Path $ScriptDir "src\main.bpp"
if (-not (Test-Path $SourceFile)) {
    throw "Compiler source not found: $SourceFile"
}

$BuildDir = Join-Path $RootDir "build\${Version}_selfhost_win"
$BinDir = Join-Path $RootDir "bin"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

$Stage0Name = "${Version}_stage0"
$Stage1Name = "${Version}_stage1"

Write-Host "[INFO] Building Windows hosted compiler stages"
$Stage0Compiler = Invoke-StageBuild `
    -Compiler $CompilerPath `
    -SourceFile $SourceFile `
    -StageName $Stage0Name `
    -BuildDir $BuildDir `
    -BinDir $BinDir `
    -Nasm $ResolvedNasm `
    -Linker $ResolvedLinker

$Stage1Compiler = Invoke-StageBuild `
    -Compiler $Stage0Compiler `
    -SourceFile $SourceFile `
    -StageName $Stage1Name `
    -BuildDir $BuildDir `
    -BinDir $BinDir `
    -Nasm $ResolvedNasm `
    -Linker $ResolvedLinker

Copy-Item -Force $Stage1Compiler (Join-Path $BinDir "stage1.exe")
Write-Host "[INFO] Stage1: $Stage1Compiler"

if ($SkipTests) {
    Write-Host "[INFO] SkipTests requested."
    exit 0
}

$TestRunner = Join-Path $ScriptDir "test\run_tests.ps1"
if (-not (Test-Path $TestRunner)) {
    throw "Windows test runner not found: $TestRunner"
}

& $TestRunner -CompilerPath $Stage1Compiler -NasmPath $ResolvedNasm -LinkerPath $ResolvedLinker
exit $LASTEXITCODE
