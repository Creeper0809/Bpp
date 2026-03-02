#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CORPUS_DIR="$SCRIPT_DIR/corpus"
SOURCE_DIR="$ROOT_DIR/test/source"

mkdir -p "$CORPUS_DIR"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "[ERROR] test/source not found: $SOURCE_DIR"
    exit 1
fi

copied=0
for f in "$SOURCE_DIR"/*.bpp; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    cp -f "$f" "$CORPUS_DIR/$base"
    copied=$((copied + 1))
done

echo "[INFO] seed corpus ready: $CORPUS_DIR"
echo "[INFO] copied files: $copied"
