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
    [ValidateRange(0, 64)][int]$Jobs = 0,
    [string]$TimingJsonPath = "",
    [ValidateRange(1, 1024)][int]$ShardCount = 1,
    [ValidateRange(0, 1023)][int]$ShardIndex = 0,
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

function Get-StableCaseHash {
    param([string]$CaseId)

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($CaseId)
        return $sha256.ComputeHash($bytes)
    } finally {
        $sha256.Dispose()
    }
}

function Get-AutomaticJobCount {
    $cpuJobs = [Math]::Max(1, [Environment]::ProcessorCount)
    $memoryJobs = 4
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $availableBytes = [UInt64]$os.FreePhysicalMemory * 1024
        $memoryJobs = [Math]::Max(1, [int][Math]::Floor($availableBytes / 1610612736))
    } catch {
        # CPU-only fallback is deterministic on hosts without CIM.
    }
    return [Math]::Max(1, [Math]::Min(4, [Math]::Min($cpuJobs, $memoryJobs)))
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
$variantOrdinal = 0
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
            $caseId = "$($testCase.Name)|$mode|$opt"
            $caseHash = Get-StableCaseHash -CaseId $caseId
            $caseHashHex = ([BitConverter]::ToString($caseHash)).Replace("-", "").ToLowerInvariant()
            $shardValue = [BitConverter]::ToUInt32($caseHash, 0) % $ShardCount
            $currentOrdinal = $variantOrdinal
            $variantOrdinal += 1
            if ($shardValue -ne $ShardIndex) { continue }
            $testVariants += [PSCustomObject]@{
                Id = $caseId
                Hash = $caseHashHex
                Ordinal = $currentOrdinal
                ArtifactStem = ("{0:D4}_{1}_{2}_{3}" -f $currentOrdinal, $mode, $opt, $caseHashHex.Substring(0, 12))
                Path = $testCase.Path
                Name = $testCase.Name
                Mode = $mode
                Opt = $opt
                Lines = $lines
            }
        }
    }
}

if ($ShardIndex -ge $ShardCount) {
    throw "ShardIndex must be less than ShardCount (index=$ShardIndex count=$ShardCount)."
}

$duplicateIds = @($testVariants | Group-Object Id | Where-Object Count -ne 1)
if ($duplicateIds.Count -ne 0) {
    throw "Duplicate Windows test case ID: $($duplicateIds[0].Name)"
}

$EffectiveJobs = if ($PSBoundParameters.ContainsKey("Jobs")) {
    $Jobs
} elseif ($env:TEST_JOBS) {
    $parsedJobs = 0
    if (-not [int]::TryParse($env:TEST_JOBS, [ref]$parsedJobs) -or $parsedJobs -lt 0) {
        throw "TEST_JOBS must be a non-negative integer: $($env:TEST_JOBS)"
    }
    $parsedJobs
} else {
    0
}
if ($EffectiveJobs -eq 0) { $EffectiveJobs = Get-AutomaticJobCount }
$EffectiveJobs = [Math]::Max(1, [Math]::Min(4, $EffectiveJobs))

$ResolvedTimingJsonPath = ""
$CompilerTimingDir = ""
if ($TimingJsonPath) {
    $ResolvedTimingJsonPath = if ([System.IO.Path]::IsPathRooted($TimingJsonPath)) {
        $TimingJsonPath
    } else {
        Join-Path $RootDir $TimingJsonPath
    }
    $CompilerTimingDir = "$ResolvedTimingJsonPath.compiler"
    New-Item -ItemType Directory -Force -Path $CompilerTimingDir | Out-Null
}

$workerConfig = [PSCustomObject]@{
    ProcessHelper = $ProcessHelper
    CompilerPath = $CompilerPath
    NasmPath = $NasmPath
    LinkerPath = $LinkerPath
    BuildDir = $BuildDir
    ResultDir = $ResultDir
    RootDir = $RootDir.Path
    TimeoutMs = $TimeoutMs
    CompilerTimeoutMs = $CompilerTimeoutMs
    MemoryLimitBytes = $MemoryLimitBytes
    StrictFailDiagnostics = $StrictFailDiagnostics
    CompilerTimingDir = $CompilerTimingDir
}

