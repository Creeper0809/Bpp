#!/bin/bash
# B 컴파일러 빌드 → 셀프 호스팅 → 테스트 자동화 스크립트

set -e  # 에러 발생 시 즉시 중단
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ROOT_DIR="$SCRIPT_DIR"
BUILD_DIR="$ROOT_DIR/build"
BIN_DIR="$ROOT_DIR/bin"
OLD_DIR="$ROOT_DIR/old"
CONFIG_FILE="$SCRIPT_DIR/config.ini"

read_config_value() {
    local key="$1"
    if [ ! -f "$CONFIG_FILE" ]; then
        return 0
    fi
    grep -E "^${key}=" "$CONFIG_FILE" | head -n1 | cut -d'=' -f2- | tr -d '[:space:]'
}

discover_latest_stage1_tag() {
    local latest_file
    latest_file="$(pick_latest_stage1_file)"
    if [ -z "$latest_file" ] || [ ! -f "$latest_file" ]; then
        return 0
    fi
    local base
    base="$(basename "$latest_file")"
    echo "${base%_stage1}"
}

pick_latest_stage1_file() {
    local best_ver=-1
    local best_file=""
    local f base ver

    for f in "$BIN_DIR"/v*_stage1; do
        [ -f "$f" ] || continue
        base="$(basename "$f")"
        if [[ "$base" =~ ^v([0-9]+)_stage1$ ]]; then
            ver="${BASH_REMATCH[1]}"
            if [ "$ver" -ge "$best_ver" ]; then
                best_ver="$ver"
                best_file="$f"
            fi
        fi
    done
    if [ -n "$best_file" ]; then
        echo "$best_file"
        return 0
    fi

    for f in "$BIN_DIR"/*_stage1; do
        [ -f "$f" ] || continue
        base="$(basename "$f")"
        if [[ "$base" == _* ]]; then
            continue
        fi
        best_file="$f"
    done
    if [ -n "$best_file" ]; then
        echo "$best_file"
    fi
}

discover_latest_old_version_tag() {
    if [ ! -d "$OLD_DIR" ]; then
        return 0
    fi

    local best_ver=-1
    local best_tag=""
    local d base ver

    for d in "$OLD_DIR"/v*; do
        [ -d "$d" ] || continue
        base="$(basename "$d")"
        if [[ "$base" =~ ^v([0-9]+)$ ]]; then
            ver="${BASH_REMATCH[1]}"
            if [ "$ver" -ge "$best_ver" ]; then
                best_ver="$ver"
                best_tag="$base"
            fi
        fi
    done

    if [ -n "$best_tag" ]; then
        echo "$best_tag"
    fi
}

pick_old_latest_stage1_file() {
    local old_tag
    old_tag="$(discover_latest_old_version_tag)"
    if [ -z "$old_tag" ]; then
        return 0
    fi

    local candidate=""
    candidate="$(pick_first_existing_file \
        "$BIN_DIR/${old_tag}_stage1" \
        "$OLD_DIR/${old_tag}/bin/${old_tag}_stage1" \
        "$OLD_DIR/${old_tag}/bin/stage1" \
        "$OLD_DIR/${old_tag}/bin/bootstrap" || true)"
    if [ -n "$candidate" ]; then
        echo "$candidate"
    fi
}

pick_first_existing_file() {
    local candidate
    for candidate in "$@"; do
        if [ -n "$candidate" ] && [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

extract_numeric_version() {
    local token="$1"
    if [[ "$token" =~ v([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

VERSION="${BPP_VERSION:-}"
if [ -z "$VERSION" ]; then
    VERSION="$(read_config_value VERSION)"
fi
if [ -z "$VERSION" ]; then
    VERSION="$(discover_latest_stage1_tag)"
fi
if [ -z "$VERSION" ]; then
    VERSION="bpp"
fi

# 버전별 경로
SRC_FILE="$SCRIPT_DIR/src/main.bpp"
TEST_SCRIPT="$SCRIPT_DIR/test/run_tests.sh"
BASE_COMPILER="${VERSION}_base"
NASM_FLAGS="-felf64 -O1"
UPDATE_BOOTSTRAP="${UPDATE_BOOTSTRAP:-0}"
TEST_FAST_IO="${TEST_FAST_IO:-1}"
TEST_QUIET="${TEST_QUIET:-1}"
KEEP_TEST_ARTIFACTS="${KEEP_TEST_ARTIFACTS:-0}"
TEST_JOBS="${TEST_JOBS:-0}"
TEST_PROFILE="${TEST_PROFILE:-}"
BUILD_AND_TEST_PROFILE="${BUILD_AND_TEST_PROFILE:-full}"
SELFHOST_VERIFY="${SELFHOST_VERIFY:-}"
STRESS_RUNS="${STRESS_RUNS:-}"
STABILITY_RUNS="${STABILITY_RUNS:-}"
TEST_SUITE_CASE_LIMIT="${TEST_SUITE_CASE_LIMIT:-0}"
TEST_NAME_FILTER="${TEST_NAME_FILTER:-}"
TEST_JOBS_SCALE="${TEST_JOBS_SCALE:-2}"
NASM_BIN="${BPP_NASM_EXECUTABLE:-nasm}"
LINKER_BIN="${BPP_LINKER_EXECUTABLE:-ld}"

if [ "$BUILD_AND_TEST_PROFILE" = "fast" ]; then
    if [ -z "$TEST_PROFILE" ]; then TEST_PROFILE="quick"; fi
    if [ -z "$SELFHOST_VERIFY" ]; then SELFHOST_VERIFY=0; fi
    if [ -z "${STRESS_RUNS:-}" ]; then STRESS_RUNS=0; fi
    if [ -z "${STABILITY_RUNS:-}" ]; then STABILITY_RUNS=0; fi
elif [ "$BUILD_AND_TEST_PROFILE" = "full" ]; then
    if [ -z "$TEST_PROFILE" ]; then TEST_PROFILE="full"; fi
    if [ -z "$SELFHOST_VERIFY" ]; then SELFHOST_VERIFY=1; fi
    # Full profile keeps full test matrix, but default avoids costly repeat runs.
    # Re-enable with STRESS_RUNS/STABILITY_RUNS env when needed.
    if [ -z "${STRESS_RUNS:-}" ]; then STRESS_RUNS=0; fi
    if [ -z "${STABILITY_RUNS:-}" ]; then STABILITY_RUNS=0; fi
else
    echo "Error: BUILD_AND_TEST_PROFILE must be 'fast' or 'full' (got: $BUILD_AND_TEST_PROFILE)"
    exit 1
fi

if [ "$TEST_JOBS" -eq 0 ]; then
    DETECTED_JOBS=4
    if command -v nproc >/dev/null 2>&1; then
        DETECTED_JOBS="$(nproc)"
    fi
    if [ -z "$DETECTED_JOBS" ] || [ "$DETECTED_JOBS" -lt 1 ]; then
        DETECTED_JOBS=1
    fi
    TEST_JOBS=$((DETECTED_JOBS * TEST_JOBS_SCALE))
    if [ "$TEST_JOBS" -lt 12 ]; then TEST_JOBS=12; fi
    if [ "$TEST_JOBS" -gt 64 ]; then TEST_JOBS=64; fi
fi

# Use RAM disk for large self-host ASM I/O when available (no build step skipped).
ASM_WORK_DIR="$BUILD_DIR"
if [ -d "/dev/shm" ] && [ -w "/dev/shm" ]; then
    # Avoid silent truncation when tmpfs is full (would produce invalid stage binaries).
    SHM_AVAIL_KB="$(df -Pk /dev/shm | awk 'NR==2 {print $4}')"
    SHM_MIN_KB=1048576  # 1 GiB safety margin for large self-host ASM outputs
    if [ -n "$SHM_AVAIL_KB" ] && [ "$SHM_AVAIL_KB" -ge "$SHM_MIN_KB" ]; then
        ASM_WORK_DIR="/dev/shm/bpp_${VERSION}_selfhost_$$"
        mkdir -p "$ASM_WORK_DIR"
    else
        echo "[WARN] /dev/shm free space is low (${SHM_AVAIL_KB:-unknown} KB). Falling back to build/."
    fi
fi
trap 'if [ "$ASM_WORK_DIR" != "$BUILD_DIR" ]; then rm -rf "$ASM_WORK_DIR"; fi' EXIT

STAGE0_ASM="$ASM_WORK_DIR/${VERSION}_stage0.asm"
STAGE1_ASM="$ASM_WORK_DIR/${VERSION}_stage1.asm"
STAGE2_ASM="$ASM_WORK_DIR/${VERSION}_stage2.asm"
BRIDGE_STAGE0_ASM="$ASM_WORK_DIR/${VERSION}_bridge_stage0.asm"

echo "========================================="
echo "${VERSION} Build & Test Automation"
echo "========================================="
echo ""

# Step 1: 베이스 컴파일러로 빌드 (또는 이전 버전 사용)
echo "[1/6] Compiling ${VERSION}..."
cd "$ROOT_DIR"
mkdir -p "$BUILD_DIR" "$BIN_DIR"

# {VERSION}_base 우선, 없으면 stage1 자동 탐지
BASE_BIN="${BPP_BASE_COMPILER:-}"
if [ -n "$BASE_BIN" ] && [ ! -f "$BASE_BIN" ]; then
    echo "Error: BPP_BASE_COMPILER points to missing file: $BASE_BIN"
    exit 1
fi
if [ -z "$BASE_BIN" ]; then
    # Default policy: use the last historical version from old/ as bootstrap base.
    BASE_BIN="$(pick_old_latest_stage1_file || true)"
fi
if [ -z "$BASE_BIN" ]; then
    BASE_BIN="$(pick_first_existing_file \
        "./bin/stage1" \
        "./bin/bootstrap" \
        "./bin/${BASE_COMPILER}" \
        "./bin/${VERSION}_stage1" \
        "./bin/${VERSION}" || true)"
fi
if [ -z "$BASE_BIN" ]; then
    BASE_BIN="$(pick_latest_stage1_file)"
fi
if [ -z "$BASE_BIN" ]; then
    echo "Error: Base compiler not found."
    echo "   Tried: old/<latest>/bin/*, bin/<old_latest>_stage1, bin/bootstrap, bin/stage1, bin/${BASE_COMPILER}, bin/${VERSION}_stage1, bin/${VERSION}, bin/*_stage1"
    echo "   Hint: set BPP_BASE_COMPILER=/abs/path/to/compiler"
    exit 1
fi
echo "   ($(basename "$BASE_BIN") used)"

echo "   (ASM work dir: ${ASM_WORK_DIR})"

if [ ! -x "${BASE_BIN}" ]; then
    chmod +x "${BASE_BIN}" 2>/dev/null || true
fi
if [ ! -x "${BASE_BIN}" ]; then
    echo "Error: Base compiler is not executable: ${BASE_BIN}"
    echo "   Run: chmod +x ${BASE_BIN}"
    exit 1
fi

BOOTSTRAP_BIN="${BASE_BIN}"
TARGET_VER_NUM="$(extract_numeric_version "$VERSION" || true)"
BASE_VER_NUM="$(extract_numeric_version "$(basename "$BASE_BIN")" || true)"
LEGACY_SRC_FILE="$OLD_DIR/$VERSION/src/main.bpp"

# Compatibility bridge:
# Some transitions (ex: v11 -> current v12) can produce a crashing stage0.
# When old/<VERSION>/ snapshot exists and base major is older than target,
# first build bridge compiler from old snapshot, then build current stage0.
if [ -n "${TARGET_VER_NUM:-}" ] && [ -n "${BASE_VER_NUM:-}" ] \
   && [ "$BASE_VER_NUM" -lt "$TARGET_VER_NUM" ] \
   && [ -f "$LEGACY_SRC_FILE" ]; then
    echo "   (bootstrap bridge enabled: v${BASE_VER_NUM} -> old/${VERSION} -> ${VERSION})"
    "${BASE_BIN}" -asm "${LEGACY_SRC_FILE}" > "${BRIDGE_STAGE0_ASM}"
    "${NASM_BIN}" ${NASM_FLAGS} "${BRIDGE_STAGE0_ASM}" -o "build/${VERSION}_bridge_stage0.o"
    "${LINKER_BIN}" "build/${VERSION}_bridge_stage0.o" -o "bin/${VERSION}_bridge_stage0"
    BOOTSTRAP_BIN="./bin/${VERSION}_bridge_stage0"
fi

"${BOOTSTRAP_BIN}" -asm "${SRC_FILE}" > "${STAGE0_ASM}"
"${NASM_BIN}" ${NASM_FLAGS} "${STAGE0_ASM}" -o "build/${VERSION}_stage0.o"
"${LINKER_BIN}" build/${VERSION}_stage0.o -o bin/${VERSION}_stage0
echo "Stage 0 Build Completed"
echo ""

# Step 2: 셀프 호스팅 (1단계)
echo "[2/6] Self-Hosting Stage 1..."
./bin/${VERSION}_stage0 -asm "${SRC_FILE}" > "${STAGE1_ASM}"
"${NASM_BIN}" ${NASM_FLAGS} "${STAGE1_ASM}" -o "build/${VERSION}_stage1.o"
"${LINKER_BIN}" build/${VERSION}_stage1.o -o bin/${VERSION}_stage1
# Unversioned pointer to latest successful stage1 output.
cp -f "bin/${VERSION}_stage1" "bin/stage1"
echo "Stage 1 Build Completed"
echo ""

# Step 3: 셀프 호스팅 (2단계)
FINAL_ASM="$STAGE1_ASM"
if [ "$SELFHOST_VERIFY" = "1" ]; then
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
    FINAL_ASM="$STAGE2_ASM"
else
    echo "[3/6] Self-Hosting Stage 2... skipped (SELFHOST_VERIFY=0)"
    echo ""
    echo "[4/6] Self-Hosting Verification... skipped (SELFHOST_VERIFY=0)"
    echo ""
fi

# Persist ASM artifacts under build/ as before.
cp "${STAGE0_ASM}" "build/${VERSION}_stage0.asm"
cp "${STAGE1_ASM}" "build/${VERSION}_stage1.asm"
if [ "$SELFHOST_VERIFY" = "1" ] && [ -f "${STAGE2_ASM}" ]; then
    cp "${STAGE2_ASM}" "build/${VERSION}_stage2.asm"
fi

# Step 5: 테스트 실행
echo "[5/6] Running Tests..."
TEST_FAST_IO="$TEST_FAST_IO" TEST_QUIET="$TEST_QUIET" KEEP_TEST_ARTIFACTS="$KEEP_TEST_ARTIFACTS" \
TEST_JOBS="$TEST_JOBS" TEST_PROFILE="$TEST_PROFILE" TEST_SUITE_CASE_LIMIT="$TEST_SUITE_CASE_LIMIT" TEST_NAME_FILTER="$TEST_NAME_FILTER" STRESS_RUNS="$STRESS_RUNS" STABILITY_RUNS="$STABILITY_RUNS" \
  bash ${TEST_SCRIPT} bin/${VERSION}_stage1 2>&1 | tail -15

# Step 6: 바이너리(.out) 생성 (기본 실행 경로)
echo ""
echo "[6/6] Generating Executable..."
OUT_OBJ="build/${VERSION}.out.o"
"${NASM_BIN}" ${NASM_FLAGS} "${FINAL_ASM}" -o "${OUT_OBJ}"
"${LINKER_BIN}" "${OUT_OBJ}" -o "build/${VERSION}.out"
rm -f "${OUT_OBJ}"

echo ""
echo "========================================="
echo "All tasks completed!"
echo "========================================="
echo ""
echo "Generated Files:"
echo "  - bin/${VERSION}_stage0 (Base Compiler)"
echo "  - bin/${VERSION}_stage1 (Self-Hosting Stage 1)"
echo "  - bin/stage1 (Latest stage1 alias)"
echo "  - build/${VERSION}_stage*.asm (ASM Output)"
echo "  - build/${VERSION}.out (Executable)"
if [ "$UPDATE_BOOTSTRAP" = "1" ]; then
    cp -f "bin/${VERSION}_stage1" "bin/bootstrap"
    echo "  - bin/bootstrap (Updated by UPDATE_BOOTSTRAP=1)"
fi
