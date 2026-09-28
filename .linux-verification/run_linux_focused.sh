#!/usr/bin/env bash
set -euo pipefail
cd /work
ulimit -Sv 4194304
ulimit -Hv 4194304
ulimit -c 0
mkdir -p build bin
chmod +x tools/*.sh
nice -n 19 bin/fix-seed --no-cache --backend legacy -asm src/main.bpp > build/fix-compiler.asm
nice -n 19 bash tools/nasm_split_assemble.sh build/fix-compiler.asm build/fix-compiler.o -felf64 -O1
ld build/fix-compiler.o -o bin/fix-compiler
export TEST_JOBS=1 TEST_PROFILE=full TEST_SKIP_LLVM_BUILD=0 KEEP_TEST_ARTIFACTS=1
export TEST_NAME_FILTER='^(05_|07_|09_|10_|11_|26_|28_|29_|30_|33_|34_|39_|40_|42_|43_|91_)'
export TEST_RESULT_JSON=/work/linux-focused-results.json
nice -n 19 bash test/run_tests.sh /work/bin/fix-compiler
