#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

FUZZ_ROOT="${FUZZ_ROOT:-$SCRIPT_DIR}"
FUZZ_CORPUS="${FUZZ_CORPUS:-$FUZZ_ROOT/corpus}"
FUZZ_WORK="${FUZZ_WORK:-$FUZZ_ROOT/work}"
FUZZ_FINDINGS="${FUZZ_FINDINGS:-$FUZZ_ROOT/findings}"
FUZZ_ITERS="${FUZZ_ITERS:-2000}"
FUZZ_TIMEOUT_SEC="${FUZZ_TIMEOUT_SEC:-4}"
FUZZ_HANG_CONFIRM_SEC="${FUZZ_HANG_CONFIRM_SEC:-$((FUZZ_TIMEOUT_SEC * 3))}"
FUZZ_MAX_BYTES="${FUZZ_MAX_BYTES:-8192}"
FUZZ_SEED="${FUZZ_SEED:-$(date +%s)}"

if [[ -z "${FUZZ_JOBS:-}" ]]; then
    if command -v nproc >/dev/null 2>&1; then
        FUZZ_JOBS="$(nproc)"
    else
        FUZZ_JOBS="4"
    fi
fi
if (( FUZZ_JOBS < 1 )); then FUZZ_JOBS=1; fi
if (( FUZZ_ITERS < 1 )); then
    echo "[ERROR] FUZZ_ITERS must be >= 1"
    exit 1
fi
if (( FUZZ_HANG_CONFIRM_SEC < FUZZ_TIMEOUT_SEC )); then
    FUZZ_HANG_CONFIRM_SEC=$FUZZ_TIMEOUT_SEC
fi

COMPILER="$(fuzz_pick_compiler "$REPO_ROOT" || true)"
if [[ -z "$COMPILER" || ! -x "$COMPILER" ]]; then
    echo "[ERROR] compiler not found. Set FUZZ_COMPILER or build stage1 first."
    exit 1
fi

mkdir -p "$FUZZ_CORPUS" "$FUZZ_WORK" "$FUZZ_FINDINGS/crash" "$FUZZ_FINDINGS/hang" "$FUZZ_FINDINGS/diff"

seed_count="$(find "$FUZZ_CORPUS" -maxdepth 1 -type f -name '*.bpp' | wc -l | tr -d ' ')"
if [[ "$seed_count" == "0" ]]; then
    fuzz_log "corpus empty, importing seeds from test/source"
    "$SCRIPT_DIR/generate_seed_corpus.sh"
fi

if ! command -v timeout >/dev/null 2>&1; then
    echo "[ERROR] 'timeout' command is required (coreutils)."
    exit 1
fi

fuzz_log "compiler=$COMPILER"
fuzz_log "iters=$FUZZ_ITERS jobs=$FUZZ_JOBS timeout=${FUZZ_TIMEOUT_SEC}s hang_confirm=${FUZZ_HANG_CONFIRM_SEC}s max_bytes=$FUZZ_MAX_BYTES seed=$FUZZ_SEED"

pick_seed_file() {
    local files=()
    while IFS= read -r f; do files+=("$f"); done < <(find "$FUZZ_CORPUS" -maxdepth 1 -type f -name '*.bpp' | sort)
    local n="${#files[@]}"
    if (( n == 0 )); then
        echo ""
        return 0
    fi
    local idx=$(( RANDOM % n ))
    echo "${files[$idx]}"
}

synth_program() {
    local out_file="$1"
    local a=$(( RANDOM % 200 - 100 ))
    local b=$(( RANDOM % 200 - 100 ))
    local c=$(( RANDOM % 100 + 1 ))
    local mode=$(( RANDOM % 6 ))

    cat > "$out_file" <<EOF
func helper(x: i64, y: i64) -> i64 {
    var z: i64 = x + y;
    if (z > ${c}) {
        z = z - 1;
    } else {
        z = z + 1;
    }
    return z;
}

func main() -> u64 {
    var x: i64 = ${a};
    var y: i64 = ${b};
    var r: i64 = helper(x, y);
    return (u64)r;
}
EOF

    if (( mode == 0 )); then
        cat >> "$out_file" <<EOF

func fuzz_extra(v: u64) -> u64 {
    var i: u64 = 0;
    var s: u64 = 0;
    while (i < v) {
        s += i;
        i += 1;
    }
    return s;
}
EOF
    elif (( mode == 1 )); then
        cat >> "$out_file" <<EOF

enum EF { A, B }
func fuzz_tag(e: EF) -> u64 {
    match (e) {
        case EF.A: { return 1; }
        case EF.B: { return 2; }
    }
}
EOF
    elif (( mode == 2 )); then
        cat >> "$out_file" <<EOF

struct P { x: u64, y: u64 }
func mk() -> P {
    var p: P = P{1, 2};
    return p;
}
EOF
    fi
}

