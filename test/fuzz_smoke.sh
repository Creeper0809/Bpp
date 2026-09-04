#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPILER="${COMPILER:-$ROOT_DIR/bin/stage1}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/build/fuzz-smoke}"
SRC_DIR="${SRC_DIR:-$ROOT_DIR/build/fuzz-smoke-src}"
COUNT="${COUNT:-100}"

case "$OUT_DIR" in
    /*) ;;
    *) OUT_DIR="$ROOT_DIR/$OUT_DIR" ;;
esac
mkdir -p "$OUT_DIR"
mkdir -p "$SRC_DIR"

if [ ! -x "$COMPILER" ]; then
    echo "compiler is not executable: $COMPILER" >&2
    exit 1
fi

REPORT="$OUT_DIR/fuzz_smoke_report.tsv"
printf 'case\to0_exit\to1_exit\to2_exit\tmatch\n' > "$REPORT"

i=0
while [ "$i" -lt "$COUNT" ]; do
    SRC="$SRC_DIR/fuzz_$i.bpp"
    A=$((i + 3))
    B=$((i * 7 + 11))
    EXPECTED=$(((A + B) ^ (i & 15)))
    cat > "$SRC" <<EOF_CASE
func fuzz_mix_${i}(a: u64, b: u64) -> u64 {
    var x: u64 = a + b;
    var y: u64 = x ^ $((i & 15));
    return y;
}

func main() -> u64 {
    if (fuzz_mix_${i}($A, $B) != $EXPECTED) { return 1; }
    return 0;
}
EOF_CASE

    set +e
    (cd "$OUT_DIR" && "$COMPILER" -O0 "$SRC") > "$OUT_DIR/fuzz_${i}.o0.out" 2> "$OUT_DIR/fuzz_${i}.o0.err"
    O0_EXIT=$?
    (cd "$OUT_DIR" && "$COMPILER" -O1 "$SRC") > "$OUT_DIR/fuzz_${i}.o1.out" 2> "$OUT_DIR/fuzz_${i}.o1.err"
    O1_EXIT=$?
    (cd "$OUT_DIR" && "$COMPILER" -O2 "$SRC") > "$OUT_DIR/fuzz_${i}.o2.out" 2> "$OUT_DIR/fuzz_${i}.o2.err"
    O2_EXIT=$?
    set -e
    MATCH=0
    if [ "$O0_EXIT" -eq "$O1_EXIT" ] && [ "$O1_EXIT" -eq "$O2_EXIT" ]; then
        MATCH=1
    fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$i" "$O0_EXIT" "$O1_EXIT" "$O2_EXIT" "$MATCH" >> "$REPORT"
    if [ "$MATCH" -ne 1 ]; then
        echo "fuzz smoke mismatch at case $i" >&2
        exit 1
    fi
    i=$((i + 1))
done

echo "[OK] fuzz smoke report: $REPORT"
