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

function Get-SanitizedCaseName {
    param([string]$Name)

    $safe = $Name -replace '[^A-Za-z0-9_.-]+', '_'
    $safe = $safe.Trim('_')
    if (-not $safe) { $safe = "case" }
    return $safe
}

function Expand-SuiteCases {
    param(
        [System.IO.FileInfo]$SuiteFile,
        [string]$OutputRoot
    )

    $suiteBase = $SuiteFile.BaseName
    $suiteOutDir = Join-Path $OutputRoot $suiteBase
    New-Item -ItemType Directory -Force -Path $suiteOutDir | Out-Null
    Get-ChildItem -Path $suiteOutDir -Filter "*.bpp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    $lines = Get-Content $SuiteFile.FullName
    $cases = @()

    $inCase = $false
    $caseLines = New-Object System.Collections.Generic.List[string]
    $rawCaseName = ""
    $caseIndex = 0

    foreach ($line in $lines) {
        if ($line -match '^//=== CASE\s+(.+)$') {
            if ($inCase) {
                throw "Suite parse error: nested //=== CASE in $($SuiteFile.FullName)"
            }
            $inCase = $true
            $rawCaseName = $matches[1].Trim()
            $caseLines.Clear()
            continue
        }

        if ($line -match '^//=== END\s*$') {
            if (-not $inCase) {
                throw "Suite parse error: orphan //=== END in $($SuiteFile.FullName)"
            }

            $caseIndex += 1
            $safeCaseName = Get-SanitizedCaseName -Name $rawCaseName
            $caseFileName = "{0}__{1:D3}_{2}.bpp" -f $suiteBase, $caseIndex, $safeCaseName
            $casePath = Join-Path $suiteOutDir $caseFileName
            Set-Content -Path $casePath -Value $caseLines -Encoding UTF8
            $cases += [PSCustomObject]@{
                Path = $casePath
                Name = "$suiteBase::$rawCaseName"
            }

            $inCase = $false
            $rawCaseName = ""
            $caseLines.Clear()
            continue
        }

        if ($inCase) {
            $caseLines.Add($line)
        }
    }

    if ($inCase) {
        throw "Suite parse error: missing //=== END in $($SuiteFile.FullName)"
    }
    if ($caseIndex -eq 0) {
        throw "Suite parse error: no //=== CASE blocks in $($SuiteFile.FullName)"
    }

    return $cases
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
$sourceFiles = Get-ChildItem -Path $TestDir -Filter "*.bpp" |
    Where-Object { $_.BaseName -match '^[0-9]+_' } |
    Sort-Object Name

if (-not $sourceFiles) {
    throw "No test files found: $TestDir"
}

$suiteOutputRoot = Join-Path $BuildDir "suite_cases"
New-Item -ItemType Directory -Force -Path $suiteOutputRoot | Out-Null

$testCases = @()
foreach ($sourceFile in $sourceFiles) {
    $sourceLines = Get-Content $sourceFile.FullName
    if ($sourceLines | Where-Object { $_ -match '^//=== CASE\s+' } | Select-Object -First 1) {
        $expanded = Expand-SuiteCases -SuiteFile $sourceFile -OutputRoot $suiteOutputRoot
        $testCases += $expanded
    } else {
        $testCases += [PSCustomObject]@{
            Path = $sourceFile.FullName
            Name = $sourceFile.BaseName
        }
    }
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

foreach ($testCase in $testCases) {
    $total += 1
    $name = [System.IO.Path]::GetFileNameWithoutExtension($testCase.Path)
    $displayName = $testCase.Name
    $lines = Get-Content $testCase.Path

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

    & $CompilerPath -asm $testCase.Path > $asmFile 2> $errFile
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
            Write-Host "[PASS] $displayName - $status"
        }
    } else {
        $failed += 1
        Write-Host "[FAIL] $displayName - $status"
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
