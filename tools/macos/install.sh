#!/bin/sh

set -eu

tools_dir=${1:?tools source directory is required}
common_dir="$tools_dir/common"
home_dir=${HOME:?home directory is required}

if ! command -v brew >/dev/null 2>&1; then
    echo "tools: Homebrew is required on macOS" >&2
    exit 1
fi

brew install \
    fd \
    ffmpeg \
    gh \
    helm \
    htop \
    jq \
    kubectl \
    pandoc \
    ripgrep \
    vim \
    yq

sh "$common_dir/main.sh" "$common_dir" "$home_dir" \
    aliyun-cli \
    fnm \
    infisical \
    lark-cli \
    pnpm \
    uv
