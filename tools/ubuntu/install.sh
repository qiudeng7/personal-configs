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

if ! command -v apt-get >/dev/null 2>&1; then
    echo "tools: apt-get is required on Ubuntu" >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
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

for conflicting_package in \
    docker.io \
    docker-compose \
    docker-compose-v2 \
    docker-doc \
    docker-buildx \
    podman-docker \
    containerd \
    runc
do
    if dpkg-query -W -f='${Status}' "$conflicting_package" 2>/dev/null |
        grep -q '^install ok installed$'
    then
        sudo apt-get remove -y "$conflicting_package"
    fi
done

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
docker_suite=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
if [ -z "$docker_suite" ]; then
    echo "tools: cannot determine Ubuntu codename for Docker repository" >&2
    exit 1
fi

docker_arch=$(dpkg --print-architecture)
{
    printf '%s\n' \
        'Types: deb' \
        'URIs: https://download.docker.com/linux/ubuntu' \
        "Suites: $docker_suite" \
        'Components: stable' \
        "Architectures: $docker_arch" \
        'Signed-By: /etc/apt/keyrings/docker.asc'
} | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null

sudo apt-get update
sudo apt-get install -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin

if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$docker_user"
sudo systemctl enable --now docker.service containerd.service

echo "tools: $docker_user was added to the docker group; log out and back in to apply it"

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
