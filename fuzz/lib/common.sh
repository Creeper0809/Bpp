#!/usr/bin/env bash

set -euo pipefail

fuzz_now() {
    date +"%Y-%m-%d %H:%M:%S"
}

fuzz_log() {
    printf '[%s] %s\n' "$(fuzz_now)" "$*"
}

fuzz_norm_err() {
    local err_file="$1"
    if [[ ! -f "$err_file" ]]; then
        echo ""
        return 0
    fi

    sed -E \
        -e 's/[0-9]+/N/g' \
        -e 's#/[^ ]+#<PATH>#g' \
        -e 's/[[:space:]]+/ /g' \
        "$err_file" | head -c 4096
}

fuzz_hash_str() {
    local value="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$value" | sha256sum | awk '{print $1}'
        return 0
    fi
    if command -v shasum >/dev/null 2>&1; then
        printf '%s' "$value" | shasum -a 256 | awk '{print $1}'
        return 0
    fi
    printf '%s' "$value" | cksum | awk '{print $1}'
}

fuzz_pick_compiler() {
    local repo_root="$1"

    if [[ -n "${FUZZ_COMPILER:-}" && -x "${FUZZ_COMPILER}" ]]; then
        echo "${FUZZ_COMPILER}"
        return 0
    fi

    if [[ -x "$repo_root/bin/stage1" ]]; then
        echo "$repo_root/bin/stage1"
        return 0
    fi

    local best=""
    best="$(ls "$repo_root"/bin/v*_stage1 2>/dev/null | sort -V | tail -n 1 || true)"
    if [[ -n "$best" && -x "$best" ]]; then
        echo "$best"
        return 0
    fi

    if [[ -x "$repo_root/bin/bootstrap" ]]; then
        echo "$repo_root/bin/bootstrap"
        return 0
    fi

    return 1
}

fuzz_split_iters() {
    local total="$1"
    local jobs="$2"
    local worker_idx="$3"

    local base=$(( total / jobs ))
    local rem=$(( total % jobs ))

    local start=0
    local count=0
    if (( worker_idx <= rem )); then
        count=$(( base + 1 ))
        start=$(( (worker_idx - 1) * count + 1 ))
    else
        count=$base
        start=$(( rem * (base + 1) + (worker_idx - rem - 1) * base + 1 ))
    fi

    local end=$(( start + count - 1 ))
    if (( count <= 0 )); then
        start=1
        end=0
    fi

    echo "$start $end"
}
