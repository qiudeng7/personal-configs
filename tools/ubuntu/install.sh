#!/bin/sh

# Main stage for the Ubuntu toolset.
# Order: prepare apt sources, install packages, configure Docker, then run common.
# Docker Engine uses docker-ce-cli and containerd.io; Buildx and Compose are CLI
# plugins supplied by docker-buildx-plugin and docker-compose-plugin.

set -eu

tools_dir=${1:?tools source directory is required}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
common_dir="$tools_dir/common"
home_dir=${HOME:?home directory is required}

if [ "$(id -u)" -eq 0 ]; then
    echo "tools: run this script as a regular user; it invokes sudo when needed" >&2
    exit 1
fi

docker_user=$(id -un)

if ! command -v apt-get >/dev/null 2>&1; then
    echo "tools: apt-get is required on Ubuntu" >&2
    exit 1
fi

sh "$script_dir/prepare.sh"

sudo apt-get install -y \
    containerd.io \
    curl \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    fd-find \
    ffmpeg \
    gh \
    htop \
    jq \
    pandoc \
    ripgrep \
    unzip \
    vim

sh "$script_dir/post-install.sh" "$docker_user"

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
