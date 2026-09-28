[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CompilerPath,
    [UInt64]$MemoryLimitBytes = 4294967296,
    [int]$CompilerTimeoutMs = 600000,
    [string]$NasmPath = '',
    [string]$LinkerPath = ''
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
. (Join-Path $repo 'tools/windows_process.ps1')
$compiler = (Resolve-Path -LiteralPath $CompilerPath).Path
$work = Join-Path $repo ('build/cache-tests-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$cache = Join-Path $work 'cache'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$entry = Join-Path $work 'entry.bpp'
$dep = Join-Path $work 'dependency.bpp'
$leaf = Join-Path $work 'leaf.bpp'
$manifest = Join-Path $work 'bpp.toml'
$library = Join-Path $work 'library'
New-Item -ItemType Directory -Path $library | Out-Null
Copy-Item -LiteralPath (Join-Path $repo 'src/std') -Destination $library -Recurse
$manifestText = 'std_root=' + $library.Replace('\','/') + "`n"
if ($NasmPath) { $manifestText += 'nasm_path=' + (Resolve-Path -LiteralPath $NasmPath).Path.Replace('\','/') + "`n" }
if ($LinkerPath) { $manifestText += 'ld_path=' + (Resolve-Path -LiteralPath $LinkerPath).Path.Replace('\','/') + "`n" }
[IO.File]::WriteAllText($manifest, $manifestText, $utf8)
$entryText = "import dependency;`nfunc main() -> u64 { return dependency_value() - 1; }`n"
[IO.File]::WriteAllText($entry, $entryText, $utf8)
[IO.File]::WriteAllText($dep, "import leaf;`nfunc dependency_value() -> u64 { return leaf_value(); }`n", $utf8)
[IO.File]::WriteAllText($leaf, "func leaf_value() -> u64 { return 1; }`n", $utf8)
$results = New-Object System.Collections.Generic.List[object]

function Invoke-CacheCase {
    param([string]$Name, [int]$Status, [string[]]$Options = @(), [string]$Binary = $compiler,
          [string]$CacheDirectory = $cache, [switch]$Fail, [switch]$Execute,
          [switch]$PreparseHit, [switch]$ParsedHit)
    $output = Join-Path $work "$Name.out"
    $errorFile = Join-Path $work "$Name.err"
    $timing = Join-Path $work "$Name.json"
    $arguments = @('--target','windows-x86_64','--cache-dir',$CacheDirectory,'--cache-report','--timings-json',$timing) + $Options
    if (-not $Execute) { $arguments += '-asm' }
    $arguments += $entry
    $result = Invoke-BppLimitedProcess -FilePath $Binary -ArgumentList $arguments -TimeoutMs $CompilerTimeoutMs -StdoutPath $output -StderrPath $errorFile -WorkingDirectory $work -MemoryLimitBytes $MemoryLimitBytes
    $errorText = [IO.File]::ReadAllText($errorFile)
    if ($Fail) {
        if ($result.ExitCode -eq 0 -or $errorText -match '\[cache\] (hit|stored)') { throw "$Name reused or published an invalid program" }
    } else {
        if ($result.ExitCode -ne 0) { throw "$Name exit=$($result.ExitCode): $errorText" }
        $profile = Get-Content -LiteralPath $timing -Raw | ConvertFrom-Json
        if ($profile.artifactCache.status -ne $Status) { throw "$Name cache status $($profile.artifactCache.status), expected $Status`: $errorText" }
        if ($Status -eq 2 -and ($profile.phases.loweringMs -ne 0 -or $profile.phases.codegenMs -ne 0)) { throw "$Name did not skip lowering/codegen" }
        if ($PreparseHit -and $profile.artifactCache.preparseHit -ne 1) { throw "$Name did not use the preparse cache path" }
        if ($ParsedHit -and $profile.artifactCache.preparseHit -ne 0) { throw "$Name unexpectedly bypassed parsing" }
    }
    $hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
    $results.Add([pscustomobject]@{ name=$Name; status=$Status; wallMs=$result.WallTimeMs; cpuMs=$result.CpuTimeMs; peakBytes=$result.PeakWorkingSetBytes; outputHash=$hash })
    Write-Host "[PASS] cache $Name"
    return $hash
}

function Invoke-IncrementalCase {
    param(
        [string]$Name,
        [string]$Source,
        [string]$CacheDirectory,
        [int]$ExpectedStatus,
        [switch]$NoCache
    )
    $output = Join-Path $work "$Name.out"
    $errorFile = Join-Path $work "$Name.err"
    $timing = Join-Path $work "$Name.json"
    $arguments = @('--target','windows-x86_64','--cache-dir',$CacheDirectory,'--cache-report','--timings-json',$timing)
    if ($NoCache) { $arguments += '--no-cache' }
    $arguments += @('-asm',$Source)
    $result = Invoke-BppLimitedProcess -FilePath $compiler -ArgumentList $arguments -TimeoutMs $CompilerTimeoutMs -StdoutPath $output -StderrPath $errorFile -WorkingDirectory $work -MemoryLimitBytes $MemoryLimitBytes
    $errorText = [IO.File]::ReadAllText($errorFile)
    if ($result.ExitCode -ne 0) { throw "$Name exit=$($result.ExitCode): $errorText" }
    $profile = Get-Content -LiteralPath $timing -Raw | ConvertFrom-Json
    if ($profile.artifactCache.status -ne $ExpectedStatus) { throw "$Name cache status $($profile.artifactCache.status), expected $ExpectedStatus" }
    $hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
    $results.Add([pscustomobject]@{
        name=$Name
        status=$ExpectedStatus
        wallMs=$result.WallTimeMs
        cpuMs=$result.CpuTimeMs
        peakBytes=$result.PeakWorkingSetBytes
        outputHash=$hash
        incrementalLookups=$profile.incrementalCache.lookups
        incrementalHits=$profile.incrementalCache.hits
        incrementalStores=$profile.incrementalCache.stores
    })
    Write-Host "[PASS] incremental cache $Name"
    return [pscustomobject]@{ Hash=$hash; Profile=$profile }
}

# Fine-grained reuse: function bodies may change without changing the exact
# non-body semantic environment. Signature changes and damaged manifests must
# conservatively invalidate all fragments.
$incrementalRoot = Join-Path $work 'incremental'
$incrementalCache = Join-Path $work 'incremental-cache'
New-Item -ItemType Directory -Path $incrementalRoot,$incrementalCache | Out-Null
$incrementalEntry = Join-Path $incrementalRoot 'entry.bpp'
$incrementalDep = Join-Path $incrementalRoot 'incremental_dep.bpp'
$incrementalEntryOriginal = @"
import incremental_dep_value from incremental_dep;
func incremental_local_keep(x: u64) -> u64 { return x + 1; }
func incremental_local_change(x: u64) -> u64 { return x + 3; }
func main() -> u64 {
    var value: u64 = incremental_local_keep(4) + incremental_local_change(5) + incremental_dep_value(2);
    if (value != 17) { return 1; }
    return 0;
}
"@
[IO.File]::WriteAllText($incrementalEntry, $incrementalEntryOriginal, $utf8)
[IO.File]::WriteAllText($incrementalDep, "func incremental_dep_value(x: u64) -> u64 { return x + 2; }`n", $utf8)
$incrementalCold = Invoke-IncrementalCase incremental_cold $incrementalEntry $incrementalCache 1
if ($incrementalCold.Profile.incrementalCache.hits -ne 0 -or $incrementalCold.Profile.incrementalCache.stores -le 0) { throw 'Incremental cold build did not populate fragments' }
$incrementalWarm = Invoke-IncrementalCase incremental_unchanged_warm $incrementalEntry $incrementalCache 2
if ($incrementalWarm.Hash -ne $incrementalCold.Hash) { throw 'Incremental unchanged warm output differs' }

$incrementalEntryLocalChange = $incrementalEntryOriginal.Replace('return x + 3;', 'return (x + 1) + 2;')
[IO.File]::WriteAllText($incrementalEntry, $incrementalEntryLocalChange, $utf8)
$incrementalLocal = Invoke-IncrementalCase incremental_leaf_body_change $incrementalEntry $incrementalCache 1
if ($incrementalLocal.Profile.incrementalCache.hits -le 0 -or $incrementalLocal.Profile.incrementalCache.stores -le 0) { throw 'Local body change did not reuse unaffected functions' }
$incrementalLocalPlain = Invoke-IncrementalCase incremental_leaf_body_change_plain $incrementalEntry $incrementalCache 0 -NoCache
if ($incrementalLocal.Hash -ne $incrementalLocalPlain.Hash) { throw 'Local body-change reuse changed assembly' }

[IO.File]::WriteAllText($incrementalDep, "func incremental_dep_value(x: u64) -> u64 { return (x + 1) + 1; }`n", $utf8)
$incrementalTransitive = Invoke-IncrementalCase incremental_transitive_body_change $incrementalEntry $incrementalCache 1
if ($incrementalTransitive.Profile.incrementalCache.hits -le 0 -or $incrementalTransitive.Profile.incrementalCache.stores -le 0) { throw 'Transitive body change did not reuse unaffected functions' }
$incrementalTransitivePlain = Invoke-IncrementalCase incremental_transitive_body_change_plain $incrementalEntry $incrementalCache 0 -NoCache
if ($incrementalTransitive.Hash -ne $incrementalTransitivePlain.Hash) { throw 'Transitive body-change reuse changed assembly' }

$incrementalSignature = $incrementalEntryLocalChange.Replace('incremental_local_change(x: u64)', 'incremental_local_change(x: u64, y: u64)').Replace('return (x + 1) + 2;', 'return x + y;').Replace('incremental_local_change(5)', 'incremental_local_change(5, 3)')
[IO.File]::WriteAllText($incrementalEntry, $incrementalSignature, $utf8)
$incrementalSignatureResult = Invoke-IncrementalCase incremental_public_signature_change $incrementalEntry $incrementalCache 1
if ($incrementalSignatureResult.Profile.incrementalCache.hits -ne 0) { throw 'Public signature change reused stale function fragments' }

[IO.File]::WriteAllText($incrementalDep, "func incremental_dep_value(x: u64) -> u64 { return x + (1 + 1); }`n", $utf8)
$functionManifest = @(Get-ChildItem -LiteralPath $incrementalCache -Filter '*.bppfun' | Sort-Object LastWriteTimeUtc -Descending)
if ($functionManifest.Count -lt 1) { throw 'Expected a function manifest before corruption test' }
[IO.File]::WriteAllBytes($functionManifest[0].FullName, [byte[]]@(1,2,3))
$incrementalCorrupt = Invoke-IncrementalCase incremental_corrupt_manifest $incrementalEntry $incrementalCache 1
if ($incrementalCorrupt.Profile.incrementalCache.hits -ne 0) { throw 'Corrupt function manifest was reused' }
$incrementalCorruptPlain = Invoke-IncrementalCase incremental_corrupt_manifest_plain $incrementalEntry $incrementalCache 0 -NoCache
if ($incrementalCorrupt.Hash -ne $incrementalCorruptPlain.Hash) { throw 'Corrupt function-manifest fallback changed assembly' }

$cold = Invoke-CacheCase cold 1
$warm = Invoke-CacheCase warm 2 -PreparseHit
if ($cold -ne $warm) { throw 'Cold and warm assembly differ' }
$plain = Invoke-CacheCase no_cache 0 -Options @('--no-cache')
if ($plain -ne $cold) { throw 'Enabling cache changed assembly' }
$indexRecord = @(Get-ChildItem -LiteralPath $cache -Filter '*.bppidx')[0].FullName
$indexBytes = [IO.File]::ReadAllBytes($indexRecord)
$indexBytes[$indexBytes.Length - 1] = $indexBytes[$indexBytes.Length - 1] -bxor 1
[IO.File]::WriteAllBytes($indexRecord, $indexBytes)
if ((Invoke-CacheCase corrupt_index 2 -ParsedHit) -ne $cold) { throw 'Corrupt preparse index changed output' }
[IO.File]::WriteAllBytes($indexRecord, [byte[]]@(1,2,3))
if ((Invoke-CacheCase truncated_index 2 -ParsedHit) -ne $cold) { throw 'Truncated preparse index changed output' }
$record = @(Get-ChildItem -LiteralPath $cache -Filter '*.bppasm')[0].FullName
$bytes = [IO.File]::ReadAllBytes($record)
$bytes[$bytes.Length - 1] = $bytes[$bytes.Length - 1] -bxor 1
[IO.File]::WriteAllBytes($record, $bytes)
if ((Invoke-CacheCase corrupt 3) -ne $cold) { throw 'Corruption rebuild changed output' }
[IO.File]::WriteAllBytes($record, [byte[]]@(1,2,3))
if ((Invoke-CacheCase truncated 3) -ne $cold) { throw 'Truncated rebuild changed output' }

[IO.File]::WriteAllText($leaf, "func leaf_value() -> u64 { return 2; }`n", $utf8)
$changedLeaf = Invoke-CacheCase transitive_change 1
if ($changedLeaf -eq $cold) { throw 'Transitive source change did not change output' }
[void](Invoke-CacheCase transitive_warm 2 -PreparseHit)
[IO.File]::WriteAllText($leaf, "func leaf_value() -> u64 { return 1; }`n", $utf8)
if ((Invoke-CacheCase restored_dependency 2 -ParsedHit) -ne $cold) { throw 'Restored exact dependency did not reuse its artifact' }
if ((Invoke-CacheCase restored_dependency_preparse 2 -PreparseHit) -ne $cold) { throw 'Restored dependency did not refresh its preparse index' }
Move-Item -LiteralPath $leaf -Destination (Join-Path $work 'leaf.original')
[void](Invoke-CacheCase missing_dependency 1 -Fail)
Copy-Item -LiteralPath (Join-Path $work 'leaf.original') -Destination (Join-Path $library 'leaf.bpp')
$fallback = Invoke-CacheCase library_fallback 1
# Use an unseen input: returning 2 was already cached by transitive_change.
# Reusing that exact earlier identity would be a correct hit, not stale reuse.
[IO.File]::WriteAllText($leaf, "func leaf_value() -> u64 { return 3; }`n", $utf8)
if ((Invoke-CacheCase new_shadowing_module 1) -eq $fallback) { throw 'New higher-priority module did not invalidate the artifact' }
[IO.File]::WriteAllText($leaf, "func leaf_value() -> u64 { return 1; }`n", $utf8)
if ((Invoke-CacheCase restored_shadowing_module 2 -ParsedHit) -ne $cold) { throw 'Restored resolved graph did not reuse its artifact' }
if ((Invoke-CacheCase restored_shadowing_preparse 2 -PreparseHit) -ne $cold) { throw 'Restored graph did not refresh its preparse index' }
[IO.File]::WriteAllText($entry, $entryText + "// changed entry`n", $utf8)
[void](Invoke-CacheCase entry_change 1)
[IO.File]::WriteAllText($entry, $entryText, $utf8)

$optimized = Invoke-CacheCase options_change 1 -Options @('-O1','--backend','legacy')
if ((Invoke-CacheCase options_warm 2 -Options @('-O1','--backend','legacy') -PreparseHit) -ne $optimized) { throw 'Options cache mismatch' }
[void](Invoke-CacheCase target_change 1 -Options @('--target','linux-x86_64'))
[void](Invoke-CacheCase target_warm 2 -Options @('--target','linux-x86_64') -PreparseHit)
[void](Invoke-CacheCase diagnostic_report 0 -Options @('--backend-report'))

[IO.File]::WriteAllText($manifest, $manifestText + "cache_test_revision=1`n", $utf8)
[void](Invoke-CacheCase manifest_change 1)
$stdFile = Join-Path $library 'std/util.bpp'
[IO.File]::AppendAllText($stdFile, "`n// cache invalidation fixture`n", $utf8)
[void](Invoke-CacheCase standard_library_change 1)
[void](Invoke-CacheCase standard_library_warm 2 -PreparseHit)

$otherCompiler = Join-Path $work 'compiler-overlay.exe'
Copy-Item -LiteralPath $compiler -Destination $otherCompiler
$overlay = [IO.File]::Open($otherCompiler, [IO.FileMode]::Append, [IO.FileAccess]::Write)
try { $overlay.WriteByte(0) } finally { $overlay.Dispose() }
[void](Invoke-CacheCase compiler_identity_change 1 -Binary $otherCompiler)
[void](Invoke-CacheCase compiler_identity_warm 2 -Binary $otherCompiler -PreparseHit)

$badCache = Join-Path $work 'not-a-directory'
[IO.File]::WriteAllText($badCache, 'fixture', $utf8)
[void](Invoke-CacheCase unavailable 1 -CacheDirectory $badCache)
[IO.File]::WriteAllText($entry, "func main() -> u64 { return cache_missing_symbol; }`n", $utf8)
[void](Invoke-CacheCase invalid_program 1 -Fail)
[void](Invoke-CacheCase invalid_program_again 1 -Fail)
[IO.File]::WriteAllText($entry, $entryText, $utf8)

# Two processes publish the same previously unseen identity. Each writer has
# its own temporary file; the final record must be complete and reusable.
[IO.File]::WriteAllText($entry, $entryText + "// concurrent publication`n", $utf8)
$raceJobs = @()
for ($race = 0; $race -lt 2; $race++) {
    $raceOutput = Join-Path $work "concurrent-$race.out"
    $raceError = Join-Path $work "concurrent-$race.err"
    $raceArgs = @('--target','windows-x86_64','--cache-dir',$cache,'-asm',$entry)
    $raceJobs += Start-Job -ScriptBlock {
        param($Helper, $Binary, $CompilerArgs, $OutputFile, $ErrorFile, $Cwd, $Limit, $Timeout)
        Set-ExecutionPolicy -Scope Process Bypass -Force
        . $Helper
        Invoke-BppLimitedProcess -FilePath $Binary -ArgumentList $CompilerArgs -TimeoutMs $Timeout -StdoutPath $OutputFile -StderrPath $ErrorFile -WorkingDirectory $Cwd -MemoryLimitBytes $Limit
    } -ArgumentList (Join-Path $repo 'tools/windows_process.ps1'),$compiler,$raceArgs,$raceOutput,$raceError,$work,$MemoryLimitBytes,$CompilerTimeoutMs
}
try {
    foreach ($job in $raceJobs) {
        $raceResult = Receive-Job -Job $job -Wait -ErrorAction Stop
        if ($raceResult.ExitCode -ne 0) { throw 'Concurrent cache publication failed' }
    }
} finally { $raceJobs | Remove-Job -Force }
$raceHash = (Get-FileHash -LiteralPath (Join-Path $work 'concurrent-0.out') -Algorithm SHA256).Hash
if ($raceHash -ne (Get-FileHash -LiteralPath (Join-Path $work 'concurrent-1.out') -Algorithm SHA256).Hash) { throw 'Concurrent writers produced different assembly' }
if ((Invoke-CacheCase concurrent_warm 2 -PreparseHit) -ne $raceHash) { throw 'Concurrent publication produced an invalid artifact' }
[IO.File]::WriteAllText($entry, $entryText, $utf8)

if ($NasmPath -and $LinkerPath) {
    [void](Invoke-CacheCase executable_cold 1 -Execute)
    [void](Invoke-CacheCase executable_warm 2 -Execute -PreparseHit)
}
if (@(Get-ChildItem -LiteralPath $cache -Filter '*.tmp.*').Count -ne 0) { throw 'Temporary cache records leaked' }
$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $work 'results.json') -Encoding UTF8
Write-Host "Artifact cache tests passed: $($results.Count). Evidence: $work"
