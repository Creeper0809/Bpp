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
    [switch]$DisableFastPlanning,
    [switch]$PlanOnly,
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

function Start-DefaultPipelineSmoke {
    param(
        [string]$Compiler,
        [string]$Nasm,
        [string]$Linker,
        [string]$OutputDirectory
    )

    # Exercise the compiler's own CreateProcess-based assemble/link/run path.
    # The regular test workers invoke those tools themselves and therefore
    # cannot detect a broken hosted process launcher.
    $Compiler = (Resolve-Path -LiteralPath $Compiler).Path
    $Nasm = (Resolve-Path -LiteralPath $Nasm).Path
    $Linker = (Resolve-Path -LiteralPath $Linker).Path
    $sourcePath = Join-Path $OutputDirectory "default_pipeline_smoke.bpp"
    $manifestPath = Join-Path $OutputDirectory "bpp.toml"
    $stdoutPath = Join-Path $OutputDirectory "default_pipeline_smoke.stdout"
    $stderrPath = Join-Path $OutputDirectory "default_pipeline_smoke.stderr"
    $exePath = Join-Path $OutputDirectory "default_pipeline_smoke.exe"
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($sourcePath, "func main() -> u64 {`n    return 0;`n}`n", $utf8)
    [System.IO.File]::WriteAllLines($manifestPath, @(
        "std_root=../../src",
        "nasm_path=$Nasm",
        "ld_path=$Linker"
    ), $utf8)

    $smokeScript = {
        param(
            [string]$ProcessHelperPath,
            [string]$CompilerExecutable,
            [string]$WorkingDirectory,
            [string]$StdoutFile,
            [string]$StderrFile,
            [int]$Timeout,
            [UInt64]$MemoryLimit
        )

        . $ProcessHelperPath
        Invoke-BppLimitedProcess `
            -FilePath $CompilerExecutable `
            -ArgumentList @("default_pipeline_smoke.bpp") `
            -TimeoutMs $Timeout `
            -StdoutPath $StdoutFile `
            -StderrPath $StderrFile `
            -WorkingDirectory $WorkingDirectory `
            -MemoryLimitBytes $MemoryLimit
    }

    $powerShell = [PowerShell]::Create()
    $smokeCommand = $powerShell.AddScript($smokeScript.ToString())
    [void]$smokeCommand.AddArgument($ProcessHelper)
    [void]$smokeCommand.AddArgument($Compiler)
    [void]$smokeCommand.AddArgument($OutputDirectory)
    [void]$smokeCommand.AddArgument($stdoutPath)
    [void]$smokeCommand.AddArgument($stderrPath)
    [void]$smokeCommand.AddArgument($CompilerTimeoutMs)
    [void]$smokeCommand.AddArgument($MemoryLimitBytes)

    return [PSCustomObject]@{
        PowerShell = $powerShell
        Handle = $powerShell.BeginInvoke()
        ExePath = $exePath
        StderrPath = $stderrPath
    }
}

function Complete-DefaultPipelineSmoke {
    param($Smoke)

    try {
        $output = @($Smoke.PowerShell.EndInvoke($Smoke.Handle))
        if ($output.Count -ne 1) {
            throw "Default pipeline worker returned $($output.Count) results"
        }
        $result = $output[0]
        if ($result.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $Smoke.ExePath)) {
            $detail = if (Test-Path -LiteralPath $Smoke.StderrPath) {
                $rawDetail = Get-Content -LiteralPath $Smoke.StderrPath -Raw
                if ($null -eq $rawDetail -or $rawDetail.Length -eq 0) { "no diagnostic" } else { $rawDetail.Trim() }
            } else {
                "no diagnostic"
            }
            throw "Compiler default assemble/link/run pipeline failed (exit=$($result.ExitCode)): $detail"
        }
    } finally {
        $Smoke.PowerShell.Dispose()
    }
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
    $memoryJobs = 8
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $availableBytes = [UInt64]$os.FreePhysicalMemory * 1024
        # Full-suite history keeps 95% of compiler processes below 100 MiB;
        # only a few compiler-internal bundles approach 400 MiB and the
        # longest-processing-first queue prevents them from forming the tail.
        # Reserve 320 MiB per worker while retaining the independent 4 GiB
        # per-process safety ceiling for pathological cases.
        $memoryJobs = [Math]::Max(1, [int][Math]::Floor($availableBytes / 335544320))
    } catch {
        # CPU-only fallback is deterministic on hosts without CIM.
    }
    return [Math]::Max(1, [Math]::Min(32, [Math]::Min($cpuJobs, $memoryJobs)))
}

function Get-VariantEstimatedCost {
    param($Variant)

    if ($Variant.PSObject.Properties['PhysicalKind'] -and $Variant.PhysicalKind -eq 'failure-batch') {
        return 2400000000 + @($Variant.Members).Count
    }
    if ($Variant.PSObject.Properties['PhysicalKind'] -and $Variant.PhysicalKind -eq 'module-bundle') {
        if ($Variant.Name -match '^internal_lifetime_bundle') { return 3100000000 }
        return 2800000000
    }
    if ($Variant.PSObject.Properties['PhysicalKind'] -and $Variant.PhysicalKind -eq 'equivalent-variants') {
        if ($Variant.Name -eq '97_strict_ssa_normal_prelude_success') { return 3000000000 }
        return 2300000000
    }
    if ($Variant.PSObject.Properties['PhysicalKind'] -and $Variant.PhysicalKind -in @('dispatch-bundle', 'concatenated-suite')) {
        return 2200000000
    }
    $text = @($Variant.Lines) -join "`n"
    # Source size is a useful secondary predictor once tests are outside the
    # explicitly classified shared bundles. Scale it enough to distinguish the
    # large ABI/runtime fixtures from tiny smoke cases.
    $score = [int64]$text.Length * 20000
    if ($text -match '(?m)^//\s*Compiler args:\s*.*--backend\s+ssa') { $score += 1500000000 }
    if ($text -match '(?m)^//\s*Compiler output mode:\s*(?!-asm\s*$)') { $score += 3000000000 }
    if ($text -match '(?m)^//\s*Expect deterministic compiler output:') { $score += 1000000000 }
    if ($text -match '(?m)^\s*import\s+(compiler|ssa)([.;]|\s|$)') { $score += 2000000000 }
    if ($text -match '(?m)^//\s*Compile only:') { $score += 100000000 }
    return $score
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

$defaultPipelineSmoke = Start-DefaultPipelineSmoke `
    -Compiler $CompilerPath `
    -Nasm $NasmPath `
    -Linker $LinkerPath `
    -OutputDirectory $BuildDir

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
$LogicalVariantCount = $testVariants.Count

$FastPlanningEnabled = (-not $DisableFastPlanning) -and $ShardCount -eq 1 -and `
    (-not $EffectiveNameFilter) -and (-not $EffectiveModeFilter) -and (-not $EffectiveOptFilter)

if ($FastPlanningEnabled) {
    # These compiler/SSA lifetime tests deliberately exercise the same large
    # implementation graph. Keep each source in its own module namespace and
    # call every original entry, but compile/assemble/link that graph once.
    $internalMembers = @($testVariants | Where-Object {
        $_.Mode -eq 'nossa' -and $_.Opt -eq 'O0' -and
        ($_.Name -eq '91_compiler_context_lifecycle_success' -or
         $_.Name -match '^(10[5-9]|11[0-9]|12[0-6])_')
    })
    if ($internalMembers.Count -eq 23) {
        $bundleOrder = @($internalMembers | Sort-Object {
            if ($_.Name -match '^109_') { 1000 }
            elseif ($_.Name -match '^91_') { 1001 }
            elseif ($_.Name -match '^(\d+)_') { [int]$matches[1] }
            else { 999 }
        })
        $bundleDir = Join-Path $BuildDir 'fast_internal_lifetime_bundle'
        New-Item -ItemType Directory -Force -Path $bundleDir | Out-Null
        $bundleUtf8 = New-Object System.Text.UTF8Encoding($false)
        $bundleIndex = 0
        foreach ($member in $bundleOrder) {
            $bundleIndex += 1
            $moduleName = "case_$bundleIndex"
            $entryName = "fast_bundle_entry_$bundleIndex"
            $sourceText = [System.IO.File]::ReadAllText($member.Path)
            $moduleText = [regex]::Replace($sourceText, '(?m)^func main\s*\(', "func $entryName(", 1)
            if ($moduleText -eq $sourceText) {
                throw "Fast bundle entry not found: $($member.Path)"
            }
            [System.IO.File]::WriteAllText((Join-Path $bundleDir "$moduleName.bpp"), $moduleText, $bundleUtf8)
        }

        $memberIds = @($internalMembers | ForEach-Object Id)
        $testVariants = @($testVariants | Where-Object { $memberIds -notcontains $_.Id })
        $splitAt = [int][Math]::Ceiling($bundleOrder.Count / 2.0)
        for ($part = 0; $part -lt 2; $part++) {
            $start = if ($part -eq 0) { 0 } else { $splitAt }
            $last = if ($part -eq 0) { $splitAt - 1 } else { $bundleOrder.Count - 1 }
            $partMembers = @($bundleOrder[$start..$last])
            $partImports = New-Object System.Collections.Generic.List[string]
            $partCalls = New-Object System.Collections.Generic.List[string]
            for ($i = $start; $i -le $last; $i++) {
                $entryNumber = $i + 1
                $partImports.Add("import fast_bundle_entry_$entryNumber from case_$entryNumber;")
                $partCalls.Add("    if (fast_bundle_entry_$entryNumber() != 0) { return $entryNumber; }")
            }
            $partNumber = $part + 1
            $bundleSource = Join-Path $bundleDir "main_part_$partNumber.bpp"
            $bundleText = @($partImports) + @('', 'func main() -> u64 {') + @($partCalls) + @('    return 0;', '}')
            [System.IO.File]::WriteAllText($bundleSource, ($bundleText -join "`n") + "`n", $bundleUtf8)
            $testVariants += [PSCustomObject]@{
                Id = "__fast_internal_lifetime_bundle_$partNumber|nossa|O0"
                Hash = ''
                Ordinal = ($partMembers.Ordinal | Measure-Object -Minimum).Minimum
                ArtifactStem = "fast_internal_lifetime_bundle_$partNumber"
                Path = $bundleSource
                Name = "internal_lifetime_bundle_$partNumber"
                Mode = 'nossa'
                Opt = 'O0'
                Lines = @('// Mode: nossa', '// Opt: O0', '// Expect exit code: 0')
                PhysicalKind = 'module-bundle'
                Members = $partMembers
            }
        }
    }

    # The final `--backend ssa -asm` arguments make the declared runner mode
    # variants byte-identical. Prior full-suite artifacts proved identical ASM
    # for test 97 and identical diagnostics for all test 89 variants.
    foreach ($equivalentName in @('89_strict_ssa_backend_fail', '97_strict_ssa_normal_prelude_success')) {
        $equivalentMembers = @($testVariants | Where-Object Name -eq $equivalentName | Sort-Object Ordinal)
        if ($equivalentMembers.Count -gt 1) {
            $canonical = $equivalentMembers[0]
            $equivalentIds = @($equivalentMembers | ForEach-Object Id)
            $testVariants = @($testVariants | Where-Object { $equivalentIds -notcontains $_.Id })
            $canonical | Add-Member -NotePropertyName PhysicalKind -NotePropertyValue 'equivalent-variants' -Force
            $canonical | Add-Member -NotePropertyName Members -NotePropertyValue $equivalentMembers -Force
            $testVariants += $canonical
        }
    }

    # Bundle proven-compatible, no-I/O fixtures by backend/opt profile.
    # Entry-point/ABI tests and the two fixtures that expose shared generic/runtime
    # state remain isolated. The four broad groups are covered by a standalone
    # probe before being admitted here.
    $generalBundleCandidates = @($testVariants | Where-Object {
        if ($_.PSObject.Properties['PhysicalKind']) { return $false }
        if ($_.Name -match '::') { return $false }
        if ($_.Name -match '^(42|43|46)_') { return $false }
        if ($_.Path -match '[\\/]source_fail[\\/]') { return $false }
        $text = @($_.Lines) -join "`n"
        if ($text -match '(?m)^//\s*Expect compile fail:\s*(1|true|yes)\s*$') { return $false }
        if ($text -match '(?m)^//\s*(Expect stdout|Stdin|Compile only|Expect deterministic compiler output|Expect asm contains|Expect compiler output excludes|Compiler output mode):') { return $false }
        $compilerArgsRaw = if ($text -match '(?m)^//\s*Compiler args:\s*(.+)$') { $matches[1].Trim() } else { '' }
        $redundantCompilerArgs = switch ($_.Opt) {
            'O1' { '-O1' }
            'O2' { '-O2' }
            'O3' { '-O3' }
            'OS' { '-Os' }
            default { '' }
        }
        if ($compilerArgsRaw -and $compilerArgsRaw -ne $redundantCompilerArgs -and $compilerArgsRaw -ne '--target windows-x86_64') { return $false }
        if ($text -match '(?m)^@\[entry\]') { return $false }
        $exitRaw = if ($text -match '(?m)^//\s*Expect exit code:\s*(.+)$') { $matches[1].Trim() } else { '0' }
        if ($exitRaw -ne '0') { return $false }
        if ([regex]::Matches($text, '(?m)^func main\s*\(').Count -ne 1) { return $false }
        return [regex]::Matches($text, '(?m)^func main\s*\(\s*\)\s*->\s*(u64|i64)').Count -eq 1
    })

    $generalBundleNumber = 0
    foreach ($bundleGroup in @($generalBundleCandidates | Group-Object {
        $groupText = @($_.Lines) -join "`n"
        $groupClass = if ($groupText -match '(?m)^//\s*Compiler args:') { 'redundant-args' } else { 'base' }
        "$($_.Mode)|$($_.Opt)|$groupClass"
    })) {
        $groupMembers = @($bundleGroup.Group | Sort-Object Ordinal)
        for ($offset = 0; $offset -lt $groupMembers.Count; $offset += $groupMembers.Count) {
            $last = $groupMembers.Count - 1
            $chunk = @($groupMembers[$offset..$last])
            if ($chunk.Count -lt 2) { continue }
            $generalBundleNumber += 1
            $chunkDir = Join-Path $BuildDir ("fast_general_bundle_{0:D3}" -f $generalBundleNumber)
            New-Item -ItemType Directory -Force -Path $chunkDir | Out-Null
            if (@($chunk | Where-Object { (@($_.Lines) -join "`n") -match '(?m)^\s*import\s+.*\bmodules\.' }).Count -gt 0) {
                $supportModules = Join-Path $RootDir 'test\source\modules'
                Copy-Item -LiteralPath $supportModules -Destination (Join-Path $chunkDir 'modules') -Recurse -Force
            }
            $chunkImports = New-Object System.Collections.Generic.List[string]
            $chunkCalls = New-Object System.Collections.Generic.List[string]
            $chunkStdinRaw = ''
            $chunkStdoutRaw = ''
            $chunkExpectedErrors = New-Object System.Collections.Generic.List[string]
            for ($i = 0; $i -lt $chunk.Count; $i++) {
                $moduleName = "case_$($i + 1)"
                $entryName = "fast_bundle_entry_$($i + 1)"
                $sourceText = [System.IO.File]::ReadAllText($chunk[$i].Path)
                $moduleText = [regex]::Replace($sourceText, '(?m)^func main\s*\(', "func $entryName(", 1)
                if ($moduleText -eq $sourceText) { throw "Fast bundle entry not found: $($chunk[$i].Path)" }
                [System.IO.File]::WriteAllText((Join-Path $chunkDir "$moduleName.bpp"), $moduleText, $bundleUtf8)
                $chunkImports.Add("import $entryName from $moduleName;")
                $memberExitRaw = Read-DirectiveValue -Lines @($chunk[$i].Lines) -Pattern '^//\s*Expect exit code:\s*(.+)$'
                $memberExit = if ($memberExitRaw) { [int]$memberExitRaw } else { 0 }
                $chunkCalls.Add("    if ($entryName() != $memberExit) { return $($i + 1); }")
                $chunkStdinRaw += Read-DirectiveValue -Lines @($chunk[$i].Lines) -Pattern '^//\s*Stdin:\s*(.+)$'
                $chunkStdoutRaw += Read-DirectiveValue -Lines @($chunk[$i].Lines) -Pattern '^//\s*Expect stdout:\s*(.+)$'
                foreach ($expectedError in @(Read-DirectiveValues -Lines @($chunk[$i].Lines) -Pattern '^//\s*Expect error contains:\s*(.+)$')) {
                    $chunkExpectedErrors.Add($expectedError)
                }
            }
            $chunkSource = Join-Path $chunkDir 'main.bpp'
            $chunkText = @($chunkImports) + @('', 'func main() -> u64 {') + @($chunkCalls) + @('    return 0;', '}')
            [System.IO.File]::WriteAllText($chunkSource, ($chunkText -join "`n") + "`n", $bundleUtf8)
            $chunkIds = @($chunk | ForEach-Object Id)
            $testVariants = @($testVariants | Where-Object { $chunkIds -notcontains $_.Id })
            $chunkLines = New-Object System.Collections.Generic.List[string]
            $chunkLines.Add("// Mode: $($chunk[0].Mode)")
            $chunkLines.Add("// Opt: $($chunk[0].Opt)")
            $chunkLines.Add('// Expect exit code: 0')
            if ($chunkStdinRaw) { $chunkLines.Add("// Stdin: $chunkStdinRaw") }
            if ($chunkStdoutRaw) { $chunkLines.Add("// Expect stdout: $chunkStdoutRaw") }
            foreach ($expectedError in $chunkExpectedErrors) { $chunkLines.Add("// Expect error contains: $expectedError") }
            $testVariants += [PSCustomObject]@{
                Id = "__fast_general_bundle_$generalBundleNumber|$($chunk[0].Mode)|$($chunk[0].Opt)"
                Hash = ''
                Ordinal = ($chunk.Ordinal | Measure-Object -Minimum).Minimum
                ArtifactStem = ("fast_general_bundle_{0:D3}" -f $generalBundleNumber)
                Path = $chunkSource
                Name = ("general_bundle_{0:D3}" -f $generalBundleNumber)
                Mode = $chunk[0].Mode
                Opt = $chunk[0].Opt
                Lines = $chunkLines.ToArray()
                PhysicalKind = 'module-bundle'
                Members = $chunk
            }
        }
    }

    # Expanded success suites must remain in their original single-module
    # topology: importing each case as a child module changes super/name
    # resolution. Their top-level fixture symbols are intentionally unique, so
    # concatenate compatible cases and rename only each entry function.
    $expandedSuccessCandidates = @($testVariants | Where-Object {
        if ($_.PSObject.Properties['PhysicalKind']) { return $false }
        if ($_.Name -notmatch '^(02_ternary_do_while_suite|03_property_hooks_suite|87_o1_reachability_exhaustive_success|100_recursive_layout_boundaries_success)::') { return $false }
        if ($_.Name -match '^03_property_hooks_suite::' -and $_.Mode -eq 'nossa') { return $false }
        $text = @($_.Lines) -join "`n"
        if ($text -match '(?m)^//\s*Expect compile fail:\s*(1|true|yes)\s*$') { return $false }
        if ($text -match '(?m)^//\s*(Expect stdout|Stdin|Compiler args|Compile only|Expect deterministic compiler output|Expect asm contains|Expect compiler output excludes|Compiler output mode):') { return $false }
        if ($text -match '(?m)^@\[entry\]') { return $false }
        $exitRaw = if ($text -match '(?m)^//\s*Expect exit code:\s*(.+)$') { $matches[1].Trim() } else { '0' }
        if ($exitRaw -ne '0') { return $false }
        if ([regex]::Matches($text, '(?m)^func main\s*\(').Count -ne 1) { return $false }
        return [regex]::Matches($text, '(?m)^func main\s*\(\s*\)\s*->\s*(u64|i64)').Count -eq 1
    })
    $concatenatedNumber = 0
    foreach ($concatGroup in @($expandedSuccessCandidates | Group-Object {
        $suiteClass = if ($_.Mode -eq 'nossa') { ($_.Name -split '::', 2)[0] } else { 'shared' }
        "$($_.Mode)|$($_.Opt)|$suiteClass"
    })) {
        $chunk = @($concatGroup.Group | Sort-Object Ordinal)
        if ($chunk.Count -lt 2) { continue }
        $concatenatedNumber += 1
        $chunkDir = Join-Path $BuildDir ("fast_concatenated_suite_{0:D3}" -f $concatenatedNumber)
        New-Item -ItemType Directory -Force -Path $chunkDir | Out-Null
        $concatUtf8 = New-Object System.Text.UTF8Encoding($false)
        $chunkParts = New-Object System.Collections.Generic.List[string]
        $chunkCalls = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $chunk.Count; $i++) {
            $entryName = "fast_suite_entry_$($i + 1)"
            $sourceText = [System.IO.File]::ReadAllText($chunk[$i].Path)
            $renamed = [regex]::Replace($sourceText, '(?m)^func main\s*\(', "func $entryName(", 1)
            if ($renamed -eq $sourceText) { throw "Concatenated suite entry not found: $($chunk[$i].Path)" }
            $chunkParts.Add($renamed)
            $chunkCalls.Add("    if ($entryName() != 0) { return $($i + 1); }")
        }
        $chunkParts.Add('func main() -> u64 {')
        foreach ($call in $chunkCalls) { $chunkParts.Add($call) }
        $chunkParts.Add('    return 0;')
        $chunkParts.Add('}')
        $chunkSource = Join-Path $chunkDir 'main.bpp'
        [System.IO.File]::WriteAllText($chunkSource, ($chunkParts -join "`n") + "`n", $concatUtf8)
        $chunkIds = @($chunk | ForEach-Object Id)
        $testVariants = @($testVariants | Where-Object { $chunkIds -notcontains $_.Id })
        $testVariants += [PSCustomObject]@{
            Id = "__fast_concatenated_suite_$concatenatedNumber|$($chunk[0].Mode)|$($chunk[0].Opt)"
            Hash = ''
            Ordinal = ($chunk.Ordinal | Measure-Object -Minimum).Minimum
            ArtifactStem = ("fast_concatenated_suite_{0:D3}" -f $concatenatedNumber)
            Path = $chunkSource
            Name = ("concatenated_suite_{0:D3}" -f $concatenatedNumber)
            Mode = $chunk[0].Mode
            Opt = $chunk[0].Opt
            Lines = @("// Mode: $($chunk[0].Mode)", "// Opt: $($chunk[0].Opt)", '// Expect exit code: 0')
            PhysicalKind = 'concatenated-suite'
            Members = $chunk
        }
    }

    # I/O fixtures cannot share one runtime because buffered input/output and
    # runtime globals intentionally persist within a process. They can still
    # share compilation: emit one selector-based executable, then launch that
    # executable once per logical fixture so every case gets a fresh runtime.
    $dispatchCandidates = @($testVariants | Where-Object {
        if ($_.PSObject.Properties['PhysicalKind']) { return $false }
        if ($_.Name -match '::' -and -not ($_.Name -match '^03_property_hooks_suite::' -and $_.Mode -eq 'nossa')) { return $false }
        if ($_.Name -match '^(42|43|46)_') { return $false }
        if ($_.Name -match '^03_property_hooks_suite::201_' -and $_.Mode -eq 'nossa') { return $false }
        if ($_.Path -match '[\\/]source_fail[\\/]') { return $false }
        $text = @($_.Lines) -join "`n"
        if ($text -match '(?m)^//\s*(Compiler args|Compile only|Expect deterministic compiler output|Expect asm contains|Expect compiler output excludes|Compiler output mode):') { return $false }
        if ($text -match '(?m)^@\[entry\]') { return $false }
        $exitRaw = if ($text -match '(?m)^//\s*Expect exit code:\s*(.+)$') { $matches[1].Trim() } else { '0' }
        if ($exitRaw -ne '0') { return $false }
        if ([regex]::Matches($text, '(?m)^func main\s*\(').Count -ne 1) { return $false }
        $noArgMain = [regex]::Matches($text, '(?m)^func main\s*\(\s*\)\s*->\s*(u64|i64)').Count -eq 1
        $argvMain = [regex]::Matches($text, '(?m)^func main\s*\(\s*argc\s*:\s*i64\s*,\s*argv\s*:\s*\*u64\s*\)\s*->\s*(u64|i64)').Count -eq 1
        return $noArgMain -or $argvMain
    })
    $dispatchNumber = 0
    foreach ($dispatchGroup in @($dispatchCandidates | Group-Object { "$($_.Mode)|$($_.Opt)" })) {
        $groupMembers = @($dispatchGroup.Group | Sort-Object Ordinal)
        for ($offset = 0; $offset -lt $groupMembers.Count; $offset += 10) {
            $last = [Math]::Min($offset + 9, $groupMembers.Count - 1)
            $chunk = @($groupMembers[$offset..$last])
            if ($chunk.Count -lt 2) { continue }
            $dispatchNumber += 1
            $chunkDir = Join-Path $BuildDir ("fast_dispatch_bundle_{0:D3}" -f $dispatchNumber)
            New-Item -ItemType Directory -Force -Path $chunkDir | Out-Null
            if (@($chunk | Where-Object { (@($_.Lines) -join "`n") -match '(?m)^\s*import\s+.*\bmodules\.' }).Count -gt 0) {
                $supportModules = Join-Path $RootDir 'test\source\modules'
                Copy-Item -LiteralPath $supportModules -Destination (Join-Path $chunkDir 'modules') -Recurse -Force
            }
            $dispatchUtf8 = New-Object System.Text.UTF8Encoding($false)
            $chunkImports = New-Object System.Collections.Generic.List[string]
            $chunkBranches = New-Object System.Collections.Generic.List[string]
            for ($i = 0; $i -lt $chunk.Count; $i++) {
                $moduleName = "case_$($i + 1)"
                $entryName = "fast_dispatch_entry_$($i + 1)"
                $sourceText = [System.IO.File]::ReadAllText($chunk[$i].Path)
                $moduleText = [regex]::Replace($sourceText, '(?m)^func main\s*\(', "func $entryName(", 1)
                if ($moduleText -eq $sourceText) { throw "Dispatch bundle entry not found: $($chunk[$i].Path)" }
                [System.IO.File]::WriteAllText((Join-Path $chunkDir "$moduleName.bpp"), $moduleText, $dispatchUtf8)
                $chunkImports.Add("import $entryName from $moduleName;")
                $selector = [char]([int][char]'0' + $i)
                $entryCall = if ($sourceText -match '(?m)^func main\s*\(\s*argc\s*:\s*i64\s*,\s*argv\s*:\s*\*u64\s*\)') {
                    "$entryName(argc - 1, argv)"
                } else {
                    "$entryName()"
                }
                $chunkBranches.Add("    if (selector == (u8)'$selector') { return (i64)$entryCall; }")
            }
            $chunkSource = Join-Path $chunkDir 'main.bpp'
            $chunkText = @($chunkImports) + @(
                '',
                'func main(argc: i64, argv: *u64) -> i64 {',
                '    if (argc < 2) { return 125; }',
                '    var selector_ptr: u64 = argv[1];',
                '    var selector: u8 = ((*u8)selector_ptr)[0];'
            ) + @($chunkBranches) + @('    return 126;', '}')
            [System.IO.File]::WriteAllText($chunkSource, ($chunkText -join "`n") + "`n", $dispatchUtf8)
            $chunkIds = @($chunk | ForEach-Object Id)
            $testVariants = @($testVariants | Where-Object { $chunkIds -notcontains $_.Id })
            $testVariants += [PSCustomObject]@{
                Id = "__fast_dispatch_bundle_$dispatchNumber|$($chunk[0].Mode)|$($chunk[0].Opt)"
                Hash = ''
                Ordinal = ($chunk.Ordinal | Measure-Object -Minimum).Minimum
                ArtifactStem = ("fast_dispatch_bundle_{0:D3}" -f $dispatchNumber)
                Path = $chunkSource
                Name = ("dispatch_bundle_{0:D3}" -f $dispatchNumber)
                Mode = $chunk[0].Mode
                Opt = $chunk[0].Opt
                Lines = @("// Mode: $($chunk[0].Mode)", "// Opt: $($chunk[0].Opt)", '// Expect exit code: 0')
                PhysicalKind = 'dispatch-bundle'
                Members = $chunk
            }
        }
    }

    # Expected failures use compiler-hosted batches. The compiler resets request
    # state between sources, captures one canonical diagnostic per source, and
    # executes only the backend/optimization requests relevant to that failure
    # phase. Compiler-argument contract cases stay on the ordinary CLI path.
    $failureBatchGroups = New-Object System.Collections.Generic.List[object]
    foreach ($failureGroup in @($testVariants | Where-Object {
        (-not $_.PSObject.Properties['PhysicalKind']) -and
        ((@($_.Lines) -join "`n") -match '(?m)^//\s*Expect compile fail:\s*(1|true|yes)\s*$') -and
        ((@($_.Lines) -join "`n") -notmatch '(?m)^//\s*Compiler args:')
    } | Group-Object Name)) {
        $failureMembers = @($failureGroup.Group | Sort-Object Ordinal)
        if (@($failureMembers | Where-Object { $_.Opt -notin @('O0', 'O1') }).Count -ne 0) { continue }
        $memberPaths = @($failureMembers.Path | Sort-Object -Unique)
        if ($memberPaths.Count -ne 1) { continue }

        $modeMask = 0
        if (@($failureMembers | Where-Object Mode -eq 'nossa').Count -ne 0) { $modeMask = $modeMask -bor 1 }
        if (@($failureMembers | Where-Object Mode -eq 'ssa').Count -ne 0) { $modeMask = $modeMask -bor 2 }
        $optMask = 0
        if (@($failureMembers | Where-Object Opt -eq 'O0').Count -ne 0) { $optMask = $optMask -bor 1 }
        if (@($failureMembers | Where-Object Opt -eq 'O1').Count -ne 0) { $optMask = $optMask -bor 2 }
        if ($modeMask -eq 0 -or $optMask -eq 0) { continue }

        $sourceLength = (Get-Item -LiteralPath $memberPaths[0]).Length
        $estimate = [int64](20000 + $sourceLength) * [Math]::Max(1, @($failureMembers.Mode | Sort-Object -Unique).Count)
        if ($failureGroup.Name -match 'complexity') { $estimate += 200000 }
        $failureBatchGroups.Add([PSCustomObject]@{
            Name = $failureGroup.Name
            Path = $memberPaths[0]
            ModeMask = $modeMask
            OptMask = $optMask
            Estimate = $estimate
            Members = $failureMembers
        })
    }

    if ($failureBatchGroups.Count -gt 0) {
        $failureBatchCount = [Math]::Min(84, $failureBatchGroups.Count)
        $failureBatchDir = Join-Path $BuildDir 'failure_batches'
        New-Item -ItemType Directory -Force -Path $failureBatchDir | Out-Null
        Get-ChildItem -LiteralPath $failureBatchDir -Filter '*.manifest' -File -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
        $failureBuckets = @()
        for ($i = 0; $i -lt $failureBatchCount; $i++) {
            $failureBuckets += [PSCustomObject]@{
                Index = $i
                Estimate = [int64]0
                Groups = New-Object System.Collections.Generic.List[object]
            }
        }
        foreach ($group in @($failureBatchGroups | Sort-Object Estimate -Descending)) {
            $bucket = $failureBuckets | Sort-Object Estimate, Index | Select-Object -First 1
            $bucket.Groups.Add($group)
            $bucket.Estimate += $group.Estimate
        }

        $batchedIds = @($failureBatchGroups | ForEach-Object { $_.Members } | ForEach-Object Id)
        $testVariants = @($testVariants | Where-Object { $batchedIds -notcontains $_.Id })
        $batchUtf8 = New-Object System.Text.UTF8Encoding($false)
        foreach ($bucket in @($failureBuckets | Sort-Object Index)) {
            $groups = $bucket.Groups.ToArray()
            if ($groups.Count -eq 0) { continue }
            $batchNumber = $bucket.Index + 1
            $manifestPath = Join-Path $failureBatchDir ("batch_{0:D2}.manifest" -f $batchNumber)
            $manifestLines = @($groups | ForEach-Object { "$($_.ModeMask)`t$($_.OptMask)`t$($_.Path)" })
            [System.IO.File]::WriteAllLines($manifestPath, $manifestLines, $batchUtf8)
            $batchMembers = @($groups | ForEach-Object { $_.Members })
            $firstMember = $batchMembers[0]
            $testVariants += [PSCustomObject]@{
                Id = ("__fast_failure_batch_{0:D2}|nossa|O0" -f $batchNumber)
                Hash = ''
                Ordinal = ($batchMembers.Ordinal | Measure-Object -Minimum).Minimum
                ArtifactStem = ("fast_failure_batch_{0:D2}" -f $batchNumber)
                Path = $manifestPath
                Name = ("failure_batch_{0:D2}" -f $batchNumber)
                Mode = $firstMember.Mode
                Opt = $firstMember.Opt
                Lines = @('// Expect compile fail: true')
                PhysicalKind = 'failure-batch'
                ManifestPath = $manifestPath
                FailureGroups = $groups
                Members = $batchMembers
            }
        }
    }

    # CLI-specific failures still share a canonical request when their source
    # declares equivalent variants, while preserving their custom arguments.
    foreach ($failureGroup in @($testVariants | Where-Object {
        (-not $_.PSObject.Properties['PhysicalKind']) -and
        ((@($_.Lines) -join "`n") -match '(?m)^//\s*Expect compile fail:\s*(1|true|yes)\s*$')
    } | Group-Object Name)) {
        $failureMembers = @($failureGroup.Group | Sort-Object Ordinal)
        if ($failureMembers.Count -lt 2) { continue }
        $canonical = $failureMembers[0]
        $failureIds = @($failureMembers | ForEach-Object Id)
        $testVariants = @($testVariants | Where-Object { $failureIds -notcontains $_.Id })
        $canonical | Add-Member -NotePropertyName PhysicalKind -NotePropertyValue 'phase-aware-failures' -Force
        $canonical | Add-Member -NotePropertyName Members -NotePropertyValue $failureMembers -Force
        $testVariants += $canonical
    }
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
$EffectiveJobs = [Math]::Max(1, [Math]::Min(32, $EffectiveJobs))

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
    $memberPassed = New-Object System.Collections.Generic.List[bool]
    $memberStatus = New-Object System.Collections.Generic.List[string]
    $memberDiagnostic = New-Object System.Collections.Generic.List[string]
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
        $expectDeterministicCompilerOutput = Read-Bool $lines '^//\s*Expect deterministic compiler output:\s*(.+)$'
        $compilerOutputMode = Read-One $lines '^//\s*Compiler output mode:\s*(.+)$'
        if (-not $compilerOutputMode) { $compilerOutputMode = "-asm" }
        $compilerArgs = @((Read-One $lines '^//\s*Compiler args:\s*(.+)$') -split '\s+' | Where-Object { $_ })
        $stdinText = [System.Text.RegularExpressions.Regex]::Unescape((Read-One $lines '^//\s*Stdin:\s*(.+)$'))
        $expectedStdout = [System.Text.RegularExpressions.Regex]::Unescape((Read-One $lines '^//\s*Expect stdout:\s*(.+)$'))
        $expectErrContains = @(Read-Many $lines '^//\s*Expect error contains:\s*(.+)$')
        $expectAsmContains = @(Read-Many $lines '^//\s*Expect asm contains:\s*(.+)$')
        $expectCompilerOutputExcludes = @(Read-Many $lines '^//\s*Expect compiler output excludes:\s*(.+)$')
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
        # On hosted Windows runners the compiler's deferred timing writer can
        # fault while unwinding an expected diagnostic. The runner still records
        # wall/CPU/memory metrics for these cases, so only request compiler phase
        # timing for compilations that are expected to succeed.
        if ($compilerTimingFile -and -not $expectCompileFail) {
            $args += @("--timings-json", $compilerTimingFile)
        }
        $args += @($compilerOutputMode, $Case.Path)

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
            if ($expectErrContains.Count -gt 0) {
                $errText = if (Test-Path -LiteralPath $errFile) { Get-Content -LiteralPath $errFile -Raw } else { "" }
                $missing = @($expectErrContains | Where-Object { $errText.IndexOf($_, [System.StringComparison]::Ordinal) -lt 0 })
                if ($missing.Count -gt 0) {
                    $caseOk = $false; $status = "FAIL (compiler stderr mismatch: $($missing[0]))"
                }
            }
            if ($expectDeterministicCompilerOutput) {
                $repeatOutputFile = "$asmFile.repeat"
                $repeatErrorFile = "$errFile.repeat"
                foreach ($path in @($repeatOutputFile, $repeatErrorFile)) {
                    if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
                }
                $repeatResult = Invoke-BppLimitedProcess -FilePath $Config.CompilerPath -ArgumentList $args `
                    -TimeoutMs $Config.CompilerTimeoutMs -StdoutPath $repeatOutputFile -StderrPath $repeatErrorFile `
                    -WorkingDirectory $Config.RootDir -MemoryLimitBytes $Config.MemoryLimitBytes
                if ($repeatResult.ExitCode -ne 0) {
                    $caseOk = $false; $status = "FAIL (determinism rerun)"
                } else {
                    $firstHash = (Get-FileHash -LiteralPath $asmFile -Algorithm SHA256).Hash
                    $repeatHash = (Get-FileHash -LiteralPath $repeatOutputFile -Algorithm SHA256).Hash
                    if ($firstHash -ne $repeatHash) {
                        $caseOk = $false; $status = "FAIL (nondeterministic compiler output)"
                    }
                }
            }
            if ($expectAsmContains.Count -gt 0) {
                $asmText = Get-Content -LiteralPath $asmFile -Raw
                $missingAsm = @($expectAsmContains | Where-Object { $asmText.IndexOf($_, [System.StringComparison]::Ordinal) -lt 0 })
                if ($missingAsm.Count -gt 0) {
                    $caseOk = $false; $status = "FAIL (asm mismatch: $($missingAsm[0]))"
                }
            }
            if ($expectCompilerOutputExcludes.Count -gt 0) {
                $compilerOutputText = Get-Content -LiteralPath $asmFile -Raw
                $unexpectedOutput = @($expectCompilerOutputExcludes | Where-Object { $compilerOutputText.IndexOf($_, [System.StringComparison]::Ordinal) -ge 0 })
                if ($unexpectedOutput.Count -gt 0) {
                    $caseOk = $false; $status = "FAIL (compiler output unexpectedly contains: $($unexpectedOutput[0]))"
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
                    } elseif ($Case.PSObject.Properties['PhysicalKind'] -and $Case.PhysicalKind -eq 'dispatch-bundle') {
                        $dispatchMembers = @($Case.Members)
                        for ($dispatchIndex = 0; $dispatchIndex -lt $dispatchMembers.Count; $dispatchIndex++) {
                            $dispatchMember = $dispatchMembers[$dispatchIndex]
                            $dispatchLines = @($dispatchMember.Lines)
                            $dispatchExit = 0
                            $dispatchExitRaw = Read-One $dispatchLines '^//\s*Expect exit code:\s*(.+)$'
                            if ($dispatchExitRaw) { [void][int]::TryParse($dispatchExitRaw, [ref]$dispatchExit) }
                            $dispatchStdin = [Text.RegularExpressions.Regex]::Unescape((Read-One $dispatchLines '^//\s*Stdin:\s*(.+)$'))
                            $dispatchStdout = [Text.RegularExpressions.Regex]::Unescape((Read-One $dispatchLines '^//\s*Expect stdout:\s*(.+)$'))
                            $runResult = Invoke-BppLimitedProcess -FilePath $exeFile -ArgumentList @([string]$dispatchIndex) `
                                -TimeoutMs $Config.TimeoutMs -StdinText $dispatchStdin -WorkingDirectory $Config.RootDir `
                                -MemoryLimitBytes $Config.MemoryLimitBytes
                            $portableExit = if ($runResult.ExitCode -eq -1073741795) { 132 } else { $runResult.ExitCode }
                            $dispatchOk = $portableExit -eq $dispatchExit -and
                                ($dispatchStdout -eq '' -or $runResult.Stdout -eq $dispatchStdout)
                            $memberPassed.Add($dispatchOk)
                            if ($portableExit -ne $dispatchExit) {
                                $memberStatus.Add("FAIL (exit=$($runResult.ExitCode) expect=$dispatchExit)")
                                $memberDiagnostic.Add('')
                            } elseif ($dispatchStdout -ne '' -and $runResult.Stdout -ne $dispatchStdout) {
                                $memberStatus.Add('FAIL (stdout mismatch)')
                                $memberDiagnostic.Add("expected=<$dispatchStdout> actual=<$($runResult.Stdout)>")
                            } else {
                                $memberStatus.Add('PASS (shared compile; isolated runtime)')
                                $memberDiagnostic.Add('')
                            }
                        }
                        $caseOk = @($memberPassed | Where-Object { -not $_ }).Count -eq 0
                        $status = if ($caseOk) { 'PASS (shared compile; isolated runtimes)' } else { 'FAIL (dispatch member)' }
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
        errorPath = $errFile
        compilerTimingsPath = $compilerTimingFile
        memberPassed = $memberPassed.ToArray()
        memberStatus = $memberStatus.ToArray()
        memberDiagnostic = $memberDiagnostic.ToArray()
        timing = [PSCustomObject]@{
            totalMs = [Math]::Round($caseClock.Elapsed.TotalMilliseconds, 3)
            compile = To-Metric $compileResult
            assemble = To-Metric $assembleResult
            link = To-Metric $linkResult
            run = To-Metric $runResult
        }
    }
}

