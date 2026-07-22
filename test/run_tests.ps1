[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CompilerPath,
    [string]$NasmPath = "nasm.exe",
    [string]$LinkerPath = "link.exe",
    [int]$TimeoutMs = 5000,
    [int]$CompilerTimeoutMs = 600000,
    [UInt64]$MemoryLimitBytes = 4294967296,
    [string]$NameFilter = "",
    [string]$ModeFilter = "",
    [string]$OptFilter = "",
    [bool]$StrictFailDiagnostics = $true,
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Resolve-Path (Join-Path $ScriptDir "..")
$ProcessHelper = Join-Path $RootDir "tools\windows_process.ps1"
if (-not (Test-Path -LiteralPath $ProcessHelper)) {
    throw "Windows process helper not found: $ProcessHelper"
}
. $ProcessHelper

function Get-VersionFromCompilerPath {
    param([string]$Path)
    if (-not $Path) { return "" }
    $base = [System.IO.Path]::GetFileName($Path)
    if ($base -match '^(.*)_stage1(\.exe)?$') {
        if ($matches[1]) { return $matches[1] }
    }
    return ""
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
        "/Brepro",
        "/subsystem:console",
        "/entry:mainCRTStartup",
        "/out:$OutputExe",
        $ObjectFile,
        "kernel32.lib"
    )

    $result = Invoke-BppLimitedProcess `
        -FilePath $Linker `
        -ArgumentList $args `
        -TimeoutMs $CompilerTimeoutMs `
        -StderrPath $ErrorFile `
        -WorkingDirectory $RootDir `
        -MemoryLimitBytes $MemoryLimitBytes
    return $result.ExitCode
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

function Read-DirectiveValues {
    param(
        [string[]]$Lines,
        [string]$Pattern
    )

    $values = New-Object System.Collections.Generic.List[string]
    foreach ($line in $Lines) {
        if ($line -match $Pattern) {
            $value = $matches[1].Trim()
            if ($value) {
                $values.Add($value)
            }
        }
    }

    return $values.ToArray()
}

function Get-BooleanDirectiveValue {
    param(
        [string[]]$Lines,
        [string]$Pattern
    )

    $raw = (Read-DirectiveValue -Lines $Lines -Pattern $Pattern).ToLowerInvariant()
    return ($raw -eq "1" -or $raw -eq "true" -or $raw -eq "yes")
}

function Split-CompilerArgs {
    param([string]$Raw)

    if (-not $Raw) { return @() }
    $parts = $Raw -split '\s+'
    return @($parts | Where-Object { $_ -ne "" })
}

function Get-NormalizedModes {
    param([string]$Raw)

    if (-not $Raw) { return @("nossa", "ssa") }
    $normalized = $Raw.ToLowerInvariant() -replace '\s+', '' -replace '\|', ','
    if ($normalized -eq "all" -or $normalized -eq "both") {
        return @("nossa", "ssa")
    }

    $selected = @()
    foreach ($mode in @("nossa", "ssa")) {
        if (@($normalized -split ',') -contains $mode) {
            $selected += $mode
        }
    }
    if ($selected.Count -eq 0) { return @("nossa", "ssa") }
    return $selected
}

function Get-NormalizedOpts {
    param([string]$Raw)

    if (-not $Raw) { return @("O0", "O1") }
    $normalized = $Raw.ToUpperInvariant() -replace '\s+', '' -replace '\|', ','
    if ($normalized -eq "ALL") {
        return @("O0", "O1", "O2", "O3", "OS")
    }
    if ($normalized -eq "BOTH") {
        return @("O0", "O1")
    }

    $selected = @()
    foreach ($opt in @("O0", "O1", "O2", "O3", "OS")) {
        if (@($normalized -split ',') -contains $opt) {
            $selected += $opt
        }
    }
    if ($selected.Count -eq 0) { return @("O0", "O1") }
    return $selected
}

function Decode-EscapedDirectiveText {
    param([string]$Raw)

    if (-not $Raw) { return "" }
    return [System.Text.RegularExpressions.Regex]::Unescape($Raw)
}

function Invoke-TestProcess {
    param(
        [string]$ExePath,
        [int]$Timeout,
        [string]$StdinText = ""
    )

    return Invoke-BppLimitedProcess `
        -FilePath $ExePath `
        -TimeoutMs $Timeout `
        -StdinText $StdinText `
        -WorkingDirectory $RootDir `
        -MemoryLimitBytes $MemoryLimitBytes
}

function Test-IsCrashExitCode {
    param([int]$ExitCode)

    # Windows crash exits are typically negative NTSTATUS values
    # (e.g. 0xC0000005 -> -1073741819). Keep POSIX 128+ handling too.
    if ($ExitCode -lt 0) { return $true }
    if ($ExitCode -ge 128) { return $true }
    return $false
}

function Convert-ToPortableTestExitCode {
    param([int]$ExitCode)

    # Match the Linux runner's conventional 128 + signal result for the
    # deliberate UD2 trap used by checked casts. Windows reports the same
    # processor exception as STATUS_ILLEGAL_INSTRUCTION (0xC000001D).
    if ($ExitCode -eq -1073741795) { return 132 }
    return $ExitCode
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
            [System.IO.File]::WriteAllLines(
                $casePath,
                [string[]]$caseLines.ToArray(),
                (New-Object System.Text.UTF8Encoding($false))
            )
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

$Version = Get-VersionFromCompilerPath -Path $CompilerPath
if (-not $Version) {
    if ($env:BPP_VERSION) {
        $Version = $env:BPP_VERSION
    } else {
        $Version = "bpp"
    }
}

$BuildDir = Join-Path $RootDir "build\${Version}_tests_win"
$ResultDir = Join-Path $RootDir "build\test_results_win"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $ResultDir | Out-Null

$TestDirs = @(
    (Join-Path $RootDir "test\source"),
    (Join-Path $RootDir "test\source_fail")
)
$sourceFiles = @($TestDirs | ForEach-Object {
    Get-ChildItem -Path $_ -Filter "*.bpp" |
        Where-Object { $_.BaseName -match '^[0-9]+_' }
}) | Sort-Object FullName

$EffectiveNameFilter = if ($NameFilter) { $NameFilter } elseif ($env:TEST_NAME_FILTER) { $env:TEST_NAME_FILTER } else { "" }
if ($EffectiveNameFilter) {
    $sourceFiles = @($sourceFiles | Where-Object { $_.BaseName -match $EffectiveNameFilter })
}

if (-not $sourceFiles) {
    throw "No Windows test files matched. Directories: $($TestDirs -join ', '); filter: $EffectiveNameFilter"
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

$EffectiveModeFilter = if ($ModeFilter) { $ModeFilter } elseif ($env:TEST_MODE_FILTER) { $env:TEST_MODE_FILTER } else { "" }
$EffectiveOptFilter = if ($OptFilter) { $OptFilter } elseif ($env:TEST_OPT_FILTER) { $env:TEST_OPT_FILTER } else { "" }
$globalModes = @(Get-NormalizedModes -Raw $EffectiveModeFilter)
$globalOpts = @(Get-NormalizedOpts -Raw $EffectiveOptFilter)

$llvmSkipped = 0
$testVariants = @()
foreach ($testCase in $testCases) {
    $lines = @(Get-Content $testCase.Path)
    $llvmOnly = Get-BooleanDirectiveValue -Lines $lines -Pattern '^//\s*LLVM Only:\s*(.+)$'
    if ($llvmOnly) {
        $llvmSkipped += 1
        if (-not $Quiet) {
            Write-Host "[SKIP] $($testCase.Name) - LLVM-only is not supported by the Windows native runner"
        }
        continue
    }

    $testModeRaw = Read-DirectiveValue -Lines $lines -Pattern '^//\s*Mode:\s*(.+)$'
    $testOptRaw = Read-DirectiveValue -Lines $lines -Pattern '^//\s*Opt:\s*(.+)$'
    $testModes = @(Get-NormalizedModes -Raw $testModeRaw)
    $testOpts = @(Get-NormalizedOpts -Raw $testOptRaw)
    $selectedModes = @($testModes | Where-Object { $globalModes -contains $_ })
    $selectedOpts = @($testOpts | Where-Object { $globalOpts -contains $_ })

    # Match the Linux runner: a per-test directive still runs when a global
    # quick filter would otherwise eliminate every requested variant.
    if ($selectedModes.Count -eq 0) { $selectedModes = $testModes }
    if ($selectedOpts.Count -eq 0) { $selectedOpts = $testOpts }

    foreach ($mode in $selectedModes) {
        foreach ($opt in $selectedOpts) {
            $testVariants += [PSCustomObject]@{
                Path = $testCase.Path
                Name = $testCase.Name
                Mode = $mode
                Opt = $opt
                Lines = $lines
            }
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
Write-Host "[INFO] Strict fail diagnostics: $StrictFailDiagnostics"
Write-Host "[INFO] Memory limit: $MemoryLimitBytes bytes"
Write-Host "[INFO] Mode filter: $($globalModes -join ',')"
Write-Host "[INFO] Opt filter : $($globalOpts -join ',')"
if ($EffectiveNameFilter) { Write-Host "[INFO] Name filter: $EffectiveNameFilter" }
Write-Host ""

foreach ($testCase in $testVariants) {
    $total += 1
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($testCase.Path)
    $name = "${baseName}.$($testCase.Mode).$($testCase.Opt)"
    $displayName = "$($testCase.Name) ($($testCase.Mode) $($testCase.Opt))"
    $lines = $testCase.Lines

    $expectedExitRaw = Read-DirectiveValue -Lines $lines -Pattern '^//\s*Expect exit code:\s*(.+)$'
    $expectedExit = 0
    if ($expectedExitRaw) { [void][int]::TryParse($expectedExitRaw, [ref]$expectedExit) }

    $expectCompileFail = Get-BooleanDirectiveValue -Lines $lines -Pattern '^//\s*Expect compile fail:\s*(.+)$'
    $compileOnly = Get-BooleanDirectiveValue -Lines $lines -Pattern '^//\s*Compile only:\s*(.+)$'
    $compilerArgs = @(Split-CompilerArgs -Raw (Read-DirectiveValue -Lines $lines -Pattern '^//\s*Compiler args:\s*(.+)$'))
    $stdinText = Decode-EscapedDirectiveText -Raw (Read-DirectiveValue -Lines $lines -Pattern '^//\s*Stdin:\s*(.+)$')
    $expectedStdout = Decode-EscapedDirectiveText -Raw (Read-DirectiveValue -Lines $lines -Pattern '^//\s*Expect stdout:\s*(.+)$')
    $expectErrContainsList = @(Read-DirectiveValues -Lines $lines -Pattern '^//\s*Expect error contains:\s*(.+)$')
    $expectAsmContainsList = @(Read-DirectiveValues -Lines $lines -Pattern '^//\s*Expect asm contains:\s*(.+)$')
    if ($expectCompileFail -and $StrictFailDiagnostics -and $expectErrContainsList.Count -eq 0) {
        throw "Missing '// Expect error contains:' directive for compile-fail test: $displayName"
    }

    $asmFile = Join-Path $BuildDir "${name}.asm"
    $objFile = Join-Path $BuildDir "${name}.obj"
    $exeFile = Join-Path $BuildDir "${name}.exe"
    $errFile = Join-Path $ResultDir "${name}.err"

    if (Test-Path $asmFile) { Remove-Item $asmFile -Force }
    if (Test-Path $objFile) { Remove-Item $objFile -Force }
    if (Test-Path $exeFile) { Remove-Item $exeFile -Force }
    if (Test-Path $errFile) { Remove-Item $errFile -Force }

    $compilerInvocationArgs = @("--target", "windows-x86_64")
    switch ($testCase.Opt) {
        "O1" { $compilerInvocationArgs += "-O1" }
        "O2" { $compilerInvocationArgs += "-O2" }
        "O3" { $compilerInvocationArgs += "-O3" }
        "OS" { $compilerInvocationArgs += "-Os" }
    }
    if ($testCase.Mode -eq "ssa") {
        $compilerInvocationArgs += "-dump-ssa"
    }
    if ($compilerArgs.Count -gt 0) {
        $compilerInvocationArgs += $compilerArgs
    }
    $compilerInvocationArgs += @("-asm", $testCase.Path)
    $compileResult = Invoke-BppLimitedProcess `
        -FilePath $CompilerPath `
        -ArgumentList $compilerInvocationArgs `
        -TimeoutMs $CompilerTimeoutMs `
        -StdoutPath $asmFile `
        -StderrPath $errFile `
        -WorkingDirectory $RootDir `
        -MemoryLimitBytes $MemoryLimitBytes
    $compileCode = $compileResult.ExitCode

    $caseOk = $true
    $status = "PASS"

    if ($compileCode -ne 0) {
        if ($compileResult.TimedOut) {
            $caseOk = $false
            $status = "FAIL (compiler timeout)"
        } elseif (Test-IsCrashExitCode -ExitCode $compileCode) {
            $caseOk = $false
            $status = "FAIL (compiler crash exit=$compileCode)"
        } elseif ($expectCompileFail) {
            if ($expectErrContainsList.Count -gt 0) {
                $errText = Get-Content $errFile -Raw
                $missing = @()
                foreach ($pat in $expectErrContainsList) {
                    if ($errText.IndexOf($pat, [System.StringComparison]::Ordinal) -lt 0) {
                        $missing += $pat
                    }
                }
                if ($missing.Count -gt 0) {
                    $caseOk = $false
                    $status = "FAIL (compile error mismatch: $($missing[0]))"
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
            if ($expectAsmContainsList.Count -gt 0) {
                $asmText = Get-Content $asmFile -Raw
                $missingAsm = @()
                foreach ($pat in $expectAsmContainsList) {
                    if ($asmText.IndexOf($pat, [System.StringComparison]::Ordinal) -lt 0) {
                        $missingAsm += $pat
                    }
                }
                if ($missingAsm.Count -gt 0) {
                    $caseOk = $false
                    $status = "FAIL (asm mismatch: $($missingAsm[0]))"
                }
            }

            if ($compileOnly) {
                if ($caseOk) {
                    $status = "PASS (compile only)"
                }
            } elseif ($caseOk) {
                $nasmResult = Invoke-BppLimitedProcess `
                    -FilePath $NasmPath `
                    -ArgumentList @("-f", "win64", "-O1", $asmFile, "-o", $objFile) `
                    -TimeoutMs $CompilerTimeoutMs `
                    -StderrPath $errFile `
                    -WorkingDirectory $RootDir `
                    -MemoryLimitBytes $MemoryLimitBytes
                if ($nasmResult.ExitCode -ne 0) {
                    $caseOk = $false
                    $status = "FAIL (assemble)"
                } else {
                    $linkCode = Invoke-Link -Linker $LinkerPath -ObjectFile $objFile -OutputExe $exeFile -ErrorFile $errFile
                    if ($linkCode -ne 0) {
                        $caseOk = $false
                        $status = "FAIL (link)"
                    } else {
                        $runResult = Invoke-TestProcess -ExePath $exeFile -Timeout $TimeoutMs -StdinText $stdinText
                        $runExit = $runResult.ExitCode
                        $portableRunExit = Convert-ToPortableTestExitCode -ExitCode $runExit
                        if ($portableRunExit -ne $expectedExit) {
                            $caseOk = $false
                            $status = "FAIL (exit=$runExit expect=$expectedExit)"
                        } elseif ($expectedStdout -ne "" -and $runResult.Stdout -ne $expectedStdout) {
                            $caseOk = $false
                            $status = "FAIL (stdout mismatch)"
                        }
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
Write-Host "LLVM skipped: $llvmSkipped"

if ($failed -ne 0) {
    exit 1
}

Write-Host "All tests passed."
exit 0
