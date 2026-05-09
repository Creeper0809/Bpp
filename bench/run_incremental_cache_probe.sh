#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPILER="${COMPILER:-$ROOT_DIR/bin/stage1}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/build/incremental-cache-probe}"
SOURCE="${SOURCE:-test/source/01_generics.bpp}"
OPT_LEVEL="${OPT_LEVEL:-O1}"

case "$OUT_DIR" in
    /*) ;;
    *) OUT_DIR="$ROOT_DIR/$OUT_DIR" ;;
esac
mkdir -p "$OUT_DIR"

case "$SOURCE" in
    /*) SOURCE_ABS="$SOURCE" ;;
    *) SOURCE_ABS="$ROOT_DIR/$SOURCE" ;;
esac

if [ ! -x "$COMPILER" ]; then
    echo "compiler is not executable: $COMPILER" >&2
    exit 1
fi
if [ ! -f "$SOURCE_ABS" ]; then
    echo "source not found: $SOURCE_ABS" >&2
    exit 1
fi

REPORT="$OUT_DIR/incremental_cache_report.tsv"
SOURCE_HASH="$(sha256sum "$SOURCE_ABS" | awk '{print $1}')"
OPTION_HASH="$(printf '%s\n' "$OPT_LEVEL" | sha256sum | awk '{print $1}')"
CACHE_KEY="$(printf '%s\t%s\n' "$SOURCE_HASH" "$OPTION_HASH" | sha256sum | awk '{print $1}')"

printf 'source\topt\tsource_hash\toption_hash\tcache_key\tfirst_seconds\tsecond_seconds\tdeterministic\n' > "$REPORT"

/usr/bin/time -f '%e' -o "$OUT_DIR/first.time" "$COMPILER" "-$OPT_LEVEL" -dump-ssa "$SOURCE_ABS" > "$OUT_DIR/first.ssa"
/usr/bin/time -f '%e' -o "$OUT_DIR/second.time" "$COMPILER" "-$OPT_LEVEL" -dump-ssa "$SOURCE_ABS" > "$OUT_DIR/second.ssa"
sed -E 's/(lea_global|lea_str|asm|fconst) #[0-9]+/\1 #ADDR/g' "$OUT_DIR/first.ssa" > "$OUT_DIR/first.normalized.ssa"
sed -E 's/(lea_global|lea_str|asm|fconst) #[0-9]+/\1 #ADDR/g' "$OUT_DIR/second.ssa" > "$OUT_DIR/second.normalized.ssa"

FIRST_SECONDS="$(awk '{print $1}' "$OUT_DIR/first.time")"
SECOND_SECONDS="$(awk '{print $1}' "$OUT_DIR/second.time")"
DETERMINISTIC=0
if cmp -s "$OUT_DIR/first.normalized.ssa" "$OUT_DIR/second.normalized.ssa"; then
    DETERMINISTIC=1
fi

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$SOURCE" "$OPT_LEVEL" "$SOURCE_HASH" "$OPTION_HASH" "$CACHE_KEY" \
    "$FIRST_SECONDS" "$SECOND_SECONDS" "$DETERMINISTIC" >> "$REPORT"

echo "[OK] incremental cache probe: $REPORT"