$phaseAwareFailureWorkerScript = {
    param($Group, $Config, [string]$OneWorkerSource)
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    $oneWorker = [scriptblock]::Create($OneWorkerSource)
    $groupClock = [Diagnostics.Stopwatch]::StartNew()
    $members = @($Group.Members)
    $first = & $oneWorker $members[0] $Config
    $aggregateOk = $first.passed
    $aggregateStatus = $first.status
    $aggregateDiagnostic = $first.diagnostic
    $phase = ''
    if ($first.errorPath -and (Test-Path -LiteralPath $first.errorPath)) {
        $errorText = Get-Content -LiteralPath $first.errorPath -Raw
        if ($errorText -match '\[ERROR\]\[([^\]]+)\]') { $phase = $matches[1] }
    }

    # Parser/type identity diagnostics happen before backend or optimization
    # selection. One canonical request therefore proves every declared variant.
    $safeFrontEndPhase = $phase -in @('parse', 'validation', 'typecheck', 'generic', 'lowering')
    if ($aggregateOk -and -not $safeFrontEndPhase) {
        $remainingMembers = if (-not $phase) {
            # Legacy diagnostics without a stage tag have two proven output
            # classes: legacy and SSA. The O0/O1 diagnostics within each class
            # are byte-identical in the frozen full-suite baseline, so execute
            # one representative for the other backend and retain both modes.
            @($members | Where-Object Mode -ne $members[0].Mode | Group-Object Mode | ForEach-Object { $_.Group | Select-Object -First 1 })
        } else {
            @($members | Select-Object -Skip 1)
        }
        foreach ($remainingMember in $remainingMembers) {
            $next = & $oneWorker $remainingMember $Config
            if (-not $next.passed) {
                $aggregateOk = $false
                $aggregateStatus = $next.status
                $aggregateDiagnostic = $next.diagnostic
                break
            }
        }
    }
    $groupClock.Stop()
    $first.passed = $aggregateOk
    $first.status = if ($aggregateOk -and $safeFrontEndPhase) {
        "PASS (front-end phase $phase)"
    } elseif ($aggregateOk) {
        'PASS (all backend-sensitive variants)'
    } else {
        $aggregateStatus
    }
    $first.diagnostic = $aggregateDiagnostic
    $first.timing.totalMs = [Math]::Round($groupClock.Elapsed.TotalMilliseconds, 3)
    return $first
}

