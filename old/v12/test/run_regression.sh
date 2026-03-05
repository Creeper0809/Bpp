#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
CONFIG_FILE="$ROOT_DIR/config.ini"

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

COMPILER="${1:-}"
if [ -z "$COMPILER" ]; then
    COMPILER="$(detect_default_compiler)" || {
        echo "[ERROR] Compiler not found."
        echo "[ERROR] Tried: BPP_COMPILER, bin/\${BPP_VERSION}_stage1, bin/bootstrap, bin/stage1, bin/*_stage1"
        exit 1
    }
fi

VERSION="$(derive_version_label "$COMPILER")"
STD_ROOT="$ROOT_DIR/src"

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
version=$VERSION
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
version=$VERSION
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
version=$VERSION
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
