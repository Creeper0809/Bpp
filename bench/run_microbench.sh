#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/build/microbench}"
BENCH_SOURCES="${BENCH_SOURCES:-bench/tagged_pointer_fastpaths.bpp}"
OPT_LEVEL="${OPT_LEVEL:-O1}"
BACKEND="${BACKEND:-llvm}"
RUNS="${RUNS:-3}"
THRESHOLD_FILE="${THRESHOLD_FILE:-$ROOT_DIR/bench/optimization_thresholds.tsv}"
COMPILER="${COMPILER:-}"
BASELINE_COMPILER="${BASELINE_COMPILER:-}"

if [ -z "$COMPILER" ]; then
    if [ -x "$ROOT_DIR/bin/stage1" ]; then
        COMPILER="$ROOT_DIR/bin/stage1"
    elif [ -x "$ROOT_DIR/bin/v13_stage1" ]; then
        COMPILER="$ROOT_DIR/bin/v13_stage1"
    else
        echo "COMPILER is not set and no default stage compiler exists." >&2
        exit 1
    fi
fi

if [ ! -x "$COMPILER" ]; then
    echo "compiler is not executable: $COMPILER" >&2
    exit 1
fi

case "$OPT_LEVEL" in
    O0|O1) ;;
    *) echo "OPT_LEVEL must be O0 or O1: $OPT_LEVEL" >&2; exit 1 ;;
esac

case "$BACKEND" in
    llvm) ;;
    *) echo "BACKEND currently supports only llvm: $BACKEND" >&2; exit 1 ;;
esac

