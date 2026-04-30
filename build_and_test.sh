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

add_base_candidate() {
    local candidate="$1"
    [ -n "$candidate" ] || return 0
    [ -f "$candidate" ] || return 0

    local existing
    for existing in "${BASE_CANDIDATES[@]}"; do
        if [ "$existing" = "$candidate" ]; then
            return 0
        fi
    done
    BASE_CANDIDATES+=("$candidate")
}

base_compiler_smoke_check() {
    local candidate="$1"
    [ -n "$candidate" ] || return 1
    [ -f "$candidate" ] || return 1

    if [ "${BPP_SKIP_BASE_SMOKE:-0}" = "1" ]; then
        return 0
    fi

    local smoke_src="$ROOT_DIR/test/source/01_arith_bit_cmp.bpp"
    if [ ! -f "$smoke_src" ]; then
        smoke_src="$SRC_FILE"
    fi

    (
        ulimit -v "${BPP_BASE_SMOKE_VMEM_KB:-4000000}" 2>/dev/null || true
        if command -v timeout >/dev/null 2>&1; then
            timeout "${BPP_BASE_SMOKE_TIMEOUT:-8s}" "$candidate" -asm "$smoke_src" >/dev/null 2>&1
        else
            "$candidate" -asm "$smoke_src" >/dev/null 2>&1
        fi
    ) 2>/dev/null
}

download_file() {
    local url="$1"
    local out="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out"
        return $?
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$out"
        return $?
    fi
    return 127
}

download_bootstrap_compiler() {
    if [ "${BPP_BOOTSTRAP_COMPILER:-1}" = "0" ]; then
        return 1
    fi

    local base_url="${BPP_BOOTSTRAP_BASE_URL:-https://github.com}"
    local repo="${BPP_BOOTSTRAP_REPOSITORY:-Creeper0809/Bpp}"
    local release_tag="${BPP_BOOTSTRAP_RELEASE_TAG:-bootstrap-${VERSION}}"
    local asset_name="${BPP_BOOTSTRAP_ASSET_LINUX:-bpp-bootstrap-${VERSION}-linux-x86_64}"
    local asset_sha="${BPP_BOOTSTRAP_SHA256_LINUX:-}"
    local tools_dir="$BUILD_DIR/_tools"
    local download_path="$tools_dir/$asset_name"
    local download_url="$base_url/$repo/releases/download/$release_tag/$asset_name"

    mkdir -p "$tools_dir"
    if [ ! -f "$download_path" ]; then
        echo "   [INFO] Downloading bootstrap compiler: $download_url" >&2
        if ! download_file "$download_url" "$download_path"; then
            rm -f "$download_path"
            echo "   [WARN] Failed to download bootstrap compiler." >&2
            return 1
        fi
    fi

    chmod +x "$download_path" 2>/dev/null || true

    if command -v sha256sum >/dev/null 2>&1; then
        if [ -n "$asset_sha" ]; then
            if ! printf '%s  %s\n' "$asset_sha" "$download_path" | sha256sum -c - >/dev/null 2>&1; then
                rm -f "$download_path"
                echo "   [WARN] Downloaded bootstrap checksum mismatch." >&2
                return 1
            fi
        else
            local sha_path="$download_path.sha256"
            local sha_url="$download_url.sha256"
            if [ ! -f "$sha_path" ]; then
                download_file "$sha_url" "$sha_path" >/dev/null 2>&1 || true
            fi
            if [ -f "$sha_path" ]; then
                if ! (cd "$tools_dir" && sha256sum -c "$(basename "$sha_path")" >/dev/null 2>&1); then
                    rm -f "$download_path"
                    echo "   [WARN] Downloaded bootstrap checksum file did not validate." >&2
                    return 1
                fi
            fi
        fi
    fi

    echo "$download_path"
}

