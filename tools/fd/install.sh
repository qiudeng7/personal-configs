#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="fd"
. "$_tools_dir/functions.sh"

repo="sharkdp/fd"
binary_name="fd"
install_dir=${FD_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null |
        sed -n 's/^fd \([^[:space:]]*\).*/\1/p' |
        sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)

case "$os_name-$arch_name" in
    darwin-arm64) target_triple="aarch64-apple-darwin" ;;
    darwin-amd64) target_triple="x86_64-apple-darwin" ;;
    linux-arm64) target_triple="aarch64-unknown-linux-gnu" ;;
    linux-amd64) target_triple="x86_64-unknown-linux-gnu" ;;
    *) fail "unsupported platform: $os_name-$arch_name" ;;
esac

version=$(github_latest_version "$repo")
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

asset="fd-v$version-$target_triple.tar.gz"
base_url="https://github.com/$repo/releases/download/v$version"
tmp_dir=$(make_tmp_dir)
archive="$tmp_dir/$asset"
extract_dir="$tmp_dir/extract"

cleanup() {
    cleanup_tmp_dir "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$extract_dir"
curl -fsSL "$base_url/$asset" -o "$archive"
tar -xzf "$archive" -C "$extract_dir"

installed_binary="$extract_dir/fd-v$version-$target_triple/$binary_name"
[ -f "$installed_binary" ] || fail "extracted binary not found"
chmod +x "$installed_binary" 2>/dev/null || true
"$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

install_binary "$installed_binary" "$target"
log "installed $version to $target"
