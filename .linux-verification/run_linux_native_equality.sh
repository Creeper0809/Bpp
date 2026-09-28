#!/usr/bin/env bash
set -euo pipefail
cd /work
ulimit -Sv 4194304
ulimit -Hv 4194304
ulimit -c 0
cmp build/v15_stage1.asm build/v15_stage2.asm
# NASM stores the chunk input path in ELF FILE symbols. Assemble both compiler
# outputs with the same scratch path so byte comparison includes all symbols
# without confusing randomly named temporary directories with code differences.
scratch=/work/build/native-equality-split
test "$(realpath -m "$scratch")" = /work/build/native-equality-split
test ! -e "$scratch"
for stage in 1 2; do
    BPP_NASM_SPLIT_WORK_DIR="$scratch" BPP_NASM_SPLIT_KEEP=0 nice -n 19 bash tools/nasm_split_assemble.sh "build/v15_stage${stage}.asm" "build/native-equality-stage${stage}.o" -felf64 -O1
    ld "build/native-equality-stage${stage}.o" -o "build/native-equality-stage${stage}"
done
cmp build/native-equality-stage1 build/native-equality-stage2
sha256sum build/native-equality-stage1 build/native-equality-stage2 build/v15_stage1.asm build/v15_stage2.asm
printf 'NATIVE_EXECUTABLE_EQUALITY=PASS (identical assembly input paths; no stripping)\n'
