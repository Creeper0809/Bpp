#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALLOWLIST_FILE="${1:-$ROOT_DIR/.github/release-allowlist.txt}"
LIST_SCRIPT="$ROOT_DIR/scripts/list_disallowed_release_files.sh"

if [[ ! -x "$LIST_SCRIPT" ]]; then
  chmod +x "$LIST_SCRIPT"
fi

mapfile -t DISALLOWED_FILES < <("$LIST_SCRIPT" "$ALLOWLIST_FILE")

if (( ${#DISALLOWED_FILES[@]} == 0 )); then
  echo "[INFO] release-tree cleanup: nothing to remove"
  exit 0
fi

echo "[INFO] removing ${#DISALLOWED_FILES[@]} disallowed tracked files"
printf '  - %s\n' "${DISALLOWED_FILES[@]}"

git -C "$ROOT_DIR" rm -r --ignore-unmatch -- "${DISALLOWED_FILES[@]}"

echo "[INFO] cleanup complete"
