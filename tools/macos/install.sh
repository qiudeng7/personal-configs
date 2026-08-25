#!/bin/sh

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

tools_name="tools/macos"

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
