#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="pnpm"
. "$_tools_dir/functions.sh"

repo="pnpm/pnpm"
binary_name="pnpm"
install_dir=${PNPM_INSTALL_DIR:-"$home_dir/.local/bin"}
store_dir=${PNPM_STORE_DIR:-"$home_dir/.local/share/tools/pnpm"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null | sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)

case "$arch_name" in
    amd64) asset_arch="x64" ;;
    arm64) asset_arch="arm64" ;;
    *) fail "unsupported architecture: $arch_name" ;;
esac

case "$os_name" in
    darwin) asset="pnpm-darwin-$asset_arch.tar.gz" ;;
    linux) asset="pnpm-linux-$asset_arch.tar.gz" ;;
esac

version=$(github_latest_version "$repo")
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

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

installed_binary="$extract_dir/$binary_name"
[ -f "$installed_binary" ] || fail "extracted binary not found"
chmod +x "$installed_binary" 2>/dev/null || true
"$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

rm -R "$store_dir" 2>/dev/null || true
mkdir -p "$store_dir"
mv "$extract_dir/$binary_name" "$store_dir/$binary_name"
mv "$extract_dir/dist" "$store_dir/dist"
write_exec_wrapper "$target" "$store_dir/$binary_name"
log "installed $version to $target"
