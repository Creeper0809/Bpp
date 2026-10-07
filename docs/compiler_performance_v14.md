# v14 performance work

## Native assembly cache

Pass `--cache-dir <directory>` to opt into persistent compilation-artifact reuse.
The directory itself is created when its parent exists. `--cache-report` prints
hit/miss/store information to stderr; `--no-cache` disables reuse and writes.
Without these options the compiler does not create a persistent cache.

The cache supports `-asm` and the default assemble/link/run workflow. Other
outputs, backend reports and symbolic reports compile normally. Assembly output
is identical with caching enabled or disabled. `--timings-json` includes
`artifactCache.status` (0 disabled, 1 miss, 2 hit, 3 invalid record) and `lookupMs`.
It also reports `preparseHit`; an unchanged build can validate a compact,
exact dependency witness and restore the assembly before lexing or parsing.

The fastest path is **whole-compilation assembly reuse**, not serialized ASTs or
separately linked module objects. A pre-parse witness records the resolved import
graph, search roots and exact source bytes. When that witness still matches, the
compiler restores the assembly without parsing, lowering, semantic passes or
backend generation. Assembly and linking still run for the default executable
workflow.

Identity includes the running compiler image, semantic command-line arguments,
target, resolved search roots, manifest bytes, and every loaded module's path
and source bytes. Length-delimited bytes are compared exactly: timestamps and
the filename hash alone cannot authorize reuse. Changed dependency contents,
newly shadowing modules, compiler builds, manifests, targets or options produce
a whole-artifact miss.

After such a miss, legacy native code generation can reuse independently stored
function fragments when an exact semantic-environment record still matches.
That environment includes non-body source, finalized signatures and annotations,
escape summaries, layouts, globals and constants. A fragment key also includes
the exact function source span and finalized ABI. Fragments that touch string or
floating literal registries, generated globals, tracing, or otherwise unproven
shared state are compiled normally. Numeric local-label fragments are replayed
only at their recorded starting label and advance the counter by their recorded
delta. This is function-level assembly replay into one final assembly file, not
independent module object linking.

Records are bounded (64 MiB identity, 320 MiB complete read), checked for exact
length/version/identity and output checksum, and published by replacing the
destination atomically after successful generation. Missing, malformed or
unwritable cache storage falls back to compilation. Incomplete output is never
published. Temporary records have per-process names; concurrent identical builds
can safely publish the same artifact. This is a private, trusted local cache:
the output checksum detects accidental corruption, not malicious replacement.
Records contain compiler/source bytes, so do not publish them as build artifacts
or share the directory with untrusted writers. The repository ignores `.bppasm`,
`.bppidx`, `.bppsem` and `.bppfun` records and their temporary files to prevent
accidental normal Git staging.
Old records are retained; users
can remove their chosen cache directory when they no longer need it.

## Other implementation changes

- SSA allocation keeps the failed coloring and rewrites all selected spills in
  one instruction walk. Call arguments retain unique memory slots; indirect
  callees, two-word results and slice-return metadata retain their ABI behavior.
- Finalized backend emission reuses nominal struct-size/GC metadata in an
  explicitly scoped cache. Context switches, generation changes, rebinding and
  scope exit invalidate it. Mutable `TypeInfo` descriptors are not interned.
- Array size queries avoid descriptor cloning. Boolean GC queries short-circuit
  without constructing lists or visiting every element of scalar arrays.
- Temporary GC roots use frame-hashed lookup and a pool bounded to 128 records.
  Reset releases the pool. Root pinning, sequence marks and injected scratch
  register preservation remain in place; no declaration-only `noalloc` shortcut
  is used.
- Cache integration also exposed two existing correctness defects: empty string
  literals emitted invalid assembly, and the canonical Linux target name used
  an incorrect hard-coded length. Both were corrected with regression coverage.
- Expression-type inference and backend type queries use generation-scoped,
  directly indexed caches. AST rewrites, symbol changes, generic substitution,
  context changes and explicit resets invalidate entries instead of retaining
  mutable type state across semantic boundaries.
- Legacy function emission reuses each function's GC requirement, bypasses span
  work when no source map is requested, and writes through a 64 KiB buffer.
  Timing JSON includes cache hit/miss counters and code-generation work counters
  so future changes can be evaluated by work performed as well as wall time.

## Verification

### Windows measurements (2026-09-27)

Compile-to-assembly only, 4 GiB per process, three sequential samples per
configuration. Baseline and candidate alternated while compiling the same final
source snapshot. Values below are medians, not a general workload guarantee.

| Workload | Baseline wall | Updated wall | Baseline CPU | Updated CPU |
| --- | ---: | ---: | ---: | ---: |
| Compiler self-host, cache disabled | 44.64 s | 42.20 s | 11.16 s | 7.73 s |
| Strict SSA prelude fixture | 44.84 s | 12.78 s | 10.89 s | 3.03 s |
| Updated self-host, uncached vs warm cache | 42.20 s | 4.61 s | 7.73 s | 1.09 s |

