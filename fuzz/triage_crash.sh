#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

FUZZ_ROOT="${FUZZ_ROOT:-$SCRIPT_DIR}"
FUZZ_TIMEOUT_SEC="${FUZZ_TIMEOUT_SEC:-4}"
TRIAGE_COMPILER="${TRIAGE_COMPILER:-}"
TRIAGE_FINDINGS_DIR="${TRIAGE_FINDINGS_DIR:-$FUZZ_ROOT/findings/crash}"
TRIAGE_OUT_ROOT="${TRIAGE_OUT_ROOT:-$FUZZ_ROOT/findings/triage}"
TRIAGE_LIMIT="${TRIAGE_LIMIT:-0}"
TRIAGE_CASE="${TRIAGE_CASE:-}"

if [[ -n "$TRIAGE_COMPILER" && -x "$TRIAGE_COMPILER" ]]; then
    COMPILER="$TRIAGE_COMPILER"
else
    COMPILER="$(fuzz_pick_compiler "$REPO_ROOT" || true)"
fi

if [[ -z "$COMPILER" || ! -x "$COMPILER" ]]; then
    echo "[ERROR] compiler not found. Set TRIAGE_COMPILER or build stage1 first."
    exit 1
fi

if [[ ! -d "$TRIAGE_FINDINGS_DIR" ]]; then
    echo "[ERROR] findings directory not found: $TRIAGE_FINDINGS_DIR"
    exit 1
fi

mkdir -p "$TRIAGE_OUT_ROOT"
RUN_ID="triage_$(date +%Y%m%d_%H%M%S)"
OUT_DIR="$TRIAGE_OUT_ROOT/$RUN_ID"
mkdir -p "$OUT_DIR/cases"

RESULT_TSV="$OUT_DIR/results.tsv"
SUMMARY_TXT="$OUT_DIR/summary.txt"

echo -e "case\thypothesis\tnossa.O0\tnossa.O1\tssa.O0\tssa.O1" > "$RESULT_TSV"

run_variant() {
    local variant="$1"
    local input_file="$2"
    local err_file="$3"

    case "$variant" in
        nossa.O0)
            timeout "$FUZZ_TIMEOUT_SEC" "$COMPILER" -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        nossa.O1)
            timeout "$FUZZ_TIMEOUT_SEC" "$COMPILER" -O1 -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        ssa.O0)
            timeout "$FUZZ_TIMEOUT_SEC" "$COMPILER" -dump-ssa -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        ssa.O1)
            timeout "$FUZZ_TIMEOUT_SEC" "$COMPILER" -O1 -dump-ssa -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        *)
            return 200
            ;;
    esac

    return 0
}

status_label() {
    local rc="$1"
    if (( rc == 0 )); then
        echo "ok"
        return 0
    fi
    if (( rc == 124 )); then
        echo "hang"
        return 0
    fi
    if (( rc >= 128 )); then
        echo "crash"
        return 0
    fi
    echo "fail"
}

hypothesis_from_labels() {
    local n0="$1"
    local n1="$2"
    local s0="$3"
    local s1="$4"

    if [[ "$n0" == "hang" || "$n1" == "hang" || "$s0" == "hang" || "$s1" == "hang" ]]; then
        echo "timeout_or_infinite_loop"
        return 0
    fi

    local all_nossa_abnormal=0
    local all_ssa_abnormal=0
    local all_o1_abnormal=0

    if [[ ("$n0" == "crash" || "$n0" == "fail") && ("$n1" == "crash" || "$n1" == "fail") ]]; then
        all_nossa_abnormal=1
    fi
    if [[ ("$s0" == "crash" || "$s0" == "fail") && ("$s1" == "crash" || "$s1" == "fail") ]]; then
        all_ssa_abnormal=1
    fi
    if [[ ("$n1" == "crash" || "$n1" == "fail") && ("$s1" == "crash" || "$s1" == "fail") && "$n0" == "ok" && "$s0" == "ok" ]]; then
        all_o1_abnormal=1
    fi

    if (( all_o1_abnormal == 1 )); then
        echo "o1_optimizer_or_o1_codegen"
        return 0
    fi
    if (( all_ssa_abnormal == 1 )) && [[ "$n0" == "ok" || "$n1" == "ok" ]]; then
        echo "ssa_pipeline_only"
        return 0
    fi
    if (( all_nossa_abnormal == 1 )) && [[ "$s0" == "ok" || "$s1" == "ok" ]]; then
        echo "nossa_codegen_only"
        return 0
    fi
    if (( all_nossa_abnormal == 1 && all_ssa_abnormal == 1 )); then
        echo "front_or_shared_pipeline"
        return 0
    fi
    if [[ "$n0" == "ok" && "$n1" == "ok" && "$s0" == "ok" && "$s1" == "ok" ]]; then
        echo "not_reproduced"
        return 0
    fi
    echo "mixed_variant_instability"
}

