#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../.."
COMPILER="${1:-$ROOT_DIR/bin/v11_stage1}"
STD_ROOT="$ROOT_DIR/v11/src"

if [ ! -x "$COMPILER" ]; then
    echo "[ERROR] Compiler not found or not executable: $COMPILER"
    exit 1
fi

if [ ! -d "$STD_ROOT" ]; then
    echo "[ERROR] std root not found: $STD_ROOT"
    exit 1
fi

TMP_DIR="$(mktemp -d "/tmp/bpp_regression_XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[1/3] Parser diagnostic regression"
mkdir -p "$TMP_DIR/proj_diag/src"
cat > "$TMP_DIR/proj_diag/bpp.toml" <<EOF
version=v11
module_root=src
std_root=$STD_ROOT
EOF
BAD_SRC="$TMP_DIR/proj_diag/src/bad_syntax.bpp"
BAD_ERR="$TMP_DIR/bad_syntax.err"
cat > "$BAD_SRC" <<'EOF'
func main() -> u64 {
    var x: u64 = 1
    return 0;
}
EOF

if "$COMPILER" -asm "$BAD_SRC" > /dev/null 2> "$BAD_ERR"; then
    echo "[ERROR] Expected syntax failure but compilation succeeded"
    exit 1
fi
grep -Fq "Unexpected token" "$BAD_ERR"
grep -Fq "line" "$BAD_ERR"
grep -Fq "column" "$BAD_ERR"
if grep -Fq "Parse error" "$BAD_ERR"; then
    echo "[ERROR] Legacy 'Parse error' message leaked"
    exit 1
fi

echo "[2/3] Manifest module_root/std_root regression"
mkdir -p "$TMP_DIR/proj_ok/src/app" "$TMP_DIR/proj_ok/cli"
cat > "$TMP_DIR/proj_ok/bpp.toml" <<EOF
version=v11
module_root=src
std_root=$STD_ROOT
EOF
cat > "$TMP_DIR/proj_ok/src/app/math.bpp" <<'EOF'
func app_value() -> u64 {
    return 7;
}
EOF
cat > "$TMP_DIR/proj_ok/cli/main.bpp" <<'EOF'
import app.math;

func main() -> u64 {
    return app_value();
}
EOF
"$COMPILER" -asm "$TMP_DIR/proj_ok/cli/main.bpp" > /dev/null

echo "[3/3] Tool override regression (nasm_path)"
mkdir -p "$TMP_DIR/proj_bad/src"
cat > "$TMP_DIR/proj_bad/bpp.toml" <<EOF
version=v11
module_root=src
std_root=$STD_ROOT
nasm_path=/definitely/missing/nasm
ld_path=/usr/bin/ld
EOF
cat > "$TMP_DIR/proj_bad/src/main.bpp" <<'EOF'
func main() -> u64 {
    return 0;
}
EOF

BAD_TOOL_ERR="$TMP_DIR/bad_tool.err"
if "$COMPILER" "$TMP_DIR/proj_bad/src/main.bpp" > /dev/null 2> "$BAD_TOOL_ERR"; then
    echo "[ERROR] Expected tool override failure but compilation succeeded"
    exit 1
fi
grep -Fq "assembler not found at nasm_path from bpp.toml" "$BAD_TOOL_ERR"

echo "[OK] regression checks passed"
