#!/bin/sh

set -eu

tools_dir=${1:?tools source directory is required}
common_dir="$tools_dir/common"
home_dir=${HOME:?home directory is required}

if ! command -v pacman >/dev/null 2>&1; then
    echo "tools: pacman is required on Arch Linux" >&2
    exit 1
fi

sudo pacman -Syu --needed \
    curl \
    fd \
    ffmpeg \
    github-cli \
    go-yq \
    helm \
    htop \
    jq \
    kubectl \
    pandoc-cli \
    ripgrep \
    unzip \
    vim

sh "$common_dir/main.sh" "$common_dir" "$home_dir" \
    aliyun-cli \
    fnm \
    infisical \
    lark-cli \
    pnpm \
    uv