The strict SSA fixture improved approximately 3.51x overall. Its measured
register-allocation span fell from 35.484 s to 3.266 s, and the spill-rewrite
span from 29.126 s to 0.094 s. These spans are not additional end-to-end time.
Uncached self-host wall improvement was only 5.5%, with overlapping sample
ranges (baseline 43.90–54.97 s; updated 42.07–46.99 s), so it is not evidence
of a universal speedup. Warm cache samples ranged from 4.54 to 4.76 s, about
9.15x faster than the updated uncached median; the first cache population took
45.33 s in one sample. Assemble/link time is excluded from these numbers.

Median peak process memory reported by the Windows Job Object was
730.7 MiB → 728.5 MiB for uncached self-host, then 295.3 MiB on a warm hit.
Strict SSA used 75.2 MiB → 73.3 MiB. The helper's legacy
`PeakWorkingSetBytes` property actually reads `PeakProcessMemoryUsed`; these
are Job Object process-memory measurements, not resident working-set samples.
Self-host assembly was byte-identical across baseline, updated, cold-cache and
warm-cache samples (35,611,453 bytes). Strict SSA assembly size stayed at
1,221,956 bytes, with deterministic register-allocation differences.
This work does not claim a general generated-program speedup or size reduction.
The GC regression independently verifies that 10,000 warmed temporary-root
push/release iterations require zero additional bookkeeping-record allocations.

Raw samples: `.planning/2026-09-27-compiler-performance/benchmark-results.json`.

### Follow-up 1–4 measurements (2026-09-27)

The follow-up comparison uses the compiler frozen immediately before the
pre-parse, scoped-inference, code-generation and function-fragment work, versus
the final self-hosted compiler. Both compile the same final source, cache is
disabled, order alternates, and each value is the median of three Windows runs
under the same 4 GiB process limit.

| Workload | Pre-follow-up wall | Final wall | Change | Pre-follow-up codegen | Final codegen |
| --- | ---: | ---: | ---: | ---: | ---: |
| Compiler self-host | 59.84 s | 41.92 s | -29.9% | 33.44 s | 20.92 s |
| Strict SSA prelude fixture | 39.95 s | 42.78 s | +7.1% | 27.20 s | 30.02 s |

Self-host lowering fell from a 16.27 s median to 11.66 s, and median process
memory fell from 740.2 MiB to 581.0 MiB. All six self-host assemblies have the
same 36,147,877-byte SHA-256 output. A completely unchanged cached self-host
build has a 351 ms median (331–376 ms), with parsing, lowering and code generation
all skipped; this is about 119x faster than the final uncached median.

The strict-SSA samples are byte-identical but show no follow-up speedup. That
path was already improved by the earlier batched spill work, while the follow-up
legacy-emitter changes do not apply to it. Its measured increase is retained as
a remaining optimization target rather than presented as a gain.

For a compiler-source edit confined to one function body, the fragment cache
reused 3,607 of 5,042 eligible lookups (71.5%). Function emission fell from
23.66 s on initial population to 10.13 s after the edit, while cached and
uncached assembly SHA-256 remained identical. This cache intentionally does not
reuse the 1,434 functions whose shared effects were not proven safe.

Raw samples: `.planning/2026-09-27-compiler-performance/followup-benchmark-results.json`.

### Correctness gates

Final unfiltered Windows verification passed **962/962** tests (2 workers),
followed by **42/42** integrated cache and incremental cases. Stage1 and Stage2
match in both assembly and executable bytes; that executable also matches the
final benchmark candidate. The native Windows runner's existing unsupported
LLVM-only fixture is excluded (1), not a new skip. None of the 1,919 measured
compile/assemble/link/run processes timed out or exceeded the 4 GiB limit; the
largest recorded process-memory value was 385.2 MiB.

The first full run caught a missing owner-module import in the new test, which
was corrected without changing assertions. An intermediate 4-worker run had
one existing program hit its 20 s timeout; the exact binary then passed 10/10
unchanged-limit repeats in 18–35 ms, and passed in the final complete 2-worker
run. The cause of that isolated delay was not established. Failed-run evidence
is retained, rather than combining passes across different runs.

Final follow-up evidence:
`.planning/2026-09-27-compiler-performance/followup-final-verification.json` and
`phase10_windows.json` in the same directory. The verification script also
checks the frozen compiler/test/build-input digest, Stage1/Stage2 identity,
benchmark and incremental output equality, warm pre-parse hits, and recorded
per-process memory/timeout results.

The Windows full build runs `test/run_cache_tests.ps1` after the normal suite.
That gate covers exact warm output, disabled operation, damaged/truncated
records, transitive and standard-library dependencies, source/options/target/
manifest/compiler identity, failed compilations, unwritable storage, concurrent
publication, executable workflow, unchanged/body-edited incremental reuse,
public-signature invalidation, transitive body changes and corrupt fragment
manifests. All compiler/program processes use the repository's 4 GiB Job Object
limit.

Native Linux execution is deferred by the user's Windows-only instruction.
Performance numbers and the final verification snapshot are recorded in
`.planning/2026-09-27-compiler-performance/`.