extract_numeric_version() {
    local token="$1"
    if [[ "$token" =~ v([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

is_container_env() {
    if [ -f "/.dockerenv" ] || [ -f "/run/.containerenv" ]; then
        return 0
    fi
    if [ -f "/proc/1/cgroup" ] && grep -Eq '(docker|containerd|kubepods|podman)' /proc/1/cgroup 2>/dev/null; then
        return 0
    fi
    return 1
}

shm_available_kb() {
    if [ ! -d "/dev/shm" ] || [ ! -w "/dev/shm" ]; then
        return 1
    fi
    df -Pk /dev/shm 2>/dev/null | awk 'NR==2 {print $4}'
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
TEST_FAST_IO_EXPLICIT=0
if [ "${TEST_FAST_IO+x}" = "x" ]; then TEST_FAST_IO_EXPLICIT=1; fi
TEST_JOBS_EXPLICIT=0
if [ "${TEST_JOBS+x}" = "x" ]; then TEST_JOBS_EXPLICIT=1; fi
TEST_FAST_IO="${TEST_FAST_IO:-1}"
TEST_SKIP_LLVM_BUILD="${TEST_SKIP_LLVM_BUILD:-0}"
TEST_QUIET="${TEST_QUIET:-1}"
KEEP_TEST_ARTIFACTS="${KEEP_TEST_ARTIFACTS:-0}"
TEST_JOBS="${TEST_JOBS:-0}"
TEST_PROFILE="${TEST_PROFILE:-}"
BUILD_AND_TEST_PROFILE="${BUILD_AND_TEST_PROFILE:-full}"
SELFHOST_VERIFY="${SELFHOST_VERIFY:-}"
SELFHOST_VERIFY_ASYNC="${SELFHOST_VERIFY_ASYNC:-0}"
COMPILE_FAIL_SINGLE_VARIANT="${COMPILE_FAIL_SINGLE_VARIANT:-}"
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
    if [ -z "$COMPILE_FAIL_SINGLE_VARIANT" ]; then COMPILE_FAIL_SINGLE_VARIANT=1; fi
    if [ -z "${STRESS_RUNS:-}" ]; then STRESS_RUNS=0; fi
    if [ -z "${STABILITY_RUNS:-}" ]; then STABILITY_RUNS=0; fi
elif [ "$BUILD_AND_TEST_PROFILE" = "full" ]; then
    if [ -z "$TEST_PROFILE" ]; then TEST_PROFILE="full"; fi
    if [ -z "$SELFHOST_VERIFY" ]; then SELFHOST_VERIFY=1; fi
    # Compile-fail tests stop before backend codegen, so one variant preserves
    # diagnostic coverage while avoiding redundant mode/opt matrix work.
    if [ -z "$COMPILE_FAIL_SINGLE_VARIANT" ]; then COMPILE_FAIL_SINGLE_VARIANT=1; fi
    # Full profile keeps full test matrix, but default avoids costly repeat runs.
    # Re-enable with STRESS_RUNS/STABILITY_RUNS env when needed.
    if [ -z "${STRESS_RUNS:-}" ]; then STRESS_RUNS=0; fi
    if [ -z "${STABILITY_RUNS:-}" ]; then STABILITY_RUNS=0; fi
else
    echo "Error: BUILD_AND_TEST_PROFILE must be 'fast' or 'full' (got: $BUILD_AND_TEST_PROFILE)"
    exit 1
fi

case "$(echo "$SELFHOST_VERIFY_ASYNC" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
    1|true|yes) SELFHOST_VERIFY_ASYNC=1 ;;
    *) SELFHOST_VERIFY_ASYNC=0 ;;
esac

TEST_FAST_IO_MIN_SHM_KB="${BPP_TEST_FAST_IO_MIN_SHM_KB:-262144}"
if [ "$TEST_FAST_IO" -eq 1 ] && [ "$TEST_FAST_IO_EXPLICIT" -eq 0 ]; then
    TEST_SHM_AVAIL_KB="$(shm_available_kb || true)"
    if [ -z "$TEST_SHM_AVAIL_KB" ] || [ "$TEST_SHM_AVAIL_KB" -lt "$TEST_FAST_IO_MIN_SHM_KB" ]; then
        echo "[WARN] TEST_FAST_IO auto-disabled: /dev/shm has ${TEST_SHM_AVAIL_KB:-0} KB available (< ${TEST_FAST_IO_MIN_SHM_KB} KB)."
        TEST_FAST_IO=0
    fi
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
if [ "$TEST_JOBS_EXPLICIT" -eq 0 ] && is_container_env; then
    CONTAINER_TEST_JOBS="${BPP_CONTAINER_TEST_JOBS:-4}"
    if [ "$CONTAINER_TEST_JOBS" -gt 0 ] && [ "$TEST_JOBS" -gt "$CONTAINER_TEST_JOBS" ]; then
        echo "[WARN] TEST_JOBS capped for container build: $TEST_JOBS -> $CONTAINER_TEST_JOBS."
        TEST_JOBS="$CONTAINER_TEST_JOBS"
    fi
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
cleanup_build_and_test() {
    if [ -n "${STAGE2_PID:-}" ]; then
        kill "$STAGE2_PID" >/dev/null 2>&1 || true
        wait "$STAGE2_PID" >/dev/null 2>&1 || true
    fi
    if [ "$ASM_WORK_DIR" != "$BUILD_DIR" ]; then
        rm -rf "$ASM_WORK_DIR"
    fi
}
trap cleanup_build_and_test EXIT

STAGE0_ASM="$ASM_WORK_DIR/${VERSION}_stage0.asm"
STAGE1_ASM="$ASM_WORK_DIR/${VERSION}_stage1.asm"
STAGE2_ASM="$ASM_WORK_DIR/${VERSION}_stage2.asm"
STAGE2_LOG="$ASM_WORK_DIR/${VERSION}_stage2.log"
BRIDGE_STAGE0_ASM="$ASM_WORK_DIR/${VERSION}_bridge_stage0.asm"

echo "========================================="
echo "${VERSION} Build & Test Automation"
echo "========================================="
echo ""

# Step 1: 베이스 컴파일러로 빌드 (또는 이전 버전 사용)
echo "[1/6] Compiling ${VERSION}..."
cd "$ROOT_DIR"
mkdir -p "$BUILD_DIR" "$BIN_DIR"

# {VERSION}_base 우선, 없으면 smoke-tested compiler 자동 탐지
BASE_BIN="${BPP_BASE_COMPILER:-}"
if [ -n "$BASE_BIN" ] && [ ! -f "$BASE_BIN" ]; then
    echo "Error: BPP_BASE_COMPILER points to missing file: $BASE_BIN"
    exit 1
fi
if [ -z "$BASE_BIN" ]; then
    BASE_CANDIDATES=()
    # Prefer the most recent successful self-host artifacts.  The ad-hoc
    # dev_stage0 can be much older than the current source and still pass the
    # small smoke test while miscompiling the compiler itself.
    add_base_candidate "./bin/${VERSION}_stage1"
    add_base_candidate "./bin/stage1"
    add_base_candidate "./bin/${VERSION}_stage0"
    add_base_candidate "./build/${VERSION}.out"
    add_base_candidate "./build/tmp/dev_stage0"
    add_base_candidate "$(pick_old_latest_stage1_file || true)"
    add_base_candidate "./bin/bootstrap"
    add_base_candidate "./bin/${BASE_COMPILER}"
    add_base_candidate "./bin/${VERSION}"
    add_base_candidate "$(pick_latest_stage1_file || true)"

    for candidate in "${BASE_CANDIDATES[@]}"; do
        if base_compiler_smoke_check "$candidate"; then
            BASE_BIN="$candidate"
            break
        fi
        echo "   [WARN] Skipping unusable base compiler: $candidate"
    done
    if [ -z "$BASE_BIN" ]; then
        downloaded_base="$(download_bootstrap_compiler || true)"
        if [ -n "$downloaded_base" ]; then
            if base_compiler_smoke_check "$downloaded_base"; then
                BASE_BIN="$downloaded_base"
            else
                echo "   [WARN] Skipping unusable downloaded bootstrap compiler: $downloaded_base"
            fi
        fi
    fi
elif ! base_compiler_smoke_check "$BASE_BIN"; then
    echo "Error: BPP_BASE_COMPILER failed the smoke compile: $BASE_BIN"
    echo "   Set BPP_SKIP_BASE_SMOKE=1 to bypass this check."
    exit 1
fi
if [ -z "$BASE_BIN" ]; then
    echo "Error: Base compiler not found."
    echo "   Tried: build/tmp/dev_stage0, build/${VERSION}.out, bin/${VERSION}_stage0, old/<latest>/bin/*, bin/<old_latest>_stage1, bin/stage1, bin/bootstrap, bin/${BASE_COMPILER}, bin/${VERSION}_stage1, bin/${VERSION}, bin/*_stage1"
    echo "   Download fallback: ${BPP_BOOTSTRAP_BASE_URL:-https://github.com}/${BPP_BOOTSTRAP_REPOSITORY:-Creeper0809/Bpp}/releases/download/${BPP_BOOTSTRAP_RELEASE_TAG:-bootstrap-${VERSION}}/${BPP_BOOTSTRAP_ASSET_LINUX:-bpp-bootstrap-${VERSION}-linux-x86_64}"
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
STAGE1_USABLE=1
TEST_COMPILER_BIN="bin/${VERSION}_stage1"
FINAL_ASM="$STAGE1_ASM"
if base_compiler_smoke_check "./bin/${VERSION}_stage1"; then
    # Unversioned pointer to latest successful stage1 output.
    cp -f "bin/${VERSION}_stage1" "bin/stage1"
else
    STAGE1_USABLE=0
    TEST_COMPILER_BIN="bin/${VERSION}_stage0"
    FINAL_ASM="$STAGE0_ASM"
    cp -f "bin/${VERSION}_stage0" "bin/stage1"
    echo "   [WARN] Generated stage1 failed smoke check; using stage0 for tests and final executable."
fi
echo "Stage 1 Build Completed"
echo ""

STAGE2_PID=""
STAGE2_DONE=0

run_stage2_verify() {
    ./bin/${VERSION}_stage1 -asm "${SRC_FILE}" > "${STAGE2_ASM}"
    echo "Stage 2 Build Completed"
    echo ""

    echo "[4/6] Self-Hosting Verification..."
    if cmp -s "${STAGE1_ASM}" "${STAGE2_ASM}"; then
        echo "Self-Hosting Success! (Stage 1 == Stage 2)"
        echo "   ASM: $(wc -l < "${STAGE1_ASM}") lines"
    else
        echo "Self-Hosting Failed! ASM is different."
        echo "   Stage 1: $(wc -l < "${STAGE1_ASM}") lines"
        echo "   Stage 2: $(wc -l < "${STAGE2_ASM}") lines"
        return 1
    fi
    echo ""
    return 0
}

wait_stage2_verify() {
    if [ -z "$STAGE2_PID" ]; then
        return 0
    fi
    local status=0
    wait "$STAGE2_PID" || status=$?
    STAGE2_PID=""
    STAGE2_DONE=1
    if [ -f "$STAGE2_LOG" ]; then
        cat "$STAGE2_LOG"
    fi
    return "$status"
}

# Step 3: 셀프 호스팅 (2단계)
if [ "$SELFHOST_VERIFY" = "1" ] && [ "$STAGE1_USABLE" = "1" ]; then
    echo "[3/6] Self-Hosting Stage 2..."
    if [ "$SELFHOST_VERIFY_ASYNC" = "1" ]; then
        echo "   (running in background; tests will run in parallel)"
        ( run_stage2_verify ) > "$STAGE2_LOG" 2>&1 &
        STAGE2_PID=$!
        echo ""
        echo "[4/6] Self-Hosting Verification... pending"
        echo ""
    else
        run_stage2_verify
        STAGE2_DONE=1
        FINAL_ASM="$STAGE2_ASM"
    fi
else
    if [ "$SELFHOST_VERIFY" = "1" ]; then
        echo "[3/6] Self-Hosting Stage 2... skipped (stage1 smoke check failed)"
    else
        echo "[3/6] Self-Hosting Stage 2... skipped (SELFHOST_VERIFY=0)"
    fi
    echo ""
    if [ "$SELFHOST_VERIFY" = "1" ]; then
        echo "[4/6] Self-Hosting Verification... skipped (stage1 smoke check failed)"
    else
        echo "[4/6] Self-Hosting Verification... skipped (SELFHOST_VERIFY=0)"
    fi
    echo ""
fi

# Persist ASM artifacts under build/ as before.
cp "${STAGE0_ASM}" "build/${VERSION}_stage0.asm"
cp "${STAGE1_ASM}" "build/${VERSION}_stage1.asm"
if [ "$SELFHOST_VERIFY" = "1" ] && [ "$STAGE2_DONE" = "1" ] && [ -f "${STAGE2_ASM}" ]; then
    cp "${STAGE2_ASM}" "build/${VERSION}_stage2.asm"
fi

# Step 5: 테스트 실행
echo "[5/6] Running Tests..."
TEST_STATUS=0
TEST_FAST_IO="$TEST_FAST_IO" TEST_QUIET="$TEST_QUIET" KEEP_TEST_ARTIFACTS="$KEEP_TEST_ARTIFACTS" \
TEST_SKIP_LLVM_BUILD="$TEST_SKIP_LLVM_BUILD" TEST_JOBS="$TEST_JOBS" TEST_PROFILE="$TEST_PROFILE" TEST_SUITE_CASE_LIMIT="$TEST_SUITE_CASE_LIMIT" TEST_NAME_FILTER="$TEST_NAME_FILTER" COMPILE_FAIL_SINGLE_VARIANT="$COMPILE_FAIL_SINGLE_VARIANT" STRESS_RUNS="$STRESS_RUNS" STABILITY_RUNS="$STABILITY_RUNS" \
  bash ${TEST_SCRIPT} "${TEST_COMPILER_BIN}" 2>&1 | tail -15 || TEST_STATUS=$?

if [ -n "$STAGE2_PID" ]; then
    echo ""
    echo "[3/6] Self-Hosting Stage 2 / [4/6] Verification result..."
    if wait_stage2_verify; then
        FINAL_ASM="$STAGE2_ASM"
        cp "${STAGE2_ASM}" "build/${VERSION}_stage2.asm"
    else
        exit 1
    fi
fi

if [ "$TEST_STATUS" -ne 0 ]; then
    exit "$TEST_STATUS"
fi

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
