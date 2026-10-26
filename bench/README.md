# Bpp / C++ algorithm benchmarks

`run_algorithm_benchmarks.py` compares ten equivalent unsigned-64-bit workloads:
array sum, dot product, binary search, heap sort, prime sieve, union-find, BFS,
0/1 knapsack, Euclid GCD and matrix multiplication.

`algorithm_cases.py` emits Bpp and C++ from the same imperative bodies. Only
declarations, signatures and I/O spelling change. Both versions use the same
array element types, layout, input generator, loops and checksums. Independent
Python oracles validate two small seeds and the measured input before timing.
The matrix oracle uses distributivity rather than copying the cubic loop.

## Run on Linux

Requires Python 3, GCC, Clang, NASM and ld. Use a fresh output directory and a
compiler built from the source state being measured. Always enforce 4 GiB:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; exec "$@"' _ \
  python3 bench/run_algorithm_benchmarks.py \
  --compiler ./bin/stage1 --out ./build/algorithms-run1 --runs 5
```

For a paired before/after measurement, retain the previous compiler binary:

```bash
bash -lc 'ulimit -Sv 4194304; ulimit -Hv 4194304 2>/dev/null || true; exec "$@"' _ \
  python3 bench/run_algorithm_benchmarks.py \
  --compiler ./bin/stage1 --baseline-compiler /path/to/retained-before \
  --modes gcc,clang,native_before,native,ssa,llvm \
  --out ./build/algorithms-paired-run1 --runs 5
```

Modes:

| Mode | Preparation |
| --- | --- |
| gcc | g++ C++17, `-O3 -march=x86-64` |
| clang | clang++ C++17, `-O3 -march=x86-64` |
| native_before | Retained Bpp, `-O1 --backend legacy -asm`, NASM and ld |
| native | Candidate Bpp, `-O1 --backend legacy -asm`, NASM and ld |
| ssa | Candidate Bpp, `-O1 --backend ssa -asm`, NASM and ld |
| llvm | Candidate Bpp `-O3 -dump-llvm-ll`, then Clang `-O3 -march=x86-64` |

The LLVM mode explicitly optimizes the emitted IR with Clang. It is not a claim
about the optimization flags forwarded by the separate `-llvm-build` CLI.
No C++ optimization is disabled, no volatile accesses inhibit its optimizer,
and neither language receives `-march=native`, fast-math or PGO.

## Measurement and correctness

- Compile, assemble and link time are recorded separately from execution.
- Runtime includes process startup, two integer inputs, deterministic dataset
  generation/initialization inside the shared workload, and one checksum.
  It measures the complete algorithm workload, not an isolated inner kernel.
- The runner pins itself and its children to one allowed logical CPU.
- A fresh native C supervisor records each target's CPU time, wall time and
  peak RSS through `wait4`, avoiding the Python parent's RSS high-water mark.
- Large-input validation is one unmeasured warmup. The measured variant order
  rotates for each repetition, including the retained before compiler.
- The JSON preserves commands, toolchain versions, source/binary hashes,
  oracle checks, stdout/stderr and every sample, with median and min/max.
- A failed or miscompiled variant is reported as failed, never as a fast sample.
  The overall command exits nonzero if any requested variant fails.
- Raw sources, assembly, LLVM IR and executables remain under the chosen output
  directory for diagnosis. Do not rewrite a previous output directory.

These are fixed-size, fixed-seed CPU workloads on primitive arrays. They do not
measure general `number` arithmetic, managed-object workloads, STL versus Bpp
container implementations, or arbitrary graph/data distributions. Record host
load and run-to-run variation; CPU affinity does not reserve a physical core.

The compiler acceptance gate remains the full `build_and_test.sh` under the
repository's 4 GiB wrapper, including actual Stage 1 == Stage 2 equality.

## Recorded comparison

The [2026-10-25 paired results](results/2026-10-25/summary.tsv) contain 300
measured samples: ten algorithms, six variants and five repetitions. The raw
[report](results/2026-10-25/report.json) preserves all validation and timing
records. The compiler change removes redundant native O1+ operand spills,
local scalar-store address materialization and indexed-address arithmetic.
It preserves O0 and does not change language semantics or the ABI.

These results use GCC 11.4 and Clang 15.0.7 on an Intel i7-7500U. They do not
claim to represent newer compiler releases or every CPU/input distribution.
The fastest C++ compiler is selected separately for each row. Observed
min/max ranges are retained; five samples are not a confidence guarantee.

The [full report](results/2026-10-25/README.md) includes correctness and generated
code evidence. Final-source acceptance passed all 1,052 Linux cases and all 962
Windows cases, with Stage 1 == Stage 2 on both platforms under 4 GiB. Windows
has one pre-existing unsupported LLVM-only skip; Linux has no LLVM skips.
The validated Linux compiler reproduces the exact measured native assembly
for all ten workloads and passes 30 additional independent oracle checks.

## Knapsack and matrix follow-up

The [focused follow-up](results/2026-10-25-kernels/README.md) investigates the
remaining native gap in knapsack DP and matrix multiplication. It preserves a
paired ten-algorithm comparison, a second 15-run check of the variable cases,
generated-loop assembly, C++ vectorization evidence and full Linux and Windows
acceptance logs.
