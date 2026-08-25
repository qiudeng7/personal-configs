#!/bin/sh

set -eu

tools_dir=${1:?tools source directory is required}
common_dir="$tools_dir/common"
home_dir=${HOME:?home directory is required}

if ! command -v apt-get >/dev/null 2>&1; then
    echo "tools: apt-get is required on Ubuntu" >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y \
    curl \
    fd-find \
    ffmpeg \
    gh \
    htop \
    jq \
    pandoc \
    ripgrep \
    unzip \
    vim

mkdir -p "$HOME/.local/bin"
ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"

sh "$common_dir/main.sh" "$common_dir" "$home_dir" \
    aliyun-cli \
    fnm \
    infisical \
    lark-cli \
    pnpm \
    uv \
    helm \
    kubectl \
    yq
