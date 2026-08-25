#!/bin/sh

set -eu

tools_dir=${1:?tools source directory is required}
common_dir="$tools_dir/common"
home_dir=${HOME:?home directory is required}

if [ "$(id -u)" -eq 0 ]; then
    echo "tools: run this script as a regular user; it invokes sudo when needed" >&2
    exit 1
fi

docker_user=$(id -un)

if ! command -v pacman >/dev/null 2>&1; then
    echo "tools: pacman is required on Arch Linux" >&2
    exit 1
fi

sudo pacman -Syu --needed \
    curl \
    fd \
    docker \
    docker-buildx \
    docker-compose \
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

if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$docker_user"
sudo systemctl enable --now docker.service containerd.service

echo "tools: $docker_user was added to the docker group; log out and back in to apply it"

sh "$common_dir/main.sh" "$common_dir" "$home_dir" \
    aliyun-cli \
    fnm \
    infisical \
    lark-cli \
    pnpm \
    uv
