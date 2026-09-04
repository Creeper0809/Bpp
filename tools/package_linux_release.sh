#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BPP_PACKAGE_BUILD_DIR:-$ROOT_DIR/build-linux}"
OUT_DIR="${BPP_PACKAGE_OUT_DIR:-$ROOT_DIR/build/release-assets}"
ARCH="${BPP_PACKAGE_ARCH:-linux-x86_64}"

read_version() {
    local version=""
    if [ -f "$ROOT_DIR/config.ini" ]; then
        version="$(grep -E '^VERSION=' "$ROOT_DIR/config.ini" | head -n1 | cut -d'=' -f2- | tr -d '[:space:]')"
    fi
    if [ -z "$version" ]; then
        version="bpp"
    fi
    printf '%s\n' "$version"
}

VERSION="${BPP_PACKAGE_VERSION:-$(read_version)}"
PACKAGE_NAME="bpp-${VERSION}-${ARCH}"
PACKAGE_ROOT="$OUT_DIR/$PACKAGE_NAME"
TARBALL="$OUT_DIR/$PACKAGE_NAME.tar.gz"

cmake -S "$ROOT_DIR" -B "$BUILD_DIR" -DBPP_ACTIVE_VERSION="$VERSION" >/dev/null

mkdir -p "$OUT_DIR"
rm -rf "$PACKAGE_ROOT" "$TARBALL" "$TARBALL.sha256"

cmake --install "$BUILD_DIR" --prefix "$PACKAGE_ROOT"

cat > "$PACKAGE_ROOT/install.sh" <<'INSTALL_SH'
#!/usr/bin/env bash
set -euo pipefail

PREFIX="${BPP_INSTALL_PREFIX:-$HOME/.local}"
ADD_PATH=0
INSTALL_DEPS=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
Usage: ./install.sh [options] [prefix]

Options:
  --prefix <dir>     Install under <dir> instead of $HOME/.local.
  --add-path         Append the install bin directory to the current shell rc.
  --install-deps     Install nasm and binutils with the detected package manager.
  -h, --help         Show this help.

Examples:
  ./install.sh
  ./install.sh --add-path
  ./install.sh --install-deps --add-path
  ./install.sh --prefix /opt/bpp
  ./install.sh /opt/bpp
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --prefix)
            if [ "$#" -lt 2 ]; then
                echo "[ERROR] --prefix requires a path." >&2
                exit 1
            fi
            PREFIX="$2"
            shift 2
            ;;
        --prefix=*)
            PREFIX="${1#--prefix=}"
            shift
            ;;
        --add-path)
            ADD_PATH=1
            shift
            ;;
        --install-deps)
            INSTALL_DEPS=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "[ERROR] Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            PREFIX="$1"
            shift
            ;;
    esac
done

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "[ERROR] sudo is required to install dependencies as a non-root user." >&2
        exit 1
    fi
}

install_deps() {
    local missing=0
    command -v nasm >/dev/null 2>&1 || missing=1
    command -v ld >/dev/null 2>&1 || missing=1
    if [ "$missing" -eq 0 ]; then
        echo "Dependency check: nasm and ld are already available."
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        run_as_root apt-get update
        run_as_root apt-get install -y nasm binutils
    elif command -v dnf >/dev/null 2>&1; then
        run_as_root dnf install -y nasm binutils
    elif command -v yum >/dev/null 2>&1; then
        run_as_root yum install -y nasm binutils
    elif command -v pacman >/dev/null 2>&1; then
        run_as_root pacman -Sy --needed nasm binutils
    elif command -v zypper >/dev/null 2>&1; then
        run_as_root zypper install -y nasm binutils
    elif command -v apk >/dev/null 2>&1; then
        run_as_root apk add nasm binutils
    else
        cat >&2 <<'EOF'
[ERROR] Could not detect a supported package manager.
Install dependencies manually:
  Debian/Ubuntu: sudo apt-get install nasm binutils
  Fedora:        sudo dnf install nasm binutils
  Arch:          sudo pacman -S nasm binutils
  openSUSE:      sudo zypper install nasm binutils
  Alpine:        sudo apk add nasm binutils
EOF
        exit 1
    fi
}

