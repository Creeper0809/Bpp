#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPILER="${COMPILER:-$ROOT_DIR/bin/v13_stage1}"
SRC="$ROOT_DIR/bench/tagged_pointer_fastpaths.bpp"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/build/bench_tagged_pointer_fastpaths}"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

"$COMPILER" -llvm-build "$SRC"

EXE="$OUT_DIR/tagged_pointer_fastpaths.llvm.out"
if [ ! -x "$EXE" ]; then
    echo "benchmark executable not found: $EXE" >&2
    exit 1
fi

if [ "${USE_PERF:-0}" = "1" ] && command -v perf >/dev/null 2>&1; then
    perf stat -e cycles,instructions,branches,branch-misses "$EXE"
else
    /usr/bin/time -f 'elapsed=%e user=%U sys=%S' "$EXE"
fi
