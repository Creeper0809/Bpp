#!/usr/bin/env bash
set -euo pipefail

# Publish docs/wiki/*.md to GitHub Wiki (separate git repo: <repo>.wiki.git)
#
# Usage:
#   scripts/publish_wiki.sh <owner/repo> [source_dir]
#
# Example:
#   scripts/publish_wiki.sh Creeper0809/Bpp docs/wiki
#
# Auth resolution order:
# 1) GITHUB_TOKEN env var
# 2) GH_TOKEN env var
# 3) gh auth token (if gh CLI is logged in)
# 4) existing git credential helper/session

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <owner/repo> [source_dir]"
  exit 1
fi

REPO_SLUG="$1"
SRC_DIR="${2:-docs/wiki}"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "[ERROR] source dir not found: $SRC_DIR"
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GITHUB_TOKEN="${GITHUB_TOKEN:-}"
AUTH_SOURCE=""
if [[ -z "$GITHUB_TOKEN" ]]; then
  GITHUB_TOKEN="${GH_TOKEN:-}"
  if [[ -n "$GITHUB_TOKEN" ]]; then
    AUTH_SOURCE="GH_TOKEN"
  fi
else
  AUTH_SOURCE="GITHUB_TOKEN"
fi
if [[ -z "$GITHUB_TOKEN" ]] && command -v gh >/dev/null 2>&1; then
  GH_AUTH_TOKEN="$(gh auth token 2>/dev/null || true)"
  if [[ -n "$GH_AUTH_TOKEN" ]]; then
    GITHUB_TOKEN="$GH_AUTH_TOKEN"
    AUTH_SOURCE="gh auth token"
  fi
fi

WIKI_URL="https://github.com/${REPO_SLUG}.wiki.git"
echo "[INFO] cloning wiki: ${REPO_SLUG}.wiki.git"

AUTH_GIT_ARGS=()
if [[ -n "$GITHUB_TOKEN" ]]; then
  AUTH_B64="$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 | tr -d '\n')"
  AUTH_GIT_ARGS=(-c "http.extraheader=Authorization: Basic ${AUTH_B64}")
  echo "[INFO] auth source: ${AUTH_SOURCE}"
else
  echo "[INFO] auth source: none (using git credential helper/session if available)"
fi

if ! git "${AUTH_GIT_ARGS[@]}" clone "$WIKI_URL" "$TMP_DIR"; then
  echo "[ERROR] failed to clone wiki repository"
  echo "[HINT] Run 'gh auth login' (then retry) or set GITHUB_TOKEN/GH_TOKEN"
  echo "[HINT] If wiki is disabled, enable it at: https://github.com/${REPO_SLUG}/settings"
  exit 1
fi

echo "[INFO] syncing markdown pages from $SRC_DIR"
rsync -a --delete --exclude='.git' "${SRC_DIR}/" "${TMP_DIR}/"
# Normalize wiki page file mode (avoid executable markdown files in wiki history)
find "${TMP_DIR}" -maxdepth 1 -type f -name "*.md" -exec chmod 644 {} \;

pushd "$TMP_DIR" >/dev/null

git config user.name "${GIT_AUTHOR_NAME:-bpp-wiki-bot}"
git config user.email "${GIT_AUTHOR_EMAIL:-bpp-wiki-bot@users.noreply.github.com}"

git add .
if git diff --cached --quiet; then
  echo "[INFO] no wiki changes to publish"
  popd >/dev/null
  exit 0
fi

git commit -m "Sync wiki from ${SRC_DIR}"
if ! git "${AUTH_GIT_ARGS[@]}" push origin HEAD; then
  echo "[ERROR] failed to push wiki changes"
  echo "[HINT] Check token permission (Contents: write) and repo access"
  popd >/dev/null
  exit 1
fi
popd >/dev/null

echo "[INFO] wiki publish completed"