$failureBatchWorkerScript = {
    param($Batch, $Config)
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    if (-not (Get-Command Invoke-BppLimitedProcess -CommandType Function -ErrorAction SilentlyContinue)) {
        . $Config.ProcessHelper
    }

    function To-BatchMetric($ProcessResult) {
        if ($null -eq $ProcessResult) { return $null }
        return [PSCustomObject]@{
            wallMs = $ProcessResult.WallTimeMs
            cpuMs = $ProcessResult.CpuTimeMs
            peakWorkingSetBytes = $ProcessResult.PeakWorkingSetBytes
        }
    }

    $clock = [Diagnostics.Stopwatch]::StartNew()
    $stdoutPath = Join-Path $Config.ResultDir "$($Batch.ArtifactStem).stdout"
    $stderrPath = Join-Path $Config.ResultDir "$($Batch.ArtifactStem).stderr"
    foreach ($path in @($stdoutPath, $stderrPath)) {
        if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
    }
    $memberPassed = New-Object System.Collections.Generic.List[bool]
    $memberStatus = New-Object System.Collections.Generic.List[string]
    $memberDiagnostic = New-Object System.Collections.Generic.List[string]
    $processResult = $null
    $fatalStatus = ''
    $fatalDiagnostic = ''

    try {
        $processResult = Invoke-BppLimitedProcess -FilePath $Config.CompilerPath `
            -ArgumentList @('--batch-fail-manifest', $Batch.ManifestPath) `
            -TimeoutMs $Config.CompilerTimeoutMs -StdoutPath $stdoutPath -StderrPath $stderrPath `
            -WorkingDirectory $Config.RootDir -MemoryLimitBytes $Config.MemoryLimitBytes
        if ($processResult.TimedOut) {
            throw 'failure batch compiler timeout'
        }
        if ($processResult.ExitCode -lt 0 -or $processResult.ExitCode -ge 128) {
            throw "failure batch compiler crash exit=$($processResult.ExitCode)"
        }
        if ($processResult.ExitCode -ne 0) {
            throw "failure batch compiler exit=$($processResult.ExitCode)"
        }
        $stderrText = if (Test-Path -LiteralPath $stderrPath) { [IO.File]::ReadAllText($stderrPath) } else { '' }
        if ($stderrText.Length -ne 0) {
            throw "failure batch leaked stderr: $($stderrText.Trim())"
        }

        $bytes = [IO.File]::ReadAllBytes($stdoutPath)
        $ascii = [Text.Encoding]::ASCII
        $utf8 = New-Object Text.UTF8Encoding($false, $true)
        $cursor = 0
        $groups = @($Batch.FailureGroups)
        for ($groupIndex = 0; $groupIndex -lt $groups.Count; $groupIndex++) {
            $lineEnd = $cursor
            while ($lineEnd -lt $bytes.Length -and $bytes[$lineEnd] -ne 10) { $lineEnd += 1 }
            if ($lineEnd -ge $bytes.Length) { throw "truncated batch header at group $groupIndex" }
            $headerLength = $lineEnd - $cursor
            if ($headerLength -gt 0 -and $bytes[$lineEnd - 1] -eq 13) { $headerLength -= 1 }
            $header = $ascii.GetString($bytes, $cursor, $headerLength)
            if ($header -notmatch '^BPPB ([0-9]+) ([01]) ([0-9]+)$') {
                throw "invalid batch header at group $groupIndex`: $header"
            }
            if ([int]$matches[1] -ne $groupIndex) {
                throw "out-of-order batch result: got $($matches[1]), expected $groupIndex"
            }
            $failedAsExpected = $matches[2] -eq '1'
            $diagnosticLength = [int]$matches[3]
            $cursor = $lineEnd + 1
            if ($diagnosticLength -lt 0 -or $cursor + $diagnosticLength -gt $bytes.Length) {
                throw "invalid diagnostic length at group $groupIndex"
            }
            $diagnosticText = $utf8.GetString($bytes, $cursor, $diagnosticLength)
            $cursor += $diagnosticLength
            if ($cursor -ge $bytes.Length -or $bytes[$cursor] -ne 10) {
                throw "missing diagnostic terminator at group $groupIndex"
            }
            $cursor += 1

            $group = $groups[$groupIndex]
            foreach ($member in @($group.Members)) {
                $expected = @()
                foreach ($line in @($member.Lines)) {
                    if ($line -match '^//\s*Expect error contains:\s*(.+)$') {
                        $value = $matches[1].Trim()
                        if ($value) { $expected += $value }
                    }
                }
                $missing = @($expected | Where-Object {
                    $diagnosticText.IndexOf($_, [StringComparison]::Ordinal) -lt 0
                })
                $ok = $failedAsExpected -and $missing.Count -eq 0
                $memberPassed.Add($ok)
                if (-not $failedAsExpected) {
                    $memberStatus.Add('FAIL (unexpected compile success in shared batch)')
                    $memberDiagnostic.Add($diagnosticText)
                } elseif ($missing.Count -ne 0) {
                    $memberStatus.Add("FAIL (compile error mismatch: $($missing[0]))")
                    $memberDiagnostic.Add($diagnosticText)
                } else {
                    $memberStatus.Add('PASS (expected compile fail; shared batch)')
                    $memberDiagnostic.Add('')
                }
            }
        }
        while ($cursor -lt $bytes.Length -and ($bytes[$cursor] -eq 10 -or $bytes[$cursor] -eq 13 -or $bytes[$cursor] -eq 32 -or $bytes[$cursor] -eq 9)) {
            $cursor += 1
        }
        if ($cursor -ne $bytes.Length) { throw 'unexpected trailing batch output' }
        if ($memberPassed.Count -ne @($Batch.Members).Count) {
            throw "batch result count mismatch: $($memberPassed.Count) != $(@($Batch.Members).Count)"
        }
    } catch {
        $fatalStatus = 'FAIL (failure batch runner)'
        $fatalDiagnostic = $_.Exception.Message
        $memberPassed.Clear()
        $memberStatus.Clear()
        $memberDiagnostic.Clear()
        foreach ($member in @($Batch.Members)) {
            $memberPassed.Add($false)
            $memberStatus.Add($fatalStatus)
            $memberDiagnostic.Add($fatalDiagnostic)
        }
    }

    $clock.Stop()
    $allPassed = $memberPassed.Count -eq @($Batch.Members).Count -and @($memberPassed | Where-Object { -not $_ }).Count -eq 0
    return [PSCustomObject]@{
        id = $Batch.Id
        ordinal = $Batch.Ordinal
        name = $Batch.Name
        mode = $Batch.Mode
        opt = $Batch.Opt
        passed = $allPassed
        status = if ($allPassed) { 'PASS (shared failure batch)' } else { $fatalStatus }
        diagnostic = $fatalDiagnostic
        errorPath = $stderrPath
        compilerTimingsPath = ''
        memberPassed = $memberPassed.ToArray()
        memberStatus = $memberStatus.ToArray()
        memberDiagnostic = $memberDiagnostic.ToArray()
        timing = [PSCustomObject]@{
            totalMs = [Math]::Round($clock.Elapsed.TotalMilliseconds, 3)
            compile = To-BatchMetric $processResult
            assemble = $null
            link = $null
            run = $null
        }
    }
}