mutate_program() {
    local src="$1"
    local out_file="$2"
    cp -f "$src" "$out_file"

    local edits=$(( RANDOM % 6 + 2 ))
    local i=0
    while (( i < edits )); do
        local mode=$(( RANDOM % 6 ))
        local lines
        lines=$(wc -l < "$out_file" | tr -d ' ')
        if (( lines < 1 )); then
            synth_program "$out_file"
            lines=$(wc -l < "$out_file" | tr -d ' ')
        fi
        local target=$(( RANDOM % lines + 1 ))

        case "$mode" in
            0)
                sed -E '0,/\+/s//-/' "$out_file" > "$out_file.tmp" || true
                ;;
            1)
                sed -E '0,/==/s//!=/' "$out_file" > "$out_file.tmp" || true
                ;;
            2)
                awk -v t="$target" 'NR!=t {print $0}' "$out_file" > "$out_file.tmp" || true
                ;;
            3)
                awk -v t="$target" 'NR==t{print $0} {print $0}' "$out_file" > "$out_file.tmp" || true
                ;;
            4)
                awk -v t="$target" 'NR==t{print "var fuzz_tmp: u64 = 0;"} {print $0}' "$out_file" > "$out_file.tmp" || true
                ;;
            *)
                awk -v t="$target" 'NR==t{print "if (1) { }"} {print $0}' "$out_file" > "$out_file.tmp" || true
                ;;
        esac

        if [[ -s "$out_file.tmp" ]]; then
            mv "$out_file.tmp" "$out_file"
        else
            rm -f "$out_file.tmp"
        fi
        i=$((i + 1))
    done

    local size
    size=$(wc -c < "$out_file" | tr -d ' ')
    if (( size > FUZZ_MAX_BYTES )); then
        head -c "$FUZZ_MAX_BYTES" "$out_file" > "$out_file.trim"
        mv "$out_file.trim" "$out_file"
        echo "" >> "$out_file"
    fi
}

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
            echo "[ERROR] unknown variant: $variant" >&2
            return 200
            ;;
    esac

    return 0
}

confirm_hang_variant() {
    local variant="$1"
    local input_file="$2"
    local err_file="$3"

    case "$variant" in
        nossa.O0)
            timeout "$FUZZ_HANG_CONFIRM_SEC" "$COMPILER" -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        nossa.O1)
            timeout "$FUZZ_HANG_CONFIRM_SEC" "$COMPILER" -O1 -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        ssa.O0)
            timeout "$FUZZ_HANG_CONFIRM_SEC" "$COMPILER" -dump-ssa -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        ssa.O1)
            timeout "$FUZZ_HANG_CONFIRM_SEC" "$COMPILER" -O1 -dump-ssa -asm "$input_file" >/dev/null 2>"$err_file" || return "$?"
            ;;
        *)
            return 200
            ;;
    esac

    return 0
}

