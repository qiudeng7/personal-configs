#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="gh"
. "$_tools_dir/functions.sh"

repo="cli/cli"
binary_name="gh"
install_dir=${GH_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null |
        sed -n 's/^gh version \([^[:space:]]*\).*/\1/p' |
        sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)

case "$os_name" in
    darwin)
        platform="macOS"
        extension="zip"
        ;;
    linux)
        platform="linux"
        extension="tar.gz"
        ;;
esac

[ "$arch_name" != "riscv64" ] || fail "unsupported architecture: riscv64"

version=$(github_latest_version "$repo")
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

asset="gh_${version}_${platform}_${arch_name}.${extension}"
checksums_asset="gh_${version}_checksums.txt"
base_url="https://github.com/$repo/releases/download/v$version"
tmp_dir=$(make_tmp_dir)
archive="$tmp_dir/$asset"
checksums="$tmp_dir/$checksums_asset"
extract_dir="$tmp_dir/extract"

cleanup() {
    cleanup_tmp_dir "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$extract_dir"
curl -fsSL "$base_url/$asset" -o "$archive"
curl -fsSL "$base_url/$checksums_asset" -o "$checksums"

expected=$(checksum_for "$checksums" "$asset")
[ -n "$expected" ] || fail "checksum not found for $asset"
verify_sha256 "$archive" "$expected"

case "$extension" in
    zip) unzip -q "$archive" -d "$extract_dir" ;;
    tar.gz) tar -xzf "$archive" -C "$extract_dir" ;;
esac

installed_binary="$extract_dir/gh_${version}_${platform}_${arch_name}/bin/gh"
[ -f "$installed_binary" ] || fail "extracted binary not found"
chmod +x "$installed_binary" 2>/dev/null || true
"$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

install_binary "$installed_binary" "$target"
log "installed $version to $target"