$workerScript = {
    param($Case, $Config)
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"
    # Jobs=1 already runs in the parent session where the helper is loaded.
    # Pool workers load it once per fresh runspace scope as needed.
    if (-not (Get-Command Invoke-BppLimitedProcess -CommandType Function -ErrorAction SilentlyContinue)) {
        . $Config.ProcessHelper
    }

    function Read-One($Lines, $Pattern) {
        foreach ($line in $Lines) {
            if ($line -match $Pattern) { return $matches[1].Trim() }
        }
        return ""
    }
    function Read-Many($Lines, $Pattern) {
        $values = @()
        foreach ($line in $Lines) {
            if ($line -match $Pattern) {
                $value = $matches[1].Trim()
                if ($value) { $values += $value }
            }
        }
        return @($values)
    }
    function Read-Bool($Lines, $Pattern) {
        $raw = (Read-One $Lines $Pattern).ToLowerInvariant()
        return ($raw -eq "1" -or $raw -eq "true" -or $raw -eq "yes")
    }
    function To-Metric($ProcessResult) {
        if ($null -eq $ProcessResult) { return $null }
        return [PSCustomObject]@{
            wallMs = $ProcessResult.WallTimeMs
            cpuMs = $ProcessResult.CpuTimeMs
            peakWorkingSetBytes = $ProcessResult.PeakWorkingSetBytes
            exitCode = $ProcessResult.ExitCode
            timedOut = $ProcessResult.TimedOut
        }
    }

    $caseClock = [System.Diagnostics.Stopwatch]::StartNew()
    $compileResult = $null
    $assembleResult = $null
    $linkResult = $null
    $runResult = $null
    $caseOk = $true
    $status = "PASS"
    $diagnostic = ""
    $displayName = "$($Case.Name) ($($Case.Mode) $($Case.Opt))"
    $asmFile = Join-Path $Config.BuildDir "$($Case.ArtifactStem).asm"
    $objFile = Join-Path $Config.BuildDir "$($Case.ArtifactStem).obj"
    $exeFile = Join-Path $Config.BuildDir "$($Case.ArtifactStem).exe"
    $errFile = Join-Path $Config.ResultDir "$($Case.ArtifactStem).err"
    $compilerTimingFile = ""
    if ($Config.CompilerTimingDir) {
        $compilerTimingFile = Join-Path $Config.CompilerTimingDir "$($Case.ArtifactStem).json"
    }

    try {
        foreach ($path in @($asmFile, $objFile, $exeFile, $errFile)) {
            if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
        }

        $lines = @($Case.Lines)
        $expectedExit = 0
        $expectedExitRaw = Read-One $lines '^//\s*Expect exit code:\s*(.+)$'
        if ($expectedExitRaw) { [void][int]::TryParse($expectedExitRaw, [ref]$expectedExit) }
        $expectCompileFail = Read-Bool $lines '^//\s*Expect compile fail:\s*(.+)$'
        $compileOnly = Read-Bool $lines '^//\s*Compile only:\s*(.+)$'
        $compilerArgs = @((Read-One $lines '^//\s*Compiler args:\s*(.+)$') -split '\s+' | Where-Object { $_ })
        $stdinText = [System.Text.RegularExpressions.Regex]::Unescape((Read-One $lines '^//\s*Stdin:\s*(.+)$'))
        $expectedStdout = [System.Text.RegularExpressions.Regex]::Unescape((Read-One $lines '^//\s*Expect stdout:\s*(.+)$'))
        $expectErrContains = @(Read-Many $lines '^//\s*Expect error contains:\s*(.+)$')
        $expectAsmContains = @(Read-Many $lines '^//\s*Expect asm contains:\s*(.+)$')
        if ($expectCompileFail -and $Config.StrictFailDiagnostics -and $expectErrContains.Count -eq 0) {
            throw "Missing '// Expect error contains:' directive"
        }

        $args = @("--target", "windows-x86_64")
        switch ($Case.Opt) {
            "O1" { $args += "-O1" }
            "O2" { $args += "-O2" }
            "O3" { $args += "-O3" }
            "OS" { $args += "-Os" }
        }
        if ($Case.Mode -eq "ssa") { $args += "-dump-ssa" }
        if ($compilerArgs.Count -gt 0) { $args += $compilerArgs }
        if ($compilerTimingFile) { $args += @("--timings-json", $compilerTimingFile) }
        $args += @("-asm", $Case.Path)

        $compileResult = Invoke-BppLimitedProcess -FilePath $Config.CompilerPath -ArgumentList $args `
            -TimeoutMs $Config.CompilerTimeoutMs -StdoutPath $asmFile -StderrPath $errFile `
            -WorkingDirectory $Config.RootDir -MemoryLimitBytes $Config.MemoryLimitBytes

        if ($compileResult.ExitCode -ne 0) {
            if ($compileResult.TimedOut) {
                $caseOk = $false; $status = "FAIL (compiler timeout)"
            } elseif ($compileResult.ExitCode -lt 0 -or $compileResult.ExitCode -ge 128) {
                $caseOk = $false; $status = "FAIL (compiler crash exit=$($compileResult.ExitCode))"
            } elseif ($expectCompileFail) {
                $errText = if (Test-Path -LiteralPath $errFile) { Get-Content -LiteralPath $errFile -Raw } else { "" }
                $missing = @($expectErrContains | Where-Object { $errText.IndexOf($_, [System.StringComparison]::Ordinal) -lt 0 })
                if ($missing.Count -gt 0) {
                    $caseOk = $false; $status = "FAIL (compile error mismatch: $($missing[0]))"
                } else {
                    $status = "PASS (expected compile fail)"
                }
            } else {
                $caseOk = $false; $status = "FAIL (compile)"
            }
        } elseif ($expectCompileFail) {
            $caseOk = $false; $status = "FAIL (unexpected compile success)"
        } else {
            if ($expectAsmContains.Count -gt 0) {
                $asmText = Get-Content -LiteralPath $asmFile -Raw
                $missingAsm = @($expectAsmContains | Where-Object { $asmText.IndexOf($_, [System.StringComparison]::Ordinal) -lt 0 })
                if ($missingAsm.Count -gt 0) {
                    $caseOk = $false; $status = "FAIL (asm mismatch: $($missingAsm[0]))"
                }
            }

            if ($compileOnly) {
                if ($caseOk) { $status = "PASS (compile only)" }
            } elseif ($caseOk) {
                $assembleResult = Invoke-BppLimitedProcess -FilePath $Config.NasmPath `
                    -ArgumentList @("-f", "win64", "-O1", $asmFile, "-o", $objFile) `
                    -TimeoutMs $Config.CompilerTimeoutMs -StderrPath $errFile `
                    -WorkingDirectory $Config.RootDir -MemoryLimitBytes $Config.MemoryLimitBytes
                if ($assembleResult.ExitCode -ne 0) {
                    $caseOk = $false; $status = "FAIL (assemble)"
                } else {
                    $linkArgs = @("/nologo", "/Brepro", "/subsystem:console", "/entry:mainCRTStartup", "/out:$exeFile", $objFile, "kernel32.lib")
                    $linkResult = Invoke-BppLimitedProcess -FilePath $Config.LinkerPath -ArgumentList $linkArgs `
                        -TimeoutMs $Config.CompilerTimeoutMs -StderrPath $errFile `
                        -WorkingDirectory $Config.RootDir -MemoryLimitBytes $Config.MemoryLimitBytes
                    if ($linkResult.ExitCode -ne 0) {
                        $caseOk = $false; $status = "FAIL (link)"
                    } else {
                        $runResult = Invoke-BppLimitedProcess -FilePath $exeFile -TimeoutMs $Config.TimeoutMs `
                            -StdinText $stdinText -WorkingDirectory $Config.RootDir `
                            -MemoryLimitBytes $Config.MemoryLimitBytes
                        $portableExit = if ($runResult.ExitCode -eq -1073741795) { 132 } else { $runResult.ExitCode }
                        if ($portableExit -ne $expectedExit) {
                            $caseOk = $false; $status = "FAIL (exit=$($runResult.ExitCode) expect=$expectedExit)"
                        } elseif ($expectedStdout -ne "" -and $runResult.Stdout -ne $expectedStdout) {
                            $caseOk = $false; $status = "FAIL (stdout mismatch)"
                        }
                    }
                }
            }
        }
    } catch {
        $caseOk = $false
        $status = "FAIL (runner error)"
        $diagnostic = $_.Exception.Message
    }

    $caseClock.Stop()
    return [PSCustomObject]@{
        id = $Case.Id
        ordinal = $Case.Ordinal
        name = $Case.Name
        mode = $Case.Mode
        opt = $Case.Opt
        passed = $caseOk
        status = $status
        diagnostic = $diagnostic
        compilerTimingsPath = $compilerTimingFile
        timing = [PSCustomObject]@{
            totalMs = [Math]::Round($caseClock.Elapsed.TotalMilliseconds, 3)
            compile = To-Metric $compileResult
            assemble = To-Metric $assembleResult
            link = To-Metric $linkResult
            run = To-Metric $runResult
        }
    }
}

Write-Host "========================================"
Write-Host "$Version Windows Test Suite"
Write-Host "========================================"
Write-Host "[INFO] Compiler: $CompilerPath"
Write-Host "[INFO] NASM    : $NasmPath"
Write-Host "[INFO] Linker  : $LinkerPath"
Write-Host "[INFO] Jobs    : $EffectiveJobs"
Write-Host "[INFO] Shard   : $ShardIndex/$ShardCount"
Write-Host "[INFO] Strict fail diagnostics: $StrictFailDiagnostics"
Write-Host "[INFO] Memory limit: $MemoryLimitBytes bytes"
Write-Host "[INFO] Mode filter: $($globalModes -join ',')"
Write-Host "[INFO] Opt filter : $($globalOpts -join ',')"
if ($EffectiveNameFilter) { Write-Host "[INFO] Name filter: $EffectiveNameFilter" }
Write-Host ""

$suiteClock = [System.Diagnostics.Stopwatch]::StartNew()
$results = New-Object System.Collections.Generic.List[object]
if ($EffectiveJobs -eq 1) {
    foreach ($variant in $testVariants) {
        $result = & $workerScript $variant $workerConfig
        $results.Add($result)
    }
} else {
    $pool = [RunspaceFactory]::CreateRunspacePool(1, $EffectiveJobs)
    $pending = New-Object System.Collections.Generic.List[object]
    try {
        $pool.Open()
        foreach ($variant in $testVariants) {
            $powerShell = [PowerShell]::Create()
            $powerShell.RunspacePool = $pool
            [void]$powerShell.AddScript($workerScript.ToString()).AddArgument($variant).AddArgument($workerConfig)
            $pending.Add([PSCustomObject]@{
                PowerShell = $powerShell
                Handle = $powerShell.BeginInvoke()
                Variant = $variant
            })
        }
        foreach ($item in $pending) {
            try {
                $output = @($item.PowerShell.EndInvoke($item.Handle))
                if ($output.Count -ne 1) { throw "Worker returned $($output.Count) results" }
                $results.Add($output[0])
            } catch {
                $results.Add([PSCustomObject]@{
                    id = $item.Variant.Id; ordinal = $item.Variant.Ordinal
                    name = $item.Variant.Name; mode = $item.Variant.Mode; opt = $item.Variant.Opt
                    passed = $false; status = "FAIL (runspace error)"
                    diagnostic = $_.Exception.Message
                    compilerTimingsPath = ""
                    timing = [PSCustomObject]@{ totalMs = 0; compile = $null; assemble = $null; link = $null; run = $null }
                })
            } finally {
                $item.PowerShell.Dispose()
            }
        }
    } finally {
        foreach ($item in $pending) { $item.PowerShell.Dispose() }
        $pool.Close()
        $pool.Dispose()
    }
}
$suiteClock.Stop()

$orderedResults = @($results | Sort-Object ordinal)
$passed = @($orderedResults | Where-Object passed).Count
$failed = $orderedResults.Count - $passed
foreach ($result in $orderedResults) {
    $displayName = "$($result.name) ($($result.mode) $($result.opt))"
    if ($result.passed) {
        if (-not $Quiet) { Write-Host "[PASS] $displayName - $($result.status)" }
    } else {
        Write-Host "[FAIL] $displayName - $($result.status)"
        if ($result.diagnostic) { Write-Host "       $($result.diagnostic)" }
    }
}

if ($TimingJsonPath) {
    $timingParent = Split-Path -Parent $ResolvedTimingJsonPath
    if ($timingParent) { New-Item -ItemType Directory -Force -Path $timingParent | Out-Null }
    $manifest = [PSCustomObject]@{
        schemaVersion = 1
        generatedAtUtc = [DateTime]::UtcNow.ToString("o")
        jobs = $EffectiveJobs
        shardCount = $ShardCount
        shardIndex = $ShardIndex
        elapsedMs = [Math]::Round($suiteClock.Elapsed.TotalMilliseconds, 3)
        total = $orderedResults.Count
        passed = $passed
        failed = $failed
        llvmSkipped = $llvmSkipped
        cases = $orderedResults
    }
    [System.IO.File]::WriteAllText(
        $ResolvedTimingJsonPath,
        ($manifest | ConvertTo-Json -Depth 8),
        (New-Object System.Text.UTF8Encoding($false))
    )
    Write-Host "[INFO] Timing JSON: $ResolvedTimingJsonPath"
}

Write-Host ""
Write-Host "========================================"
Write-Host "Windows Test Results"
Write-Host "========================================"
Write-Host "Total:  $($orderedResults.Count)"
Write-Host "Passed: $passed"
Write-Host "Failed: $failed"
Write-Host "LLVM skipped: $llvmSkipped"
Write-Host ("Elapsed: {0:N1}s" -f $suiteClock.Elapsed.TotalSeconds)

if ($failed -ne 0) { exit 1 }
Write-Host "All tests passed."
exit 0
