#!/bin/bash
# B Test Runner
# Runs all tests

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
CONFIG_FILE="$ROOT_DIR/config.ini"

# 프로젝트 루트로 이동 (repo/test -> repo root)
cd "$ROOT_DIR"

read_config_value() {
    local key="$1"
    if [ ! -f "$CONFIG_FILE" ]; then
        return 0
    fi
    grep -E "^${key}=" "$CONFIG_FILE" | head -n1 | cut -d'=' -f2- | tr -d '[:space:]'
}

detect_latest_stage1_compiler() {
    local best_ver=-1
    local best_file=""
    local f base ver

    for f in "$ROOT_DIR"/bin/v*_stage1; do
        [ -x "$f" ] || continue
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

    for f in "$ROOT_DIR"/bin/*_stage1; do
        [ -x "$f" ] || continue
        base="$(basename "$f")"
        if [[ "$base" == _* ]]; then
            continue
        fi
        best_file="$f"
    done
    if [ -n "$best_file" ]; then
        echo "$best_file"
        return 0
    fi
    return 1
}

detect_default_compiler() {
    if [ -n "${BPP_COMPILER:-}" ] && [ -x "${BPP_COMPILER}" ]; then
        echo "$BPP_COMPILER"
        return 0
    fi

    local version_hint="${BPP_VERSION:-}"
    if [ -z "$version_hint" ]; then
        version_hint="$(read_config_value VERSION)"
    fi

    if [ -n "$version_hint" ] && [ -x "$ROOT_DIR/bin/${version_hint}_stage1" ]; then
        echo "$ROOT_DIR/bin/${version_hint}_stage1"
        return 0
    fi

    if [ -x "$ROOT_DIR/bin/bootstrap" ]; then
        echo "$ROOT_DIR/bin/bootstrap"
        return 0
    fi

    if [ -x "$ROOT_DIR/bin/stage1" ]; then
        echo "$ROOT_DIR/bin/stage1"
        return 0
    fi

    local candidate=""
    candidate="$(detect_latest_stage1_compiler || true)"
    if [ -n "$candidate" ]; then
        echo "$candidate"
        return 0
    fi

    return 1
}

derive_version_label() {
    local compiler_path="$1"
    local base
    base="$(basename "$compiler_path")"
    if [[ "$base" =~ ^(.+)_stage1(\.exe)?$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    if [ -n "${BPP_VERSION:-}" ]; then
        echo "$BPP_VERSION"
        return 0
    fi
    local cfg
    cfg="$(read_config_value VERSION)"
    if [ -n "$cfg" ]; then
        echo "$cfg"
        return 0
    fi
    echo "bpp"
}

COMPILER="${1:-}"
if [ -z "$COMPILER" ]; then
    COMPILER="$(detect_default_compiler)" || {
        echo "Error: Compiler not found."
        echo "  Tried: BPP_COMPILER, bin/\${BPP_VERSION}_stage1, bin/bootstrap, bin/stage1, bin/*_stage1"
        exit 1
    }
fi
if [ ! -x "$COMPILER" ]; then
    echo "Error: Compiler not found or not executable: $COMPILER"
    exit 1
fi

VERSION="$(derive_version_label "$COMPILER")"
TEST_DIR="test/source"
IR_TEST_DIR="test/ir"
BUILD_DIR_BASE="build/${VERSION}_tests"
RESULTS_DIR_BASE="build/test_results"

TEST_FAST_IO=${TEST_FAST_IO:-0}
TEST_QUIET=${TEST_QUIET:-0}
KEEP_TEST_ARTIFACTS=${KEEP_TEST_ARTIFACTS:-1}
TEST_JOBS=${TEST_JOBS:-0}
TEST_PROFILE=${TEST_PROFILE:-full}
TEST_MODE_FILTER=${TEST_MODE_FILTER:-}
TEST_OPT_FILTER=${TEST_OPT_FILTER:-}
COMPILE_FAIL_SINGLE_VARIANT=${COMPILE_FAIL_SINGLE_VARIANT:-}
TEST_SUITE_CASE_LIMIT=${TEST_SUITE_CASE_LIMIT:-}
STRICT_FAIL_DIAGNOSTICS=${STRICT_FAIL_DIAGNOSTICS:-1}
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

normalize_modes_csv() {
    local raw
    raw="$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
    case "$raw" in
        ""|"both"|"all")
            echo "nossa,ssa"
            ;;
        "nossa"|"ssa")
            echo "$raw"
            ;;
        "nossa,ssa"|"ssa,nossa")
            echo "nossa,ssa"
            ;;
        *)
            local out=""
            IFS=',' read -r -a parts <<< "$raw"
            for p in "${parts[@]}"; do
                if [ "$p" != "nossa" ] && [ "$p" != "ssa" ]; then
                    continue
                fi
                if [[ ",$out," != *",$p,"* ]]; then
                    if [ -z "$out" ]; then
                        out="$p"
                    else
                        out="$out,$p"
                    fi
                fi
            done
            if [ -n "$out" ]; then
                echo "$out"
            else
                echo "nossa,ssa"
            fi
            ;;
    esac
}

normalize_opts_csv() {
    local raw
    raw="$(echo "$1" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')"
    case "$raw" in
        ""|"BOTH"|"ALL")
            echo "O0,O1"
            ;;
        "O0"|"O1")
            echo "$raw"
            ;;
        "O0,O1"|"O1,O0")
            echo "O0,O1"
            ;;
        *)
            local out=""
            IFS=',' read -r -a parts <<< "$raw"
            for p in "${parts[@]}"; do
                if [ "$p" != "O0" ] && [ "$p" != "O1" ]; then
                    continue
                fi
                if [[ ",$out," != *",$p,"* ]]; then
                    if [ -z "$out" ]; then
                        out="$p"
                    else
                        out="$out,$p"
                    fi
                fi
            done
            if [ -n "$out" ]; then
                echo "$out"
            else
                echo "O0,O1"
            fi
            ;;
    esac
}

csv_has() {
    local csv="$1"
    local needle="$2"
    [[ ",$csv," == *",$needle,"* ]]
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

# Resolve profile defaults first, then normalize filters.
if [ -z "$TEST_MODE_FILTER" ]; then
    if [ "$TEST_PROFILE" = "quick" ]; then
        TEST_MODE_FILTER="nossa"
    else
        TEST_MODE_FILTER="nossa,ssa"
    fi
fi
if [ -z "$TEST_OPT_FILTER" ]; then
    if [ "$TEST_PROFILE" = "quick" ]; then
        TEST_OPT_FILTER="O1"
    else
        TEST_OPT_FILTER="O0,O1"
    fi
fi
if [ -z "$COMPILE_FAIL_SINGLE_VARIANT" ]; then
    if [ "$TEST_PROFILE" = "quick" ]; then
        COMPILE_FAIL_SINGLE_VARIANT=1
    else
        COMPILE_FAIL_SINGLE_VARIANT=0
    fi
fi
if [ -z "$TEST_SUITE_CASE_LIMIT" ]; then
    TEST_SUITE_CASE_LIMIT=0
fi
if ! [[ "$TEST_SUITE_CASE_LIMIT" =~ ^[0-9]+$ ]]; then
    echo "Error: TEST_SUITE_CASE_LIMIT must be a non-negative integer"
    exit 1
fi

GLOBAL_MODES_CSV="$(normalize_modes_csv "$TEST_MODE_FILTER")"
GLOBAL_OPTS_CSV="$(normalize_opts_csv "$TEST_OPT_FILTER")"

# Stress/Stability settings (override via env; quick profile disables by default)
if [ -z "${STRESS_RUNS+x}" ]; then
    if [ "$TEST_PROFILE" = "quick" ]; then
        STRESS_RUNS=0
    else
        STRESS_RUNS=20
    fi
fi
if [ -z "${STABILITY_RUNS+x}" ]; then
    if [ "$TEST_PROFILE" = "quick" ]; then
        STABILITY_RUNS=0
    else
        STABILITY_RUNS=5
    fi
fi
STRESS_PASSED=0
STRESS_FAILED=0
STABILITY_PASSED=0
STABILITY_FAILED=0

# De-dup by content (ignore directive headers)
declare -A SEEN_HASH
declare -A TEST_DISPLAY_NAME

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
    echo "[INFO] Profile: $TEST_PROFILE"
    echo "[INFO] Mode filter: $GLOBAL_MODES_CSV"
    echo "[INFO] Opt filter: $GLOBAL_OPTS_CSV"
    echo "[INFO] Compile-fail single variant: $COMPILE_FAIL_SINGLE_VARIANT"
    echo "[INFO] Strict fail diagnostics: $STRICT_FAIL_DIAGNOSTICS"
    echo "[INFO] Suite case limit: $TEST_SUITE_CASE_LIMIT (0=all)"
    echo "[INFO] Stress runs: $STRESS_RUNS"
    echo "[INFO] Stability runs: $STABILITY_RUNS"
    echo ""
fi

JOBS_DIR="$RESULTS_DIR/.jobs"
mkdir -p "$JOBS_DIR"
rm -f "$JOBS_DIR"/*.result 2>/dev/null || true
rm -f "$JOBS_DIR"/*.expect 2>/dev/null || true
RUN_TAG="run_$$"
CASE_RESULT_FILES=()
IR_RESULT_FILES=()
SUITE_CASES_DIR="$ROOT_DIR/build/${VERSION}_suite_cases/$RUN_TAG"
mkdir -p "$SUITE_CASES_DIR"

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
    local test_id="$3"
    local test_label="$4"
    local mode="$5"
    local opt="$6"
    local expected="$7"
    local expect_compile_fail="$8"
    local expect_error_file="$9"
    local result_file="${10}"

    local case_tag="[$case_num] Testing $test_label ($mode $opt)"
    local case_pass=0
    local case_fail=0
    local case_stress_pass=0
    local case_stress_fail=0
    local case_stability_pass=0
    local case_stability_fail=0
    local case_status="PASS"

    local asm_file="$BUILD_DIR/${test_id}.${mode}.${opt}.asm"
    local obj_file="$BUILD_DIR/${test_id}.${mode}.${opt}.o"
    local bin_file="$BUILD_DIR/${test_id}.${mode}.${opt}"
    local out_file="$RESULTS_DIR/${test_id}.${mode}.${opt}.out"
    local err_file="$RESULTS_DIR/${test_id}.${mode}.${opt}.err"
    local out_file_persist="$RESULTS_DIR_BASE/${test_id}.${mode}.${opt}.out"
    local err_file_persist="$RESULTS_DIR_BASE/${test_id}.${mode}.${opt}.err"

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
        persist_result_file "$err_file" "$err_file_persist"
        if [ "$expect_compile_fail" -eq 1 ]; then
            if [ "$STRICT_FAIL_DIAGNOSTICS" -eq 1 ] && [ -z "$expect_error_file" ]; then
                case_fail=1
                case_status="FAIL (missing expected compile error directive)"
            else
                local missing_pat=""
                if [ -n "$expect_error_file" ] && [ -f "$expect_error_file" ]; then
                    while IFS= read -r pat || [ -n "$pat" ]; do
                        if [ -z "$pat" ]; then
                            continue
                        fi
                        if ! grep -Fq "$pat" "$err_file"; then
                            missing_pat="$pat"
                            break
                        fi
                    done < "$expect_error_file"
                fi
                if [ -n "$missing_pat" ]; then
                    case_fail=1
                    case_status="FAIL (compile error mismatch: $missing_pat)"
                else
                    case_pass=1
                    case_status="PASS (expected compile fail)"
                fi
            fi
        else
            case_fail=1
            case_status="FAIL (compile)"
        fi
    else
        if [ "$expect_compile_fail" -eq 1 ]; then
            case_fail=1
            case_status="FAIL (unexpected compile success)"
        elif ! nasm -f elf64 -O1 "$asm_file" -o "$obj_file" 2>"$err_file"; then
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

expand_suite_file() {
    local suite_file="$1"
    local suite_base
    suite_base="$(basename "$suite_file" .bpp)"
    local suite_out_dir="$SUITE_CASES_DIR/$suite_base"
    local manifest="$suite_out_dir/cases.tsv"

    mkdir -p "$suite_out_dir"
    rm -f "$suite_out_dir"/*.bpp "$manifest" 2>/dev/null || true

    awk \
        -v suite_base="$suite_base" \
        -v out_dir="$suite_out_dir" \
        -v manifest="$manifest" \
        '
function sanitize(raw, out) {
    out = raw
    gsub(/[^A-Za-z0-9_.-]+/, "_", out)
    sub(/^_+/, "", out)
    sub(/_+$/, "", out)
    if (out == "") out = "case"
    return out
}
BEGIN {
    in_case = 0
    case_idx = 0
}
/^\/\/=== CASE[[:space:]]+/ {
    if (in_case) {
        print "Suite parse error: nested //=== CASE in " FILENAME > "/dev/stderr"
        exit 1
    }
    raw_name = $0
    sub(/^\/\/=== CASE[[:space:]]+/, "", raw_name)
    case_idx++
    safe_name = sanitize(raw_name)
    out_file = sprintf("%s/%s__%03d_%s.bpp", out_dir, suite_base, case_idx, safe_name)
    display_name = sprintf("%s::%s", suite_base, raw_name)
    print out_file "\t" display_name >> manifest
    in_case = 1
    next
}
/^\/\/=== END[[:space:]]*$/ {
    if (!in_case) {
        print "Suite parse error: orphan //=== END in " FILENAME > "/dev/stderr"
        exit 1
    }
    close(out_file)
    in_case = 0
    next
}
{
    if (in_case) {
        print $0 >> out_file
    }
}
END {
    if (in_case) {
        print "Suite parse error: missing //=== END in " FILENAME > "/dev/stderr"
        exit 1
    }
    if (case_idx == 0) {
        print "Suite parse error: no //=== CASE blocks in " FILENAME > "/dev/stderr"
        exit 1
    }
}
' "$suite_file" || return 1

    cat "$manifest"
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

# Find all top-level test files (exclude module files).
mapfile -t SOURCE_FILES < <(find "$TEST_DIR" -maxdepth 1 -type f -name '*.bpp' | sort -V)
TEST_FILES=()
for TEST_FILE in "${SOURCE_FILES[@]}"; do
    TEST_BASE_NAME=$(basename "$TEST_FILE")
    if [[ ! "$TEST_BASE_NAME" =~ ^[0-9]+_ ]]; then
        continue
    fi

    if grep -qE '^//=== CASE[[:space:]]+' "$TEST_FILE"; then
        if ! SUITE_CASES="$(expand_suite_file "$TEST_FILE")"; then
            echo "Error: Failed to expand suite file $TEST_FILE"
            exit 1
        fi
        SUITE_CASE_IDX=0
        while IFS=$'\t' read -r EXPANDED_FILE DISPLAY_NAME; do
            [ -z "$EXPANDED_FILE" ] && continue
            SUITE_CASE_IDX=$((SUITE_CASE_IDX + 1))
            if [ "$TEST_SUITE_CASE_LIMIT" -gt 0 ] && [ "$SUITE_CASE_IDX" -gt "$TEST_SUITE_CASE_LIMIT" ]; then
                continue
            fi
            TEST_FILES+=("$EXPANDED_FILE")
            TEST_DISPLAY_NAME["$EXPANDED_FILE"]="$DISPLAY_NAME"
        done <<< "$SUITE_CASES"
    else
        TEST_FILES+=("$TEST_FILE")
        TEST_DISPLAY_NAME["$TEST_FILE"]="$(basename "$TEST_FILE" .bpp)"
    fi
done

if [ "${#TEST_FILES[@]}" -eq 0 ]; then
    echo "No test files found in $TEST_DIR"
    exit 1
fi

for TEST_FILE in "${TEST_FILES[@]}"; do
    TEST_NAME=$(basename "$TEST_FILE" .bpp)
    TEST_LABEL="${TEST_DISPLAY_NAME[$TEST_FILE]:-$TEST_NAME}"
    CONTENT_HASH=$(awk '{if ($0 !~ /^\/\/ (Covers:|Mode:|Opt:|Expect exit code:|Expect compile fail:|Expect error contains:)/) print}' "$TEST_FILE" | md5sum | awk '{print $1}')
    if [ -n "${SEEN_HASH[$CONTENT_HASH]}" ]; then
        if [ "$TEST_QUIET" -eq 0 ]; then
            echo "[SKIP] Duplicate content: $TEST_LABEL (same as ${SEEN_HASH[$CONTENT_HASH]})"
        fi
        continue
    fi
    SEEN_HASH[$CONTENT_HASH]="$TEST_LABEL"

    EXPECTED=$(grep -m1 -E '^// Expect exit code:' "$TEST_FILE" | awk -F': ' '{print $2}' | tr -d ' ' || echo "0")
    if [ -z "$EXPECTED" ]; then
        EXPECTED=0
    fi

    EXPECT_COMPILE_FAIL_RAW=$(grep -m1 -E '^// Expect compile fail:' "$TEST_FILE" | awk -F': ' '{print $2}' | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' || true)
    EXPECT_COMPILE_FAIL=0
    if [ "$EXPECT_COMPILE_FAIL_RAW" = "1" ] || [ "$EXPECT_COMPILE_FAIL_RAW" = "true" ] || [ "$EXPECT_COMPILE_FAIL_RAW" = "yes" ]; then
        EXPECT_COMPILE_FAIL=1
    fi
    EXPECT_ERROR_FILE="$JOBS_DIR/${RUN_TAG}_${TEST_NAME}.expect"
    rm -f "$EXPECT_ERROR_FILE"
    grep -E '^// Expect error contains:' "$TEST_FILE" | sed -E 's|^// Expect error contains:[[:space:]]*||' > "$EXPECT_ERROR_FILE" || true
    if [ ! -s "$EXPECT_ERROR_FILE" ]; then
        rm -f "$EXPECT_ERROR_FILE"
        EXPECT_ERROR_FILE=""
    fi
    if [ "$EXPECT_COMPILE_FAIL" -eq 1 ] && [ "$STRICT_FAIL_DIAGNOSTICS" -eq 1 ] && [ -z "$EXPECT_ERROR_FILE" ]; then
        echo "Error: Missing '// Expect error contains:' directive for compile-fail test: $TEST_LABEL"
        exit 1
    fi

    TEST_MODE_DIRECTIVE=$(grep -m1 -E '^// Mode:' "$TEST_FILE" | sed -E 's|^// Mode:[[:space:]]*||' || true)
    TEST_OPT_DIRECTIVE=$(grep -m1 -E '^// Opt:' "$TEST_FILE" | sed -E 's|^// Opt:[[:space:]]*||' || true)
    TEST_MODES_CSV="$(normalize_modes_csv "$TEST_MODE_DIRECTIVE")"
    TEST_OPTS_CSV="$(normalize_opts_csv "$TEST_OPT_DIRECTIVE")"

    # Compile-fail tests do not need full codegen matrix unless explicitly requested.
    if [ "$EXPECT_COMPILE_FAIL" -eq 1 ] && [ "$COMPILE_FAIL_SINGLE_VARIANT" -eq 1 ] && [ -z "$TEST_MODE_DIRECTIVE" ] && [ -z "$TEST_OPT_DIRECTIVE" ]; then
        TEST_MODES_CSV="nossa"
        TEST_OPTS_CSV="O0"
    fi

    VARIANT_COUNT=0
    for MODE in nossa ssa; do
        if ! csv_has "$GLOBAL_MODES_CSV" "$MODE" || ! csv_has "$TEST_MODES_CSV" "$MODE"; then
            continue
        fi
        for OPT in O0 O1; do
            if ! csv_has "$GLOBAL_OPTS_CSV" "$OPT" || ! csv_has "$TEST_OPTS_CSV" "$OPT"; then
                continue
            fi
            VARIANT_COUNT=$((VARIANT_COUNT + 1))
            TOTAL=$((TOTAL + 1))
            RESULT_FILE="$JOBS_DIR/${RUN_TAG}_case_${TOTAL}.result"
            CASE_RESULT_FILES+=("$RESULT_FILE")
            launch_job_with_limit run_matrix_case "$TOTAL" "$TEST_FILE" "$TEST_NAME" "$TEST_LABEL" "$MODE" "$OPT" "$EXPECTED" "$EXPECT_COMPILE_FAIL" "$EXPECT_ERROR_FILE" "$RESULT_FILE"
        done
    done

    # If global quick filters eliminate all variants, honor per-test directives.
    if [ "$VARIANT_COUNT" -eq 0 ]; then
        for MODE in nossa ssa; do
            if ! csv_has "$TEST_MODES_CSV" "$MODE"; then
                continue
            fi
            for OPT in O0 O1; do
                if ! csv_has "$TEST_OPTS_CSV" "$OPT"; then
                    continue
                fi
                VARIANT_COUNT=$((VARIANT_COUNT + 1))
                TOTAL=$((TOTAL + 1))
                RESULT_FILE="$JOBS_DIR/${RUN_TAG}_case_${TOTAL}.result"
                CASE_RESULT_FILES+=("$RESULT_FILE")
                launch_job_with_limit run_matrix_case "$TOTAL" "$TEST_FILE" "$TEST_NAME" "$TEST_LABEL" "$MODE" "$OPT" "$EXPECTED" "$EXPECT_COMPILE_FAIL" "$EXPECT_ERROR_FILE" "$RESULT_FILE"
            done
        done
    fi

    if [ "$VARIANT_COUNT" -eq 0 ]; then
        echo "Error: No test variants selected for $TEST_LABEL"
        echo "       Global mode/opt: $GLOBAL_MODES_CSV / $GLOBAL_OPTS_CSV"
        echo "       Test mode/opt:   $TEST_MODES_CSV / $TEST_OPTS_CSV"
        exit 1
    fi
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
    if [ "$KEEP_TEST_ARTIFACTS" -eq 0 ]; then
        rm -rf "$SUITE_CASES_DIR"
    fi
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    if [ "$KEEP_TEST_ARTIFACTS" -eq 0 ]; then
        rm -rf "$SUITE_CASES_DIR"
    fi
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