function Add-LogicalResults {
    param(
        [System.Collections.Generic.List[object]]$Destination,
        $PhysicalVariant,
        $PhysicalResult
    )

    if (-not $PhysicalVariant.PSObject.Properties['Members']) {
        $Destination.Add($PhysicalResult)
        return
    }

    $members = @($PhysicalVariant.Members)
    $hasMemberOutcomes = $null -ne $PhysicalResult.PSObject.Properties['memberPassed']
    $memberPassedValues = @()
    $memberStatusValues = @()
    $memberDiagnosticValues = @()
    if ($hasMemberOutcomes) {
        $memberPassedValues = @($PhysicalResult.memberPassed)
        $memberStatusValues = @($PhysicalResult.memberStatus)
        $memberDiagnosticValues = @($PhysicalResult.memberDiagnostic)
    }
    $hasMemberOutcomes = $hasMemberOutcomes -and $memberPassedValues.Count -eq $members.Count
    for ($i = 0; $i -lt $members.Count; $i++) {
        $member = $members[$i]
        $sharedTiming = if ($i -eq 0) {
            $PhysicalResult.timing
        } else {
            [PSCustomObject]@{ totalMs = 0; compile = $null; assemble = $null; link = $null; run = $null }
        }
        $thisPassed = if ($hasMemberOutcomes) { [bool]$memberPassedValues[$i] } else { [bool]$PhysicalResult.passed }
        $thisStatus = if ($hasMemberOutcomes) {
            [string]$memberStatusValues[$i]
        } elseif ($PhysicalResult.passed) {
            "PASS (shared $($PhysicalVariant.PhysicalKind))"
        } else {
            $PhysicalResult.status
        }
        $thisDiagnostic = if ($hasMemberOutcomes) { [string]$memberDiagnosticValues[$i] } else { $PhysicalResult.diagnostic }
        $Destination.Add([PSCustomObject]@{
            id = $member.Id
            ordinal = $member.Ordinal
            name = $member.Name
            mode = $member.Mode
            opt = $member.Opt
            passed = $thisPassed
            status = $thisStatus
            diagnostic = $thisDiagnostic
            compilerTimingsPath = if ($i -eq 0) { $PhysicalResult.compilerTimingsPath } else { '' }
            physicalGroup = $PhysicalVariant.Id
            timing = $sharedTiming
        })
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
Write-Host "[INFO] Plan       : $($testVariants.Count) physical / $LogicalVariantCount logical cases"
$planKinds = @($testVariants | Group-Object {
    if ($_.PSObject.Properties['PhysicalKind']) { $_.PhysicalKind } else { 'isolated' }
} | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Count)" })
Write-Host "[INFO] Plan kinds : $($planKinds -join ', ')"
if ($EffectiveNameFilter) { Write-Host "[INFO] Name filter: $EffectiveNameFilter" }
Write-Host ""
if ($PlanOnly) {
    Complete-DefaultPipelineSmoke -Smoke $defaultPipelineSmoke
    return
}

$suiteClock = [System.Diagnostics.Stopwatch]::StartNew()
$results = New-Object System.Collections.Generic.List[object]
$physicalVariants = @($testVariants | Sort-Object `
    @{ Expression = { Get-VariantEstimatedCost -Variant $_ }; Descending = $true }, `
    @{ Expression = { $_.Ordinal }; Descending = $false })
if ($EffectiveJobs -eq 1) {
    foreach ($variant in $physicalVariants) {
        $result = if ($variant.PSObject.Properties['PhysicalKind'] -and $variant.PhysicalKind -eq 'failure-batch') {
            & $failureBatchWorkerScript $variant $workerConfig
        } elseif ($variant.PSObject.Properties['PhysicalKind'] -and $variant.PhysicalKind -eq 'phase-aware-failures') {
            & $phaseAwareFailureWorkerScript $variant $workerConfig $workerScript.ToString()
        } else {
            & $workerScript $variant $workerConfig
        }
        Add-LogicalResults -Destination $results -PhysicalVariant $variant -PhysicalResult $result
    }
} else {
    $pool = [RunspaceFactory]::CreateRunspacePool(1, $EffectiveJobs)
    $pending = New-Object System.Collections.Generic.List[object]
    try {
        $pool.Open()
        foreach ($variant in $physicalVariants) {
            $powerShell = [PowerShell]::Create()
            $powerShell.RunspacePool = $pool
            if ($variant.PSObject.Properties['PhysicalKind'] -and $variant.PhysicalKind -eq 'failure-batch') {
                [void]$powerShell.AddScript($failureBatchWorkerScript.ToString()).AddArgument($variant).AddArgument($workerConfig)
            } elseif ($variant.PSObject.Properties['PhysicalKind'] -and $variant.PhysicalKind -eq 'phase-aware-failures') {
                [void]$powerShell.AddScript($phaseAwareFailureWorkerScript.ToString()).AddArgument($variant).AddArgument($workerConfig).AddArgument($workerScript.ToString())
            } else {
                [void]$powerShell.AddScript($workerScript.ToString()).AddArgument($variant).AddArgument($workerConfig)
            }
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
                Add-LogicalResults -Destination $results -PhysicalVariant $item.Variant -PhysicalResult $output[0]
            } catch {
                $runspaceFailure = [PSCustomObject]@{
                    id = $item.Variant.Id; ordinal = $item.Variant.Ordinal
                    name = $item.Variant.Name; mode = $item.Variant.Mode; opt = $item.Variant.Opt
                    passed = $false; status = "FAIL (runspace error)"
                    diagnostic = $_.Exception.Message
                    compilerTimingsPath = ""
                    timing = [PSCustomObject]@{ totalMs = 0; compile = $null; assemble = $null; link = $null; run = $null }
                }
                Add-LogicalResults -Destination $results -PhysicalVariant $item.Variant -PhysicalResult $runspaceFailure
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
Complete-DefaultPipelineSmoke -Smoke $defaultPipelineSmoke

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
