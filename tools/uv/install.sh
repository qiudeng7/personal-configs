#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="uv"
. "$_tools_dir/functions.sh"

repo="astral-sh/uv"
binary_name="uv"
install_dir=${UV_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null |
        sed -n 's/^uv \([^[:space:]]*\).*/\1/p' |
        sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)

case "$os_name-$arch_name" in
    darwin-arm64) target_triple="aarch64-apple-darwin" ;;
    darwin-amd64) target_triple="x86_64-apple-darwin" ;;
    linux-arm64) target_triple="aarch64-unknown-linux-gnu" ;;
    linux-amd64) target_triple="x86_64-unknown-linux-gnu" ;;
    linux-riscv64) target_triple="riscv64gc-unknown-linux-gnu" ;;
    *) fail "unsupported platform: $os_name-$arch_name" ;;
esac

version=$(github_latest_version "$repo")
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
else

    asset="uv-$target_triple.tar.gz"
    checksum_asset="$asset.sha256"
    base_url="https://github.com/$repo/releases/download/$version"
    tmp_dir=$(make_tmp_dir)
    archive="$tmp_dir/$asset"
    checksum="$tmp_dir/$checksum_asset"
    extract_dir="$tmp_dir/extract"

    cleanup() {
        cleanup_tmp_dir "$tmp_dir"
    }
    trap cleanup EXIT HUP INT TERM

    mkdir -p "$extract_dir"
    curl -fsSL "$base_url/$asset" -o "$archive"
    curl -fsSL "$base_url/$checksum_asset" -o "$checksum"

    expected=$(sed 's/[[:space:]].*//' "$checksum" | sed -n '1p')
    [ -n "$expected" ] || fail "checksum not found for $asset"
    verify_sha256 "$archive" "$expected"

    tar -xzf "$archive" -C "$extract_dir"
    installed_binary="$extract_dir/uv-$target_triple/$binary_name"
    [ -f "$installed_binary" ] || fail "extracted binary not found"
    chmod +x "$installed_binary" 2>/dev/null || true
    "$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

    install_binary "$installed_binary" "$target"
    log "installed $version to $target"
fi

install_uv_tool() {
    package=$1
    command_name=$2
    tool_bin_dir="$home_dir/.local/bin"
    tool_dir="$home_dir/.local/share/tools/uv"
    command_path="$tool_bin_dir/$command_name"

    before=""
    if [ -x "$command_path" ]; then
        before=$("$command_path" --version 2>/dev/null | sed -n '1p' || true)
    fi

    UV_TOOL_BIN_DIR="$tool_bin_dir" \
    UV_TOOL_DIR="$tool_dir" \
        "$target" tool install --upgrade "$package"

    [ -x "$command_path" ] || fail "$command_name installation did not produce an executable"
    after=$("$command_path" --version 2>/dev/null | sed -n '1p' || true)
    [ -n "$after" ] || fail "$command_name installation did not produce a working executable"

    if [ "$before" = "$after" ]; then
        log "$command_name already latest ($after)"
    else
        log "$command_name installed $after to $command_path"
    fi
}

install_uv_tool tccli tccli
