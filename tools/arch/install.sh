#!/bin/sh

# Main stage for the Arch Linux toolset.
# Order: install pacman packages, configure Docker, then run Arch-local binary
# installers. No prepare stage is needed because every system package here uses
# the regular pacman repositories already configured on the machine.

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

tools_name="tools/arch"

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

sh "$system_dir/post-install.sh" "$docker_user"

prepare_binary_installation "$home_dir"

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
