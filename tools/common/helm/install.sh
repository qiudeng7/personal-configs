#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="helm"
. "$_tools_dir/functions.sh"

repo="helm/helm"
binary_name="helm"
install_dir=${HELM_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" version --short 2>/dev/null |
        sed -n 's/^v\([^+[:space:]]*\).*/\1/p' |
        sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)

version=$(github_latest_version "$repo")
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

asset="helm-v$version-$os_name-$arch_name.tar.gz"
checksum_asset="$asset.sha256sum"
base_url="https://get.helm.sh"
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

expected=$(checksum_for "$checksum" "$asset")
[ -n "$expected" ] || fail "checksum not found for $asset"
verify_sha256 "$archive" "$expected"

tar -xzf "$archive" -C "$extract_dir"
installed_binary="$extract_dir/$os_name-$arch_name/$binary_name"
[ -f "$installed_binary" ] || fail "extracted binary not found"
chmod +x "$installed_binary" 2>/dev/null || true
"$installed_binary" version --short >/dev/null 2>&1 || fail "downloaded binary failed version check"

install_binary "$installed_binary" "$target"
log "installed $version to $target"