cases=()
while IFS= read -r d; do
    cases+=("$d")
done < <(find "$TRIAGE_FINDINGS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ -n "$TRIAGE_CASE" ]]; then
    filtered=()
    for d in "${cases[@]}"; do
        base="$(basename "$d")"
        if [[ "$base" == "$TRIAGE_CASE" ]]; then
            filtered+=("$d")
        fi
    done
    cases=("${filtered[@]}")
fi

if (( TRIAGE_LIMIT > 0 )) && (( ${#cases[@]} > TRIAGE_LIMIT )); then
    cases=("${cases[@]:0:TRIAGE_LIMIT}")
fi

if (( ${#cases[@]} == 0 )); then
    echo "[ERROR] no crash cases to triage"
    exit 1
fi

fuzz_log "triage start compiler=$COMPILER cases=${#cases[@]} timeout=${FUZZ_TIMEOUT_SEC}s"

count_total=0
count_front_or_shared_pipeline=0
count_ssa_pipeline_only=0
count_nossa_codegen_only=0
count_o1_optimizer_or_o1_codegen=0
count_timeout_or_infinite_loop=0
count_mixed_variant_instability=0
count_not_reproduced=0

for case_dir in "${cases[@]}"; do
    case_name="$(basename "$case_dir")"
    input_file="$case_dir/input.bpp"
    if [[ ! -f "$input_file" ]]; then
        continue
    fi

    out_case_dir="$OUT_DIR/cases/$case_name"
    mkdir -p "$out_case_dir"
    cp -f "$input_file" "$out_case_dir/input.bpp"

    variants=("nossa.O0" "nossa.O1" "ssa.O0" "ssa.O1")
    labels=()
    for v in "${variants[@]}"; do
        err_file="$out_case_dir/${v}.err"
        rc=0
        if run_variant "$v" "$input_file" "$err_file"; then
            rc=0
        else
            rc=$?
        fi
        labels+=("$(status_label "$rc")")
    done

    hypothesis="$(hypothesis_from_labels "${labels[0]}" "${labels[1]}" "${labels[2]}" "${labels[3]}")"
    echo -e "$case_name\t$hypothesis\t${labels[0]}\t${labels[1]}\t${labels[2]}\t${labels[3]}" >> "$RESULT_TSV"

    case "$hypothesis" in
        front_or_shared_pipeline) count_front_or_shared_pipeline=$((count_front_or_shared_pipeline + 1)) ;;
        ssa_pipeline_only) count_ssa_pipeline_only=$((count_ssa_pipeline_only + 1)) ;;
        nossa_codegen_only) count_nossa_codegen_only=$((count_nossa_codegen_only + 1)) ;;
        o1_optimizer_or_o1_codegen) count_o1_optimizer_or_o1_codegen=$((count_o1_optimizer_or_o1_codegen + 1)) ;;
        timeout_or_infinite_loop) count_timeout_or_infinite_loop=$((count_timeout_or_infinite_loop + 1)) ;;
        mixed_variant_instability) count_mixed_variant_instability=$((count_mixed_variant_instability + 1)) ;;
        not_reproduced) count_not_reproduced=$((count_not_reproduced + 1)) ;;
    esac

    count_total=$((count_total + 1))
done

{
    echo "triage_run=$RUN_ID"
    echo "compiler=$COMPILER"
    echo "cases=$count_total"
    echo "front_or_shared_pipeline=$count_front_or_shared_pipeline"
    echo "ssa_pipeline_only=$count_ssa_pipeline_only"
    echo "nossa_codegen_only=$count_nossa_codegen_only"
    echo "o1_optimizer_or_o1_codegen=$count_o1_optimizer_or_o1_codegen"
    echo "timeout_or_infinite_loop=$count_timeout_or_infinite_loop"
    echo "mixed_variant_instability=$count_mixed_variant_instability"
    echo "not_reproduced=$count_not_reproduced"
} > "$SUMMARY_TXT"

fuzz_log "triage finished out=$OUT_DIR"
fuzz_log "summary front/shared=$count_front_or_shared_pipeline ssa_only=$count_ssa_pipeline_only nossa_only=$count_nossa_codegen_only o1_only=$count_o1_optimizer_or_o1_codegen mixed=$count_mixed_variant_instability not_reproduced=$count_not_reproduced"

exit 0