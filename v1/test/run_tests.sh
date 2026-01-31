#!/bin/bash
# B Test Runner
# Runs all tests

set -e

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
BUILD_DIR="build/${VERSION}_tests"
RESULTS_DIR="build/test_results"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "$BUILD_DIR"
mkdir -p "$RESULTS_DIR"

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
        echo "[SKIP] Duplicate content: $TEST_NAME (same as ${SEEN_HASH[$CONTENT_HASH]})"
        continue
    fi
    SEEN_HASH[$CONTENT_HASH]="$TEST_NAME"

    # Parse test directives from the test file using awk for cleaner extraction.
    EXPECTED=$(grep -m1 -E '^// Expect exit code:' "$TEST_FILE" | awk -F': ' '{print $2}' | tr -d ' ' || echo "0")

    # Fallback to 0 if EXPECTED is empty after parsing.
    if [ -z "$EXPECTED" ]; then
        EXPECTED=0
    fi

    for MODE in nossa ssa; do
        for OPT in O0 O1; do
            TOTAL=$((TOTAL + 1))
            echo -n "[$TOTAL] Testing $TEST_NAME ($MODE $OPT)... "

            ASM_FILE="$BUILD_DIR/${TEST_NAME}.${MODE}.${OPT}.asm"
            OBJ_FILE="$BUILD_DIR/${TEST_NAME}.${MODE}.${OPT}.o"
            BIN_FILE="$BUILD_DIR/${TEST_NAME}.${MODE}.${OPT}"
            OUT_FILE="$RESULTS_DIR/${TEST_NAME}.${MODE}.${OPT}.out"
            ERR_FILE="$RESULTS_DIR/${TEST_NAME}.${MODE}.${OPT}.err"

            # Set compiler flags based on mode/opt matrix.
            IR_FLAG=""
            if [ "$MODE" = "ssa" ]; then
                IR_FLAG="-dump-ssa"
            fi

            OPT_FLAG=""
            if [ "$OPT" = "O1" ]; then
                OPT_FLAG="-O1"
            fi

            if ! $COMPILER $OPT_FLAG $IR_FLAG -asm "$TEST_FILE" 2>/dev/null > "$ASM_FILE"; then
                echo -e "${RED}FAIL (compile)${NC}"
                echo "Compilation failed" > "$ERR_FILE"
                FAILED=$((FAILED + 1))
                continue
            fi

            # Assemble
            if ! nasm -f elf64 "$ASM_FILE" -o "$OBJ_FILE" 2>"$ERR_FILE"; then
                echo -e "${RED}FAIL (assemble)${NC}"
                FAILED=$((FAILED + 1))
                continue
            fi

            # Link
            if ! ld "$OBJ_FILE" -o "$BIN_FILE" 2>>"$ERR_FILE"; then
                echo -e "${RED}FAIL (link)${NC}"
                FAILED=$((FAILED + 1))
                continue
            fi

            # Run (compare exit code with expected)
            set +e
            timeout 5s "$BIN_FILE" > "$OUT_FILE" 2>&1
            EXIT_CODE=$?
            set -e

            if [ "$EXIT_CODE" -eq "$EXPECTED" ]; then
                echo -e "${GREEN}PASS${NC} (exit=$EXIT_CODE)"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}FAIL${NC} (exit=$EXIT_CODE, expect=$EXPECTED)"
                FAILED=$((FAILED + 1))
                continue
            fi

            # Stress test: run the binary multiple times to catch flakiness.
            if [ "$STRESS_RUNS" -gt 0 ]; then
                STRESS_OK=1
                for ((i=1; i<=STRESS_RUNS; i++)); do
                    set +e
                    timeout 5s "$BIN_FILE" > "$OUT_FILE" 2>&1
                    STRESS_EXIT=$?
                    set -e
                    if [ "$STRESS_EXIT" -ne "$EXPECTED" ]; then
                        STRESS_OK=0
                        break
                    fi
                done
                if [ "$STRESS_OK" -eq 1 ]; then
                    echo -e "${GREEN}STRESS PASS${NC} (runs=$STRESS_RUNS)"
                    STRESS_PASSED=$((STRESS_PASSED + 1))
                else
                    echo -e "${RED}STRESS FAIL${NC} (run=$i, exit=$STRESS_EXIT, expect=$EXPECTED)"
                    STRESS_FAILED=$((STRESS_FAILED + 1))
                    FAILED=$((FAILED + 1))
                    continue
                fi
            fi

            # Stability test: shorter loop with an explicit label.
            if [ "$STABILITY_RUNS" -gt 0 ]; then
                STABILITY_OK=1
                for ((i=1; i<=STABILITY_RUNS; i++)); do
                    set +e
                    timeout 5s "$BIN_FILE" > "$OUT_FILE" 2>&1
                    STABILITY_EXIT=$?
                    set -e
                    if [ "$STABILITY_EXIT" -ne "$EXPECTED" ]; then
                        STABILITY_OK=0
                        break
                    fi
                done
                if [ "$STABILITY_OK" -eq 1 ]; then
                    echo -e "${GREEN}STABILITY PASS${NC} (runs=$STABILITY_RUNS)"
                    STABILITY_PASSED=$((STABILITY_PASSED + 1))
                else
                    echo -e "${RED}STABILITY FAIL${NC} (run=$i, exit=$STABILITY_EXIT, expect=$EXPECTED)"
                    STABILITY_FAILED=$((STABILITY_FAILED + 1))
                    FAILED=$((FAILED + 1))
                fi
            fi
        done
    done
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

    echo -n "[$TOTAL] IR $TEST_NAME... "

    SSA_OUT="$RESULTS_DIR/${TEST_NAME}.ssa.ir"
    ADDR_OUT="$RESULTS_DIR/${TEST_NAME}.3addr.ir"
    ERR_FILE="$RESULTS_DIR/${TEST_NAME}.ir.err"

    if ! $COMPILER -dump-ssa "$TEST_FILE" > "$SSA_OUT" 2>"$ERR_FILE"; then
        echo -e "${RED}FAIL${NC} (ssa dump)"
        FAILED=$((FAILED + 1))
        continue
    fi
    if ! grep -q "phi" "$SSA_OUT"; then
        echo -e "${RED}FAIL${NC} (ssa missing phi)"
        FAILED=$((FAILED + 1))
        continue
    fi
    if ! $COMPILER -dump-ir "$TEST_FILE" > "$ADDR_OUT" 2>>"$ERR_FILE"; then
        echo -e "${RED}FAIL${NC} (3addr dump)"
        FAILED=$((FAILED + 1))
        continue
    fi
    if grep -q "phi" "$ADDR_OUT"; then
        echo -e "${RED}FAIL${NC} (3addr has phi)"
        FAILED=$((FAILED + 1))
        continue
    fi

    echo -e "${GREEN}PASS${NC}"
    PASSED=$((PASSED + 1))
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
