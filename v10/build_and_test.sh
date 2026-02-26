#!/bin/bash
# B 컴파일러 빌드 → 셀프 호스팅 → 테스트 자동화 스크립트

set -e  # 에러 발생 시 즉시 중단
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================
# config.ini에서 버전 설정 읽기
# ============================================
if [ -f "$SCRIPT_DIR/config.ini" ]; then
    source <(grep -E '^(VERSION|PREV_VERSION)=' "$SCRIPT_DIR/config.ini")
else
    echo "Error: config.ini file not found."
    exit 1
fi
ROOT_DIR="$SCRIPT_DIR/.."
BUILD_DIR="$ROOT_DIR/build"
BIN_DIR="$ROOT_DIR/bin"

# 버전별 경로
SRC_FILE="$SCRIPT_DIR/src/main.bpp"
TEST_SCRIPT="$SCRIPT_DIR/test/run_tests.sh"
BASE_COMPILER="${VERSION}_base"
NASM_FLAGS="-felf64 -O1"
TEST_FAST_IO="${TEST_FAST_IO:-1}"
TEST_QUIET="${TEST_QUIET:-1}"
KEEP_TEST_ARTIFACTS="${KEEP_TEST_ARTIFACTS:-0}"
TEST_JOBS="${TEST_JOBS:-0}"

# Use RAM disk for large self-host ASM I/O when available (no build step skipped).
ASM_WORK_DIR="$BUILD_DIR"
if [ -d "/dev/shm" ] && [ -w "/dev/shm" ]; then
    ASM_WORK_DIR="/dev/shm/bpp_${VERSION}_selfhost_$$"
    mkdir -p "$ASM_WORK_DIR"
fi
trap 'if [ "$ASM_WORK_DIR" != "$BUILD_DIR" ]; then rm -rf "$ASM_WORK_DIR"; fi' EXIT

STAGE0_ASM="$ASM_WORK_DIR/${VERSION}_stage0.asm"
STAGE1_ASM="$ASM_WORK_DIR/${VERSION}_stage1.asm"
STAGE2_ASM="$ASM_WORK_DIR/${VERSION}_stage2.asm"

echo "========================================="
echo "${VERSION} Build & Test Automation"
echo "========================================="
echo ""

# Step 1: 베이스 컴파일러로 빌드 (또는 이전 버전 사용)
echo "[1/6] Compiling ${VERSION}..."
cd "$ROOT_DIR"
mkdir -p "$BUILD_DIR" "$BIN_DIR"

# {VERSION}_base가 있으면 사용, 없으면 이전 버전 사용
BASE_BIN=""
if [ -f "./bin/${BASE_COMPILER}" ]; then
    echo "   (${BASE_COMPILER} used)"
    BASE_BIN="./bin/${BASE_COMPILER}"
elif [ -f "./bin/${PREV_VERSION}_stage1" ]; then
    echo "   (${PREV_VERSION}_stage1 used)"
    BASE_BIN="./bin/${PREV_VERSION}_stage1"
elif [ -f "./bin/${PREV_VERSION}" ]; then
    echo "   (${PREV_VERSION} used)"
    BASE_BIN="./bin/${PREV_VERSION}"
else
    echo "Error: Base compiler not found."
    echo "   ${BASE_COMPILER}, ${PREV_VERSION}_stage1 or ${PREV_VERSION} is required."
    exit 1
fi

echo "   (ASM work dir: ${ASM_WORK_DIR})"

if [ ! -x "${BASE_BIN}" ]; then
    chmod +x "${BASE_BIN}" 2>/dev/null || true
fi
if [ ! -x "${BASE_BIN}" ]; then
    echo "Error: Base compiler is not executable: ${BASE_BIN}"
    echo "   Run: chmod +x ${BASE_BIN}"
    exit 1
fi

"${BASE_BIN}" -asm "${SRC_FILE}" > "${STAGE0_ASM}"
nasm ${NASM_FLAGS} "${STAGE0_ASM}" -o "build/${VERSION}_stage0.o"
ld build/${VERSION}_stage0.o -o bin/${VERSION}_stage0
echo "Stage 0 Build Completed"
echo ""

# Step 2: 셀프 호스팅 (1단계)
echo "[2/6] Self-Hosting Stage 1..."
./bin/${VERSION}_stage0 -asm "${SRC_FILE}" > "${STAGE1_ASM}"
nasm ${NASM_FLAGS} "${STAGE1_ASM}" -o "build/${VERSION}_stage1.o"
ld build/${VERSION}_stage1.o -o bin/${VERSION}_stage1
echo "Stage 1 Build Completed"
echo ""

# Step 3: 셀프 호스팅 (2단계)
echo "[3/6] Self-Hosting Stage 2..."
./bin/${VERSION}_stage1 -asm "${SRC_FILE}" > "${STAGE2_ASM}"
echo "Stage 2 Build Completed"
echo ""

# Step 4: ASM 비교 (1단계 vs 2단계)
echo "[4/6] Self-Hosting Verification..."
# We only need equality check; cmp is faster than textual diff for this.
if cmp -s "${STAGE1_ASM}" "${STAGE2_ASM}"; then
    echo "Self-Hosting Success! (Stage 1 == Stage 2)"
    echo "   ASM: $(wc -l < "${STAGE1_ASM}") lines"
else
    echo "Self-Hosting Failed! ASM is different."
    echo "   Stage 1: $(wc -l < "${STAGE1_ASM}") lines"
    echo "   Stage 2: $(wc -l < "${STAGE2_ASM}") lines"
    exit 1
fi
echo ""

# Persist ASM artifacts under build/ as before.
cp "${STAGE0_ASM}" "build/${VERSION}_stage0.asm"
cp "${STAGE1_ASM}" "build/${VERSION}_stage1.asm"
cp "${STAGE2_ASM}" "build/${VERSION}_stage2.asm"

# Step 5: 테스트 실행
echo "[5/6] Running Tests..."
TEST_FAST_IO="$TEST_FAST_IO" TEST_QUIET="$TEST_QUIET" KEEP_TEST_ARTIFACTS="$KEEP_TEST_ARTIFACTS" \
TEST_JOBS="$TEST_JOBS" \
  bash ${TEST_SCRIPT} bin/${VERSION}_stage1 2>&1 | tail -15

# Step 6: 바이너리(.out) 생성 (기본 실행 경로)
echo ""
echo "[6/6] Generating Executable..."
OUT_OBJ="build/${VERSION}.out.o"
nasm ${NASM_FLAGS} "${STAGE2_ASM}" -o "${OUT_OBJ}"
ld "${OUT_OBJ}" -o "build/${VERSION}.out"
rm -f "${OUT_OBJ}"

echo ""
echo "========================================="
echo "All tasks completed!"
echo "========================================="
echo ""
echo "Generated Files:"
echo "  - bin/${VERSION}_stage0 (Base Compiler)"
echo "  - bin/${VERSION}_stage1 (Self-Hosting Stage 1)"
echo "  - build/${VERSION}_stage*.asm (ASM Output)"
echo "  - build/${VERSION}.out (Executable)"
