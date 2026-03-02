# Bpp Commercial Fuzzing Harness

This directory contains a production-style fuzzing harness for Bpp compiler validation.

## Goals

- Continuously generate and mutate `.bpp` inputs.
- Detect hard failures:
  - crashes (`signal`)
  - hangs (`timeout`)
- Detect semantic instability via differential checks:
  - `nossa` vs `ssa`
  - `O0` vs `O1`
- Persist repro artifacts for triage and CI replay.

## Layout

- `run_fuzz.sh`: main orchestrator (parallel workers).
- `generate_seed_corpus.sh`: imports initial seeds from `test/source`.
- `lib/common.sh`: shared helper functions.
- `corpus/`: seed corpus used for mutation.
- `work/`: ephemeral per-run generated cases.
- `findings/`: saved repro cases (`crash`, `hang`, `diff`).

## Quick Start

```bash
cd fuzz
./generate_seed_corpus.sh
./run_fuzz.sh
```

## Recommended CI/Server Profile

```bash
FUZZ_COMPILER=bin/v11_stage1 \
FUZZ_ITERS=20000 \
FUZZ_JOBS=$(nproc) \
FUZZ_TIMEOUT_SEC=3 \
FUZZ_MAX_BYTES=16384 \
./fuzz/run_fuzz.sh
```

## Environment Variables

- `FUZZ_COMPILER` (default: auto-detect stage1 compiler)
- `FUZZ_ITERS` (default: `2000`)
- `FUZZ_JOBS` (default: `nproc`, min `1`)
- `FUZZ_TIMEOUT_SEC` (default: `4`)
- `FUZZ_HANG_CONFIRM_SEC` (default: `FUZZ_TIMEOUT_SEC * 3`, used to confirm real hangs and reduce load-induced timeout false positives)
- `FUZZ_MAX_BYTES` (default: `8192`)
- `FUZZ_SEED` (default: current epoch)
- `FUZZ_ROOT` (default: `<repo>/fuzz`)

## Differential Matrix

Each case is compiled across:

- `nossa.O0`: `-asm`
- `nossa.O1`: `-O1 -asm`
- `ssa.O0`: `-dump-ssa -asm`
- `ssa.O1`: `-O1 -dump-ssa -asm`

Findings are emitted when:

- any variant crashes/hangs
- success/failure differs across variants
- same-mode optimization levels disagree on success/failure

## Reproducing a Finding

```bash
case_file=fuzz/findings/crash/<id>/input.bpp
bin/v11_stage1 -asm "$case_file"
bin/v11_stage1 -O1 -dump-ssa -asm "$case_file"
```

## Crash Triage (Stage Hypothesis)

Use the triage helper to re-run `findings/crash/*` and classify likely failure area.

```bash
./fuzz/triage_crash.sh
```

Useful options:

```bash
TRIAGE_COMPILER=bin/v11_stage1 TRIAGE_LIMIT=1 ./fuzz/triage_crash.sh
TRIAGE_CASE=crash_20260302_204638_w2_i11_14930 ./fuzz/triage_crash.sh
```

Output is written under:

- `fuzz/findings/triage/<run_id>/results.tsv`
- `fuzz/findings/triage/<run_id>/summary.txt`

## Notes

- Harness is intentionally fail-fast on infrastructure errors, not on compiler findings.
- Findings are append-only and safe to archive as CI artifacts.
- For long campaigns, rotate `fuzz/findings/` externally by date/job id.
