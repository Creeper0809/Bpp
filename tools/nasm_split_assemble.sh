#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input.asm> <output.o> [nasm flags...]" >&2
    exit 2
fi

ASM_FILE="$1"
OUT_OBJ="$2"
shift 2
if [ "$#" -eq 0 ]; then
    set -- -felf64 -O1
fi

NASM_BIN="${BPP_NASM_EXECUTABLE:-nasm}"
LINKER_BIN="${BPP_LINKER_EXECUTABLE:-ld}"
SPLIT_LINES="${BPP_NASM_SPLIT_LINES:-60000}"
WORK_DIR="${BPP_NASM_SPLIT_WORK_DIR:-}"
KEEP_SPLIT="${BPP_NASM_SPLIT_KEEP:-0}"

if [ ! -f "$ASM_FILE" ]; then
    echo "Error: asm file not found: $ASM_FILE" >&2
    exit 1
fi

if [ -z "$WORK_DIR" ]; then
    WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bpp_nasm_split.XXXXXX")"
else
    mkdir -p "$WORK_DIR"
    rm -f "$WORK_DIR"/*.asm "$WORK_DIR"/*.o "$WORK_DIR"/*.defs "$WORK_DIR"/labels.txt "$WORK_DIR"/manifest.txt 2>/dev/null || true
fi

cleanup() {
    if [ "$KEEP_SPLIT" != "1" ]; then
        rm -rf "$WORK_DIR"
    fi
}
trap cleanup EXIT

LABELS_FILE="$WORK_DIR/labels.txt"
awk '/^[A-Za-z_][A-Za-z0-9_]*:/ { name=$0; sub(/:.*/, "", name); print name }' "$ASM_FILE" > "$LABELS_FILE"

awk -v out_dir="$WORK_DIR" -v max_lines="$SPLIT_LINES" '
function open_chunk() {
    chunk++
    body = sprintf("%s/body_%05d.asm", out_dir, chunk)
    defs = sprintf("%s/chunk_%05d.defs", out_dir, chunk)
    print body >> sprintf("%s/manifest.txt", out_dir)
    close(sprintf("%s/manifest.txt", out_dir))
    line_count = 0
}
function close_chunk() {
    if (body != "") {
        close(body)
        close(defs)
    }
}
BEGIN {
    chunk = 0
    body = ""
    defs = ""
    line_count = 0
    open_chunk()
}
{
    is_text_boundary = ($0 ~ /^section[[:space:]]+\.text[[:space:]]*$/)
    if (is_text_boundary && line_count >= max_lines) {
        close_chunk()
        open_chunk()
    }

    print $0 >> body
    line_count++

    if ($0 ~ /^[A-Za-z_][A-Za-z0-9_]*:/) {
        name = $0
        sub(/:.*/, "", name)
        print name >> defs
    }
}
END {
    close_chunk()
}
' "$ASM_FILE"

mapfile -t CHUNK_BODIES < "$WORK_DIR/manifest.txt"
if [ "${#CHUNK_BODIES[@]}" -eq 0 ]; then
    echo "Error: no asm chunks generated" >&2
    exit 1
fi

OBJECTS=()
idx=0
for body in "${CHUNK_BODIES[@]}"; do
    idx=$((idx + 1))
    chunk_id="$(printf "%05d" "$idx")"
    defs_file="$WORK_DIR/chunk_${chunk_id}.defs"
    chunk_file="$WORK_DIR/chunk_${chunk_id}.asm"
    obj_file="$WORK_DIR/chunk_${chunk_id}.o"

    {
        if [ -f "$defs_file" ]; then
            sed 's/^/global /' "$defs_file"
        fi
        awk 'NR == FNR { defs[$0] = 1; next } $0 != "" && !($0 in defs) { print "extern " $0 }' "$defs_file" "$LABELS_FILE"
        cat "$body"
    } > "$chunk_file"

    "$NASM_BIN" "$@" "$chunk_file" -o "$obj_file"
    OBJECTS+=("$obj_file")
done

"$LINKER_BIN" -r "${OBJECTS[@]}" -o "$OUT_OBJ"
