#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/build/bench_tagged_pointer_fastpaths}"
BENCH_SOURCES="bench/tagged_pointer_fastpaths.bpp" OUT_DIR="$OUT_DIR" exec "$ROOT_DIR/bench/run_microbench.sh"