case "$OUT_DIR" in
    /*) ;;
    *) OUT_DIR="$ROOT_DIR/$OUT_DIR" ;;
esac
mkdir -p "$OUT_DIR"

REPORT="$OUT_DIR/bench_report.tsv"
OPT_REPORT="$OUT_DIR/optimization_report.tsv"
COMPARE_REPORT="$OUT_DIR/comparison_report.tsv"
THRESHOLD_COPY="$OUT_DIR/optimization_thresholds.tsv"

threshold_hash="none"
if [ -f "$THRESHOLD_FILE" ]; then
    cp "$THRESHOLD_FILE" "$THRESHOLD_COPY"
    threshold_hash="$(sha256sum "$THRESHOLD_FILE" | awk '{print $1}')"
fi

printf 'timestamp\tlabel\tsource\tbackend\topt\truns\tcompile_seconds\tbuild_seconds\trun_best_seconds\trun_avg_seconds\tmax_rss_kb\tthreshold_hash\n' > "$REPORT"
printf 'timestamp\tlabel\tsource\topt\to1_inline\to1_number_ir\to1_pgo\to1_loop2\to1_tag2\to1_sroa2\to1_regalloc2\to1_peephole\tthreshold_hash\n' > "$OPT_REPORT"
printf 'source\tbackend\topt\tmetric\tbaseline\tcandidate\tdelta_percent\n' > "$COMPARE_REPORT"

abs_source() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '%s/%s\n' "$ROOT_DIR" "$1" ;;
    esac
}

sum_metadata() {
    local key="$1"
    local file="$2"
    grep -o "${key}=[0-9][0-9]*" "$file" 2>/dev/null | awk -F= '{sum += $2} END {print sum + 0}'
}

read_time_field() {
    local file="$1"
    local field="$2"
    awk -v field="$field" '{print $field}' "$file"
}

run_one() {
    local compiler="$1"
    local label="$2"
    local source_rel="$3"
    local source_abs
    source_abs="$(abs_source "$source_rel")"
    if [ ! -f "$source_abs" ]; then
        echo "benchmark source not found: $source_abs" >&2
        exit 1
    fi

    local base
    base="$(basename "$source_abs" .bpp)"
    local case_dir="$OUT_DIR/$label/$base"
    mkdir -p "$case_dir"

    local ll_file="$case_dir/$base.ll"
    local compile_time="$case_dir/compile.time"
    local build_time="$case_dir/build.time"
    local build_out="$case_dir/build.out"
    local build_err="$case_dir/build.err"
    local run_times="$case_dir/run.times"

    /usr/bin/time -f '%e	%U	%S	%M' -o "$compile_time" \
        "$compiler" "-$OPT_LEVEL" -dump-llvm-ll "$source_abs" > "$ll_file"

    local compile_seconds
    local compile_rss
    compile_seconds="$(read_time_field "$compile_time" 1)"
    compile_rss="$(read_time_field "$compile_time" 4)"

    local o1_inline
    local o1_number_ir
    local o1_pgo
    local o1_loop2
    local o1_tag2
    local o1_sroa2
    local o1_regalloc2
    local o1_peephole
    o1_inline="$(sum_metadata o1_inline "$ll_file")"
    o1_number_ir="$(sum_metadata o1_number_ir "$ll_file")"
    o1_pgo="$(sum_metadata o1_pgo "$ll_file")"
    o1_loop2="$(sum_metadata o1_loop2 "$ll_file")"
    o1_tag2="$(sum_metadata o1_tag2 "$ll_file")"
    o1_sroa2="$(sum_metadata o1_sroa2 "$ll_file")"
    o1_regalloc2="$(sum_metadata o1_regalloc2 "$ll_file")"
    o1_peephole="$(sum_metadata o1_peephole "$ll_file")"

    local timestamp
    timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$timestamp" "$label" "$source_rel" "$OPT_LEVEL" "$o1_inline" "$o1_number_ir" "$o1_pgo" \
        "$o1_loop2" "$o1_tag2" "$o1_sroa2" "$o1_regalloc2" "$o1_peephole" "$threshold_hash" >> "$OPT_REPORT"

    (cd "$case_dir" && /usr/bin/time -f '%e	%U	%S	%M' -o "$build_time" \
        "$compiler" "-$OPT_LEVEL" -llvm-build "$source_abs" > "$build_out" 2> "$build_err")

    local build_seconds
    local build_rss
    build_seconds="$(read_time_field "$build_time" 1)"
    build_rss="$(read_time_field "$build_time" 4)"
    local max_rss
    max_rss="$compile_rss"
    if [ "$build_rss" -gt "$max_rss" ]; then
        max_rss="$build_rss"
    fi

    local exe_path
    exe_path="$(sed -n 's/^\[OK\] llvm exe: //p' "$build_out" | tail -n 1)"
    if [ -z "$exe_path" ]; then
        echo "llvm build did not report an executable for $source_rel" >&2
        cat "$build_err" >&2
        exit 1
    fi
    case "$exe_path" in
        /*) ;;
        *) exe_path="$case_dir/$exe_path" ;;
    esac
    if [ ! -x "$exe_path" ]; then
        echo "benchmark executable not found: $exe_path" >&2
        exit 1
    fi

    : > "$run_times"
    local i
    i=1
    while [ "$i" -le "$RUNS" ]; do
        local run_time="$case_dir/run_$i.time"
        /usr/bin/time -f '%e	%U	%S	%M' -o "$run_time" "$exe_path" > "$case_dir/run_$i.out"
        read_time_field "$run_time" 1 >> "$run_times"
        local run_rss
        run_rss="$(read_time_field "$run_time" 4)"
        if [ "$run_rss" -gt "$max_rss" ]; then
            max_rss="$run_rss"
        fi
        i=$((i + 1))
    done

    local run_best
    local run_avg
    run_best="$(awk 'NR == 1 || $1 < best {best = $1} END {printf "%.6f", best + 0}' "$run_times")"
    run_avg="$(awk '{sum += $1; n += 1} END {if (n == 0) {printf "0.000000"} else {printf "%.6f", sum / n}}' "$run_times")"

    timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$timestamp" "$label" "$source_rel" "$BACKEND" "$OPT_LEVEL" "$RUNS" \
        "$compile_seconds" "$build_seconds" "$run_best" "$run_avg" "$max_rss" "$threshold_hash" >> "$REPORT"
}

for source in $BENCH_SOURCES; do
    if [ -n "$BASELINE_COMPILER" ]; then
        if [ ! -x "$BASELINE_COMPILER" ]; then
            echo "baseline compiler is not executable: $BASELINE_COMPILER" >&2
            exit 1
        fi
        run_one "$BASELINE_COMPILER" baseline "$source"
    fi
    run_one "$COMPILER" candidate "$source"
done

if [ -n "$BASELINE_COMPILER" ]; then
    awk -F '\t' '
        BEGIN {
            OFS = "\t";
            print "source", "backend", "opt", "metric", "baseline", "candidate", "delta_percent";
        }
        NR == 1 { next }
        $2 == "baseline" {
            key = $3 "\t" $4 "\t" $5;
            b_compile[key] = $7;
            b_build[key] = $8;
            b_best[key] = $9;
            b_avg[key] = $10;
            next;
        }
        $2 == "candidate" {
            key = $3 "\t" $4 "\t" $5;
            if (key in b_compile) {
                emit($3, $4, $5, "compile_seconds", b_compile[key], $7);
                emit($3, $4, $5, "build_seconds", b_build[key], $8);
                emit($3, $4, $5, "run_best_seconds", b_best[key], $9);
                emit($3, $4, $5, "run_avg_seconds", b_avg[key], $10);
            }
        }
        function emit(source, backend, opt, metric, baseline, candidate, delta) {
            if (baseline + 0 == 0) { delta = 0; }
            else { delta = ((candidate - baseline) * 100.0) / baseline; }
            printf "%s\t%s\t%s\t%s\t%.6f\t%.6f\t%.3f\n", source, backend, opt, metric, baseline, candidate, delta;
        }
    ' "$REPORT" > "$COMPARE_REPORT"
fi

echo "[OK] benchmark report: $REPORT"
echo "[OK] optimization report: $OPT_REPORT"
if [ -n "$BASELINE_COMPILER" ]; then
    echo "[OK] comparison report: $COMPARE_REPORT"
fi