detect_shell_rc() {
    local shell_name
    shell_name="$(basename "${SHELL:-}")"
    case "$shell_name" in
        zsh)
            printf '%s\n' "$HOME/.zshrc"
            ;;
        bash)
            if [ -f "$HOME/.bashrc" ] || [ ! -f "$HOME/.bash_profile" ]; then
                printf '%s\n' "$HOME/.bashrc"
            else
                printf '%s\n' "$HOME/.bash_profile"
            fi
            ;;
        fish)
            printf '%s\n' "$HOME/.config/fish/config.fish"
            ;;
        *)
            printf '%s\n' "$HOME/.profile"
            ;;
    esac
}

add_path_to_shell() {
    local bin_dir="$PREFIX/bin"
    local rc_file
    local shell_name
    rc_file="$(detect_shell_rc)"
    shell_name="$(basename "${SHELL:-}")"
    mkdir -p "$(dirname "$rc_file")"
    touch "$rc_file"

    if [ "$shell_name" = "fish" ]; then
        if grep -Fq "$bin_dir" "$rc_file"; then
            echo "PATH entry already exists in $rc_file"
            return 0
        fi
        {
            echo ""
            echo "# Bpp"
            echo "fish_add_path \"$bin_dir\""
        } >> "$rc_file"
    else
        if grep -Fq "export PATH=\"$bin_dir:\$PATH\"" "$rc_file" || grep -Fq "$bin_dir" "$rc_file"; then
            echo "PATH entry already exists in $rc_file"
            return 0
        fi
        {
            echo ""
            echo "# Bpp"
            echo "export PATH=\"$bin_dir:\$PATH\""
        } >> "$rc_file"
    fi
    echo "Added $bin_dir to PATH in $rc_file"
}

if [ "$INSTALL_DEPS" -eq 1 ]; then
    install_deps
fi

mkdir -p "$PREFIX/bin" "$PREFIX/libexec" "$PREFIX/share"
cp -R "$SCRIPT_DIR/bin/." "$PREFIX/bin/"
cp -R "$SCRIPT_DIR/libexec/." "$PREFIX/libexec/"
cp -R "$SCRIPT_DIR/share/." "$PREFIX/share/"
chmod +x "$PREFIX/bin/bpp" "$PREFIX"/libexec/bpp/* 2>/dev/null || true

if [ "$ADD_PATH" -eq 1 ]; then
    add_path_to_shell
fi

cat <<EOF
Bpp installed under: $PREFIX

Add this to PATH if needed, or rerun ./install.sh --add-path:
  export PATH="$PREFIX/bin:\$PATH"

Current native backend still requires:
  - nasm
  - ld from binutils

Install those automatically with:
  ./install.sh --install-deps
EOF
INSTALL_SH
chmod +x "$PACKAGE_ROOT/install.sh"

cat > "$PACKAGE_ROOT/README.md" <<EOF
# Bpp ${VERSION} Linux SDK

This package contains the Bpp launcher, a matching self-hosted compiler binary,
and the matching standard library snapshot.

## Install

\`\`\`bash
./install.sh
\`\`\`

Install to a custom prefix:

\`\`\`bash
./install.sh /opt/bpp
\`\`\`

Useful install options:

\`\`\`bash
./install.sh --add-path
./install.sh --install-deps
./install.sh --prefix /opt/bpp
\`\`\`

## Use Without Installing

\`\`\`bash
./bin/bpp hello.bpp
\`\`\`

## Native Backend Requirements

The current compiler still invokes the system assembler and linker:

- \`nasm\`
- \`ld\` from \`binutils\`

On Debian/Ubuntu:

\`\`\`bash
sudo apt-get install nasm binutils
\`\`\`
EOF

(
    cd "$OUT_DIR"
    tar --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -czf "$TARBALL" "$PACKAGE_NAME"
)

hash="$(sha256sum "$TARBALL" | awk '{print $1}')"
printf '%s  %s\n' "$hash" "$(basename "$TARBALL")" > "$TARBALL.sha256"

echo "$TARBALL"
