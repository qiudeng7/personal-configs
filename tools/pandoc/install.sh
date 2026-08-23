#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="pandoc"
. "$_tools_dir/functions.sh"

repo="jgm/pandoc"
binary_name="pandoc"
install_dir=${PANDOC_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null |
        sed -n 's/^pandoc \([^[:space:]]*\).*/\1/p' |
        sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)
[ "$arch_name" != "riscv64" ] || fail "unsupported architecture: riscv64"

version=$(github_latest_version "$repo")
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

case "$os_name-$arch_name" in
    darwin-arm64)
        asset="pandoc-$version-arm64-macOS.zip"
        binary_path="pandoc-$version-arm64/bin/pandoc"
        ;;
    darwin-amd64)
        asset="pandoc-$version-x86_64-macOS.zip"
        binary_path="pandoc-$version-x86_64/bin/pandoc"
        ;;
    linux-arm64)
        asset="pandoc-$version-linux-arm64.tar.gz"
        binary_path="pandoc-$version/bin/pandoc"
        ;;
    linux-amd64)
        asset="pandoc-$version-linux-amd64.tar.gz"
        binary_path="pandoc-$version/bin/pandoc"
        ;;
    *) fail "unsupported platform: $os_name-$arch_name" ;;
esac

base_url="https://github.com/$repo/releases/download/$version"
tmp_dir=$(make_tmp_dir)
archive="$tmp_dir/$asset"
extract_dir="$tmp_dir/extract"

cleanup() {
    cleanup_tmp_dir "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$extract_dir"
curl -fsSL "$base_url/$asset" -o "$archive"

case "$asset" in
    *.zip) unzip -q "$archive" -d "$extract_dir" ;;
    *.tar.gz) tar -xzf "$archive" -C "$extract_dir" ;;
esac

installed_binary="$extract_dir/$binary_path"
[ -f "$installed_binary" ] || fail "extracted binary not found"
chmod +x "$installed_binary" 2>/dev/null || true
"$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

install_binary "$installed_binary" "$target"
log "installed $version to $target"
