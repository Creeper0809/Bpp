[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CompilerPath,
    [string]$NasmPath = "nasm.exe",
    [string]$LinkerPath = "link.exe",
    [int]$TimeoutMs = 5000,
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionDir = Resolve-Path (Join-Path $ScriptDir "..")
$RootDir = Resolve-Path (Join-Path $VersionDir "..")
$ConfigPath = Join-Path $VersionDir "config.ini"

function Get-IniValue {
    param([string]$Path, [string]$Key)
    $line = Get-Content $Path | Where-Object { $_ -match "^${Key}=" } | Select-Object -First 1
    if (-not $line) { return "" }
    return ($line -split "=", 2)[1].Trim()
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
        "/entry:_start",
        "/out:$OutputExe",
        $ObjectFile,
        "kernel32.lib"
    )

    & $Linker @args 2> $ErrorFile
    return $LASTEXITCODE
}

function Read-DirectiveValue {
    param(
        [string[]]$Lines,
        [string]$Pattern
    )

    foreach ($line in $Lines) {
        if ($line -match $Pattern) {
            return $matches[1].Trim()
        }
    }

    return ""
}

function Invoke-TestProcess {
    param(
        [string]$ExePath,
        [int]$Timeout
    )

    $proc = Start-Process -FilePath $ExePath -NoNewWindow -PassThru
    $exited = $proc.WaitForExit($Timeout)
    if (-not $exited) {
        try { $proc.Kill() } catch { }
        return 124
    }
    return $proc.ExitCode
}

if (-not (Test-Path $ConfigPath)) {
    throw "config.ini not found: $ConfigPath"
}

$Version = Get-IniValue -Path $ConfigPath -Key "VERSION"
if (-not $Version) {
    throw "VERSION is missing in config.ini"
}

if (-not (Test-Path $CompilerPath)) {
    throw "Compiler not found: $CompilerPath"
}
if (-not (Test-Path $NasmPath)) {
    $resolvedNasm = Get-Command $NasmPath -ErrorAction SilentlyContinue
    if (-not $resolvedNasm) { throw "NASM not found: $NasmPath" }
    $NasmPath = $resolvedNasm.Source
}
if (-not (Test-Path $LinkerPath)) {
    $resolvedLinker = Get-Command $LinkerPath -ErrorAction SilentlyContinue
    if (-not $resolvedLinker) { throw "Linker not found: $LinkerPath" }
    $LinkerPath = $resolvedLinker.Source
}

$BuildDir = Join-Path $RootDir "build\${Version}_tests_win"
$ResultDir = Join-Path $RootDir "build\test_results_win"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $ResultDir | Out-Null

$TestDir = Join-Path $VersionDir "test\source"
$testFiles = Get-ChildItem -Path $TestDir -Filter "*.bpp" |
    Where-Object { $_.BaseName -match '^[0-9]+_' } |
    Sort-Object Name

if (-not $testFiles) {
    throw "No test files found: $TestDir"
}

$total = 0
$passed = 0
$failed = 0

Write-Host "========================================"
Write-Host "$Version Windows Test Suite"
Write-Host "========================================"
Write-Host "[INFO] Compiler: $CompilerPath"
Write-Host "[INFO] NASM    : $NasmPath"
Write-Host "[INFO] Linker  : $LinkerPath"
Write-Host ""

foreach ($testFile in $testFiles) {
    $total += 1
    $name = $testFile.BaseName
    $lines = Get-Content $testFile.FullName

    $expectedExitRaw = Read-DirectiveValue -Lines $lines -Pattern '^//\s*Expect exit code:\s*(.+)$'
    $expectedExit = 0
    if ($expectedExitRaw) { [void][int]::TryParse($expectedExitRaw, [ref]$expectedExit) }

    $expectCompileFailRaw = (Read-DirectiveValue -Lines $lines -Pattern '^//\s*Expect compile fail:\s*(.+)$').ToLowerInvariant()
    $expectCompileFail = ($expectCompileFailRaw -eq "1" -or $expectCompileFailRaw -eq "true" -or $expectCompileFailRaw -eq "yes")
    $expectErrContains = Read-DirectiveValue -Lines $lines -Pattern '^//\s*Expect error contains:\s*(.+)$'

    $asmFile = Join-Path $BuildDir "${name}.asm"
    $objFile = Join-Path $BuildDir "${name}.obj"
    $exeFile = Join-Path $BuildDir "${name}.exe"
    $errFile = Join-Path $ResultDir "${name}.err"

    if (Test-Path $asmFile) { Remove-Item $asmFile -Force }
    if (Test-Path $objFile) { Remove-Item $objFile -Force }
    if (Test-Path $exeFile) { Remove-Item $exeFile -Force }
    if (Test-Path $errFile) { Remove-Item $errFile -Force }

    & $CompilerPath -asm $testFile.FullName > $asmFile 2> $errFile
    $compileCode = $LASTEXITCODE

    $caseOk = $true
    $status = "PASS"

    if ($compileCode -ne 0) {
        if ($expectCompileFail) {
            if ($expectErrContains) {
                $errText = Get-Content $errFile -Raw
                if ($errText -notlike "*$expectErrContains*") {
                    $caseOk = $false
                    $status = "FAIL (compile error mismatch)"
                } else {
                    $status = "PASS (expected compile fail)"
                }
            } else {
                $status = "PASS (expected compile fail)"
            }
        } else {
            $caseOk = $false
            $status = "FAIL (compile)"
        }
    } else {
        if ($expectCompileFail) {
            $caseOk = $false
            $status = "FAIL (unexpected compile success)"
        } else {
            & $NasmPath -f win64 -O1 $asmFile -o $objFile 2> $errFile
            if ($LASTEXITCODE -ne 0) {
                $caseOk = $false
                $status = "FAIL (assemble)"
            } else {
                $linkCode = Invoke-Link -Linker $LinkerPath -ObjectFile $objFile -OutputExe $exeFile -ErrorFile $errFile
                if ($linkCode -ne 0) {
                    $caseOk = $false
                    $status = "FAIL (link)"
                } else {
                    $runExit = Invoke-TestProcess -ExePath $exeFile -Timeout $TimeoutMs
                    if ($runExit -ne $expectedExit) {
                        $caseOk = $false
                        $status = "FAIL (exit=$runExit expect=$expectedExit)"
                    }
                }
            }
        }
    }

    if ($caseOk) {
        $passed += 1
        if (-not $Quiet) {
            Write-Host "[PASS] $name - $status"
        }
    } else {
        $failed += 1
        Write-Host "[FAIL] $name - $status"
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "Windows Test Results"
Write-Host "========================================"
Write-Host "Total:  $total"
Write-Host "Passed: $passed"
Write-Host "Failed: $failed"

if ($failed -ne 0) {
    exit 1
}

Write-Host "All tests passed."
exit 0
