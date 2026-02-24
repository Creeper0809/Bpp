#!/bin/bash
# B Test Runner
# Runs all tests

set -e
set -o pipefail

# Load version from config.ini
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.ini"

# 프로젝트 루트로 이동 (bpp/v1/test -> repo root)
ROOT_DIR="$SCRIPT_DIR/../.."
cd "$ROOT_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.ini not found at $CONFIG_FILE"
    exit 1
fi

# Parse config.ini (simple key=value format)
source <(grep -E '^(VERSION|PREV_VERSION)=' "$CONFIG_FILE")

if [ -z "$VERSION" ]; then
    echo "Error: VERSION not set in config.ini"
    exit 1
fi

COMPILER="$ROOT_DIR/bin/${VERSION}_stage1"
TEST_DIR="${VERSION}/test/source"
IR_TEST_DIR="${VERSION}/test/ir"
BUILD_DIR_BASE="build/${VERSION}_tests"
RESULTS_DIR_BASE="build/test_results"

TEST_FAST_IO=${TEST_FAST_IO:-0}
TEST_QUIET=${TEST_QUIET:-0}
KEEP_TEST_ARTIFACTS=${KEEP_TEST_ARTIFACTS:-1}
TEST_JOBS=${TEST_JOBS:-0}
FAST_IO_ACTIVE=0

BUILD_DIR="$BUILD_DIR_BASE"
RESULTS_DIR="$RESULTS_DIR_BASE"
if [ "$TEST_FAST_IO" -eq 1 ] && [ -d "/dev/shm" ] && [ -w "/dev/shm" ]; then
    WORK_DIR="$(mktemp -d "/dev/shm/bpp_${VERSION}_tests_XXXXXX")"
    BUILD_DIR="$WORK_DIR/${VERSION}_tests"
    RESULTS_DIR="$WORK_DIR/test_results"
    FAST_IO_ACTIVE=1
    trap 'rm -rf "$WORK_DIR"' EXIT
fi

