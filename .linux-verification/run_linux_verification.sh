#!/usr/bin/env bash
set -euo pipefail
cd /work
ulimit -Sv 4194304
ulimit -Hv 4194304
ulimit -c 0
export LC_ALL=C.UTF-8
export TMPDIR=/tmp
export BPP_BASE_COMPILER=/work/bin/v15_cross_seed
export BPP_BOOTSTRAP_COMPILER=0
export BUILD_AND_TEST_PROFILE=full
export SELFHOST_VERIFY=1
export SELFHOST_VERIFY_ASYNC=0
export TEST_JOBS=1
export TEST_PROFILE=full
export TEST_NAME_FILTER=
export TEST_MODE_FILTER=
export TEST_OPT_FILTER=
export TEST_SHARD_COUNT=1
export TEST_SHARD_INDEX=0
export COMPILE_FAIL_SINGLE_VARIANT=0
export TEST_SUITE_CASE_LIMIT=0
export TEST_SKIP_LLVM_BUILD=0
export TEST_QUIET=0
export TEST_FAST_IO=0
export KEEP_TEST_ARTIFACTS=0
export TEST_RESULT_JSON=/work/linux-results.json
export BUILD_SKIP_TESTS=0
export UPDATE_BOOTSTRAP=0
date -u
uname -srm
printf 'address_space_limit_kib=%s\n' "$(ulimit -v)"
nasm -v
clang --version
sha256sum linux-bootstrap.asm
mkdir -p build bin
nasm -felf64 -O1 linux-bootstrap.asm -o build/linux-bootstrap.o
ld build/linux-bootstrap.o -o bin/v15_cross_seed
chmod +x tools/*.sh
started=$SECONDS
set +e
nice -n 19 bash build_and_test.sh
status=$?
set -e
printf 'build_and_test_exit=%s\nelapsed_seconds=%s\n' "$status" "$((SECONDS - started))"
if [[ $status == 0 ]]; then
    cmp build/v15_stage1.asm build/v15_stage2.asm
    if [[ $(wc -l < build/v15_stage2.asm) -ge 120000 ]]; then
        bash tools/nasm_split_assemble.sh build/v15_stage2.asm build/v15_stage2.o -felf64 -O1
    else
        nasm -felf64 -O1 build/v15_stage2.asm -o build/v15_stage2.o
    fi
    ld build/v15_stage2.o -o bin/v15_stage2
    cmp bin/v15_stage1 bin/v15_stage2
    sha256sum bin/v15_stage1 bin/v15_stage2 build/v15_stage1.asm build/v15_stage2.asm
    printf 'NATIVE_EXECUTABLE_EQUALITY=PASS\n'
fi
du -sb build bin
date -u
exit "$status"