store_finding() {
    local type="$1"
    local input_file="$2"
    local worker_id="$3"
    local iter_id="$4"
    local note="$5"
    local result_dir="$6"

    local id="${type}_$(date +%Y%m%d_%H%M%S)_w${worker_id}_i${iter_id}_$RANDOM"
    local out_dir="$FUZZ_FINDINGS/$type/$id"
    mkdir -p "$out_dir"

    cp -f "$input_file" "$out_dir/input.bpp"
    cp -f "$result_dir"/*.err "$out_dir/" 2>/dev/null || true

    cat > "$out_dir/meta.txt" <<EOF
type=$type
compiler=$COMPILER
worker=$worker_id
iter=$iter_id
seed=$FUZZ_SEED
note=$note
EOF
}

worker_loop() {
    local worker_id="$1"
    local start_iter="$2"
    local end_iter="$3"

    if (( end_iter < start_iter )); then
        return 0
    fi

    RANDOM=$(( FUZZ_SEED + worker_id * 7919 ))

    local worker_dir="$FUZZ_WORK/worker_$worker_id"
    mkdir -p "$worker_dir"

    local iter
    for (( iter = start_iter; iter <= end_iter; iter++ )); do
        local case_file="$worker_dir/case_${iter}.bpp"
        local result_dir="$worker_dir/result_${iter}"
        mkdir -p "$result_dir"

        local seed_file
        seed_file="$(pick_seed_file)"
        if [[ -n "$seed_file" && $(( RANDOM % 100 )) -lt 80 ]]; then
            mutate_program "$seed_file" "$case_file"
        else
            synth_program "$case_file"
        fi

        local variants=("nossa.O0" "nossa.O1" "ssa.O0" "ssa.O1")
        local had_abnormal=0
        local success_bitmap=""
        local status_line=""

        local v
        for v in "${variants[@]}"; do
            local err_file="$result_dir/${v}.err"
            local rc=0
            if run_variant "$v" "$case_file" "$err_file"; then
                rc=0
            else
                rc=$?
            fi

            local ok=0
            local abnormal="none"
            if (( rc == 0 )); then
                ok=1
            elif (( rc == 124 )); then
                local confirm_err_file="$result_dir/${v}.confirm.err"
                local confirm_rc=0
                if confirm_hang_variant "$v" "$case_file" "$confirm_err_file"; then
                    confirm_rc=0
                else
                    confirm_rc=$?
                fi
                if (( confirm_rc == 124 )); then
                    abnormal="hang"
                    had_abnormal=1
                elif (( confirm_rc >= 128 )); then
                    abnormal="crash"
                    had_abnormal=1
                else
                    abnormal="slow"
                fi
            elif (( rc >= 128 )); then
                abnormal="crash"
                had_abnormal=1
            fi

            success_bitmap+="$ok"
            status_line+="$v:$rc:$abnormal "

            if [[ "$abnormal" == "hang" ]]; then
                store_finding "hang" "$case_file" "$worker_id" "$iter" "$status_line" "$result_dir"
            elif [[ "$abnormal" == "crash" ]]; then
                store_finding "crash" "$case_file" "$worker_id" "$iter" "$status_line" "$result_dir"
            fi
        done

        if (( had_abnormal == 0 )); then
            if [[ "$success_bitmap" != "1111" && "$success_bitmap" != "0000" ]]; then
                store_finding "diff" "$case_file" "$worker_id" "$iter" "$status_line" "$result_dir"
            else
                local nossa_o0_err nossa_o1_err ssa_o0_err ssa_o1_err
                nossa_o0_err="$(fuzz_norm_err "$result_dir/nossa.O0.err")"
                nossa_o1_err="$(fuzz_norm_err "$result_dir/nossa.O1.err")"
                ssa_o0_err="$(fuzz_norm_err "$result_dir/ssa.O0.err")"
                ssa_o1_err="$(fuzz_norm_err "$result_dir/ssa.O1.err")"

                local nossa_o0_hash nossa_o1_hash ssa_o0_hash ssa_o1_hash
                nossa_o0_hash="$(fuzz_hash_str "$nossa_o0_err")"
                nossa_o1_hash="$(fuzz_hash_str "$nossa_o1_err")"
                ssa_o0_hash="$(fuzz_hash_str "$ssa_o0_err")"
                ssa_o1_hash="$(fuzz_hash_str "$ssa_o1_err")"

                if [[ "$nossa_o0_hash" != "$nossa_o1_hash" || "$ssa_o0_hash" != "$ssa_o1_hash" ]]; then
                    store_finding "diff" "$case_file" "$worker_id" "$iter" "$status_line" "$result_dir"
                fi
            fi
        fi

        rm -rf "$result_dir"
        rm -f "$case_file"
    done
}

pids=()
for (( w = 1; w <= FUZZ_JOBS; w++ )); do
    read -r start_i end_i < <(fuzz_split_iters "$FUZZ_ITERS" "$FUZZ_JOBS" "$w")
    worker_loop "$w" "$start_i" "$end_i" &
    pids+=("$!")
done

for pid in "${pids[@]}"; do
    wait "$pid"
done

crash_count="$(find "$FUZZ_FINDINGS/crash" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
hang_count="$(find "$FUZZ_FINDINGS/hang" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
diff_count="$(find "$FUZZ_FINDINGS/diff" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"

fuzz_log "fuzz campaign finished"
fuzz_log "findings crash=$crash_count hang=$hang_count diff=$diff_count"

exit 0