persist_result_file() {
    local src="$1"
    local dst="$2"
    if [ "$FAST_IO_ACTIVE" -eq 1 ] && [ -f "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
    fi
}

detect_test_jobs() {
    if [ "$TEST_JOBS" -gt 0 ]; then
        return
    fi
    local detected=4
    if command -v nproc >/dev/null 2>&1; then
        detected="$(nproc)"
    fi
    if [ "$detected" -lt 1 ]; then
        detected=1
    fi
    TEST_JOBS="$detected"
}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "$BUILD_DIR"
mkdir -p "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR_BASE"

# Counters
TOTAL=0
PASSED=0
FAILED=0

# Stress/Stability settings (override via env)
STRESS_RUNS=${STRESS_RUNS:-20}
STABILITY_RUNS=${STABILITY_RUNS:-5}
STRESS_PASSED=0
STRESS_FAILED=0
STABILITY_PASSED=0
STABILITY_FAILED=0

# De-dup by content (ignore directive headers)
declare -A SEEN_HASH

echo "========================================"
echo "${VERSION} Compiler Test Suite"
echo "========================================"
echo ""
if [ "$FAST_IO_ACTIVE" -eq 1 ] && [ "$TEST_QUIET" -eq 0 ]; then
    echo "[INFO] Fast test I/O enabled: $WORK_DIR"
    echo ""
fi

detect_test_jobs
if [ "$TEST_QUIET" -eq 0 ]; then
    echo "[INFO] Parallel jobs: $TEST_JOBS"
    echo ""
fi

JOBS_DIR="$RESULTS_DIR/.jobs"
mkdir -p "$JOBS_DIR"
rm -f "$JOBS_DIR"/*.result 2>/dev/null || true
RUN_TAG="run_$$"
CASE_RESULT_FILES=()
IR_RESULT_FILES=()

launch_job_with_limit() {
    while [ "$(jobs -rp | wc -l)" -ge "$TEST_JOBS" ]; do
        wait -n || true
    done
    "$@" &
}

run_matrix_case() {
    set +e
    local case_num="$1"
    local test_file="$2"
    local test_name="$3"
    local mode="$4"
    local opt="$5"
    local expected="$6"
    local result_file="$7"

    local case_tag="[$case_num] Testing $test_name ($mode $opt)"
    local case_pass=0
    local case_fail=0
    local case_stress_pass=0
    local case_stress_fail=0
    local case_stability_pass=0
    local case_stability_fail=0
    local case_status="PASS"

    local asm_file="$BUILD_DIR/${test_name}.${mode}.${opt}.asm"
    local obj_file="$BUILD_DIR/${test_name}.${mode}.${opt}.o"
    local bin_file="$BUILD_DIR/${test_name}.${mode}.${opt}"
    local out_file="$RESULTS_DIR/${test_name}.${mode}.${opt}.out"
    local err_file="$RESULTS_DIR/${test_name}.${mode}.${opt}.err"
    local out_file_persist="$RESULTS_DIR_BASE/${test_name}.${mode}.${opt}.out"
    local err_file_persist="$RESULTS_DIR_BASE/${test_name}.${mode}.${opt}.err"

    rm -f "$out_file" "$err_file"

    local ir_flag=""
    if [ "$mode" = "ssa" ]; then
        ir_flag="-dump-ssa"
    fi
    local opt_flag=""
    if [ "$opt" = "O1" ]; then
        opt_flag="-O1"
    fi

    if ! $COMPILER $opt_flag $ir_flag -asm "$test_file" > "$asm_file" 2>"$err_file"; then
        echo "Compilation failed" > "$err_file"
        persist_result_file "$err_file" "$err_file_persist"
        case_fail=1
        case_status="FAIL (compile)"
    else
        if ! nasm -f elf64 -O0 "$asm_file" -o "$obj_file" 2>"$err_file"; then
            persist_result_file "$err_file" "$err_file_persist"
            case_fail=1
            case_status="FAIL (assemble)"
        elif ! ld "$obj_file" -o "$bin_file" 2>>"$err_file"; then
            persist_result_file "$err_file" "$err_file_persist"
            case_fail=1
            case_status="FAIL (link)"
        else
            timeout 5s "$bin_file" >/dev/null 2>/dev/null
            local exit_code="$?"
            if [ "$exit_code" -eq "$expected" ]; then
                case_pass=1
                if [ "$STRESS_RUNS" -gt 0 ]; then
                    local stress_ok=1
                    local i=0
                    local stress_exit=0
                    for ((i=1; i<=STRESS_RUNS; i++)); do
                        timeout 5s "$bin_file" >/dev/null 2>/dev/null
                        stress_exit="$?"
                        if [ "$stress_exit" -ne "$expected" ]; then
                            stress_ok=0
                            break
                        fi
                    done
                    if [ "$stress_ok" -eq 1 ]; then
                        case_stress_pass=1
                    else
                        case_stress_fail=1
                        case_fail=$((case_fail + 1))
                        case_status="STRESS FAIL (run=$i, exit=$stress_exit, expect=$expected)"
                    fi
                fi

                if [ "$case_stress_fail" -eq 0 ] && [ "$STABILITY_RUNS" -gt 0 ]; then
                    local stability_ok=1
                    local j=0
                    local stability_exit=0
                    for ((j=1; j<=STABILITY_RUNS; j++)); do
                        timeout 5s "$bin_file" >/dev/null 2>/dev/null
                        stability_exit="$?"
                        if [ "$stability_exit" -ne "$expected" ]; then
                            stability_ok=0
                            break
                        fi
                    done
                    if [ "$stability_ok" -eq 1 ]; then
                        case_stability_pass=1
                    else
                        case_stability_fail=1
                        case_fail=$((case_fail + 1))
                        case_status="STABILITY FAIL (run=$j, exit=$stability_exit, expect=$expected)"
                    fi
                fi
            else
                timeout 5s "$bin_file" > "$out_file" 2>&1
                persist_result_file "$out_file" "$out_file_persist"
                case_fail=1
                case_status="FAIL (exit=$exit_code, expect=$expected)"
            fi
        fi
    fi

    if [ "$KEEP_TEST_ARTIFACTS" -eq 0 ]; then
        rm -f "$asm_file" "$obj_file" "$bin_file" "$out_file" "$err_file"
    fi

    {
        echo "CASE_TAG=\"$case_tag\""
        echo "CASE_STATUS=\"$case_status\""
        echo "CASE_PASS=$case_pass"
        echo "CASE_FAIL=$case_fail"
        echo "CASE_STRESS_PASS=$case_stress_pass"
        echo "CASE_STRESS_FAIL=$case_stress_fail"
        echo "CASE_STABILITY_PASS=$case_stability_pass"
        echo "CASE_STABILITY_FAIL=$case_stability_fail"
    } > "$result_file"
    return 0
}

run_ir_case() {
    set +e
    local case_num="$1"
    local test_file="$2"
    local test_name="$3"
    local result_file="$4"

    local case_tag="[$case_num] IR $test_name"
    local case_pass=0
    local case_fail=0
    local case_status="PASS"

    local ssa_out="$RESULTS_DIR/${test_name}.ssa.ir"
    local addr_out="$RESULTS_DIR/${test_name}.3addr.ir"
    local err_file="$RESULTS_DIR/${test_name}.ir.err"
    local err_file_persist="$RESULTS_DIR_BASE/${test_name}.ir.err"
    rm -f "$err_file"

    if ! $COMPILER -dump-ssa "$test_file" > "$ssa_out" 2>"$err_file"; then
        persist_result_file "$err_file" "$err_file_persist"
        case_fail=1
        case_status="FAIL (ssa dump)"
    elif ! grep -q "phi" "$ssa_out"; then
        case_fail=1
        case_status="FAIL (ssa missing phi)"
    elif ! $COMPILER -dump-ir "$test_file" > "$addr_out" 2>>"$err_file"; then
        persist_result_file "$err_file" "$err_file_persist"
        case_fail=1
        case_status="FAIL (3addr dump)"
    elif grep -q "phi" "$addr_out"; then
        case_fail=1
        case_status="FAIL (3addr has phi)"
    else
        case_pass=1
    fi

    if [ "$KEEP_TEST_ARTIFACTS" -eq 0 ]; then
        rm -f "$ssa_out" "$addr_out" "$err_file"
    fi

    {
        echo "CASE_TAG=\"$case_tag\""
        echo "CASE_STATUS=\"$case_status\""
        echo "CASE_PASS=$case_pass"
        echo "CASE_FAIL=$case_fail"
    } > "$result_file"
    return 0
}

# Find all test files (exclude module files)
TEST_FILES=$(ls $TEST_DIR/*.bpp 2>/dev/null | grep -E '/[0-9]+_' | sort -V)
if [ -z "$TEST_FILES" ]; then
    echo "No test files found in $TEST_DIR"
    exit 1
fi

for TEST_FILE in $TEST_FILES; do
    TEST_NAME=$(basename "$TEST_FILE" .bpp)
    CONTENT_HASH=$(awk '{if ($0 !~ /^\/\/ (Covers:|Mode:|Opt:|Expect exit code:)/) print}' "$TEST_FILE" | md5sum | awk '{print $1}')
    if [ -n "${SEEN_HASH[$CONTENT_HASH]}" ]; then
        if [ "$TEST_QUIET" -eq 0 ]; then
            echo "[SKIP] Duplicate content: $TEST_NAME (same as ${SEEN_HASH[$CONTENT_HASH]})"
        fi
        continue
    fi
    SEEN_HASH[$CONTENT_HASH]="$TEST_NAME"

    EXPECTED=$(grep -m1 -E '^// Expect exit code:' "$TEST_FILE" | awk -F': ' '{print $2}' | tr -d ' ' || echo "0")
    if [ -z "$EXPECTED" ]; then
        EXPECTED=0
    fi

    for MODE in nossa ssa; do
        for OPT in O0 O1; do
            TOTAL=$((TOTAL + 1))
            RESULT_FILE="$JOBS_DIR/${RUN_TAG}_case_${TOTAL}.result"
            CASE_RESULT_FILES+=("$RESULT_FILE")
            launch_job_with_limit run_matrix_case "$TOTAL" "$TEST_FILE" "$TEST_NAME" "$MODE" "$OPT" "$EXPECTED" "$RESULT_FILE"
        done
    done
done

wait || true

for RESULT_FILE in "${CASE_RESULT_FILES[@]}"; do
    if [ ! -f "$RESULT_FILE" ]; then
        FAILED=$((FAILED + 1))
        continue
    fi
    CASE_TAG=""
    CASE_STATUS=""
    CASE_PASS=0
    CASE_FAIL=0
    CASE_STRESS_PASS=0
    CASE_STRESS_FAIL=0
    CASE_STABILITY_PASS=0
    CASE_STABILITY_FAIL=0
    source "$RESULT_FILE"

    PASSED=$((PASSED + CASE_PASS))
    FAILED=$((FAILED + CASE_FAIL))
    STRESS_PASSED=$((STRESS_PASSED + CASE_STRESS_PASS))
    STRESS_FAILED=$((STRESS_FAILED + CASE_STRESS_FAIL))
    STABILITY_PASSED=$((STABILITY_PASSED + CASE_STABILITY_PASS))
    STABILITY_FAILED=$((STABILITY_FAILED + CASE_STABILITY_FAIL))

    if [ "$TEST_QUIET" -eq 0 ]; then
        if [ "$CASE_FAIL" -eq 0 ]; then
            echo -e "${GREEN}${CASE_TAG} ${CASE_STATUS}${NC}"
        else
            echo -e "${RED}${CASE_TAG} ${CASE_STATUS}${NC}"
        fi
    fi
done

IR_TEST_FILES=$(ls $IR_TEST_DIR/*.bpp 2>/dev/null | sort -V)
if [ -n "$IR_TEST_FILES" ]; then
    echo ""
    echo "========================================"
    echo "IR Dump Tests"
    echo "========================================"
    echo ""
fi

for TEST_FILE in $IR_TEST_FILES; do
    TOTAL=$((TOTAL + 1))
    TEST_NAME=$(basename "$TEST_FILE" .bpp)
    RESULT_FILE="$JOBS_DIR/${RUN_TAG}_ir_${TOTAL}.result"
    IR_RESULT_FILES+=("$RESULT_FILE")
    launch_job_with_limit run_ir_case "$TOTAL" "$TEST_FILE" "$TEST_NAME" "$RESULT_FILE"
done

wait || true

for RESULT_FILE in "${IR_RESULT_FILES[@]}"; do
    if [ ! -f "$RESULT_FILE" ]; then
        FAILED=$((FAILED + 1))
        continue
    fi
    CASE_TAG=""
    CASE_STATUS=""
    CASE_PASS=0
    CASE_FAIL=0
    source "$RESULT_FILE"
    PASSED=$((PASSED + CASE_PASS))
    FAILED=$((FAILED + CASE_FAIL))

    if [ "$TEST_QUIET" -eq 0 ]; then
        if [ "$CASE_FAIL" -eq 0 ]; then
            echo -e "${GREEN}${CASE_TAG} ${CASE_STATUS}${NC}"
        else
            echo -e "${RED}${CASE_TAG} ${CASE_STATUS}${NC}"
        fi
    fi
done

echo ""
echo "========================================"
echo "Test Results"
echo "========================================"
echo "Total:  $TOTAL"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo -e "Stress: ${GREEN}$STRESS_PASSED${NC} passed, ${RED}$STRESS_FAILED${NC} failed"
echo -e "Stability: ${GREEN}$STABILITY_PASSED${NC} passed, ${RED}$STABILITY_FAILED${NC} failed"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
