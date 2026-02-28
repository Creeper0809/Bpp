#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALLOWLIST_FILE="${1:-$ROOT_DIR/.github/release-allowlist.txt}"

if [[ ! -f "$ALLOWLIST_FILE" ]]; then
  echo "[ERROR] allowlist not found: $ALLOWLIST_FILE" >&2
  exit 1
fi

mapfile -t ALLOW_PATTERNS < <(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$ALLOWLIST_FILE" | grep -Ev '^(#|$)' || true)

if (( ${#ALLOW_PATTERNS[@]} == 0 )); then
  echo "[ERROR] allowlist is empty: $ALLOWLIST_FILE" >&2
  exit 1
fi

is_allowed() {
  local file_path="$1"
  local pattern
  for pattern in "${ALLOW_PATTERNS[@]}"; do
    if [[ "$file_path" == $pattern ]]; then
      return 0
    fi
  done
  return 1
}

while IFS= read -r tracked_file; do
  if ! is_allowed "$tracked_file"; then
    echo "$tracked_file"
  fi
done < <(git -C "$ROOT_DIR" ls-files)
