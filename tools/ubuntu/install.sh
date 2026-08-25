#!/bin/sh

# Main stage for the Ubuntu toolset.
# Order: prepare apt sources, install packages, configure Docker, then run
# Ubuntu-local binary installers.
# Docker Engine uses docker-ce-cli and containerd.io; Buildx and Compose are CLI
# plugins supplied by docker-buildx-plugin and docker-compose-plugin.

set -eu

tools_dir=${1:?tools source directory is required}
system_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
home_dir=${HOME:?home directory is required}

. "$tools_dir/functions.sh"
. "$system_dir/get-binaries/aliyun-cli.sh"
. "$system_dir/get-binaries/fnm.sh"
. "$system_dir/get-binaries/infisical.sh"
. "$system_dir/get-binaries/lark-cli.sh"
. "$system_dir/get-binaries/pnpm.sh"
. "$system_dir/get-binaries/uv.sh"
. "$system_dir/get-binaries/helm.sh"
. "$system_dir/get-binaries/kubectl.sh"
. "$system_dir/get-binaries/yq.sh"

tools_name="tools/ubuntu"

if [ "$(id -u)" -eq 0 ]; then
    echo "tools: run this script as a regular user; it invokes sudo when needed" >&2
    exit 1
fi

docker_user=$(id -un)

if ! command -v apt-get >/dev/null 2>&1; then
    echo "tools: apt-get is required on Ubuntu" >&2
    exit 1
fi

sh "$system_dir/prepare.sh"

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

sh "$system_dir/post-install.sh" "$docker_user"

prepare_binary_installation "$home_dir"

ln -sfn "$(command -v fdfind)" "$home_dir/.local/bin/fd"

log "aliyun-cli"
install_aliyun_cli
log "fnm"
install_fnm
log "infisical"
install_infisical
log "lark-cli"
install_lark_cli
log "pnpm"
install_pnpm
log "uv"
install_uv
log "helm"
install_helm
log "kubectl"
install_kubectl
log "yq"
install_yq
