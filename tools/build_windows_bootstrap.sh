#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${BPP_VERSION:-$(sed -n 's/^VERSION=//p' "$ROOT_DIR/config.ini" | head -n1 | tr -d '[:space:]')}"
COMPILER="${BPP_BASE_COMPILER:-$ROOT_DIR/bin/stage1}"
OUT_FILE="${1:-$ROOT_DIR/bpp-bootstrap-${VERSION}-windows-x86_64.exe}"
BUILD_DIR="${BPP_WINDOWS_BOOTSTRAP_BUILD_DIR:-$ROOT_DIR/build/windows-cross-bootstrap}"
MEMORY_LIMIT_KIB="${BPP_MEMORY_LIMIT_KIB:-4194304}"

if [ -z "$VERSION" ]; then
    echo "VERSION is missing from config.ini" >&2
    exit 1
fi
if [ ! -x "$COMPILER" ]; then
    echo "Linux bootstrap compiler is missing or not executable: $COMPILER" >&2
    exit 1
fi

for tool in nasm x86_64-w64-mingw32-ld; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Required cross-bootstrap tool is missing: $tool" >&2
        echo "On Debian/Ubuntu install: nasm binutils-mingw-w64-x86-64 mingw-w64-x86-64-dev" >&2
        exit 1
    fi
done

mkdir -p "$BUILD_DIR" "$(dirname "$OUT_FILE")"
ASM_FILE="$BUILD_DIR/${VERSION}_windows_seed.asm"
OBJ_FILE="$BUILD_DIR/${VERSION}_windows_seed.obj"

run_limited() {
    bash -lc '
        limit_kib="$1"
        shift
        ulimit -Sv "$limit_kib"
        ulimit -Hv "$limit_kib" 2>/dev/null || true
        exec "$@"
    ' _ "$MEMORY_LIMIT_KIB" "$@"
}

echo "[INFO] Cross-compiling Windows bootstrap assembly with $COMPILER"
run_limited "$COMPILER" --target windows-x86_64 -asm "$ROOT_DIR/src/main.bpp" > "$ASM_FILE"

echo "[INFO] Assembling Win64 COFF object"
nasm -f win64 -O1 "$ASM_FILE" -o "$OBJ_FILE"

echo "[INFO] Linking PE32+ bootstrap executable"
x86_64-w64-mingw32-ld \
    -m i386pep \
    --subsystem console \
    --entry mainCRTStartup \
    -o "$OUT_FILE" \
    "$OBJ_FILE" \
    -lkernel32

magic="$(od -An -tx1 -N2 "$OUT_FILE" | tr -d '[:space:]')"
if [ "$magic" != "4d5a" ]; then
    echo "Cross-bootstrap output is not a PE executable: $OUT_FILE" >&2
    exit 1
fi

echo "[INFO] Windows bootstrap created: $OUT_FILE"
