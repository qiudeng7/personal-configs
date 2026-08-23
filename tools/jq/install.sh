#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="jq"
. "$_tools_dir/functions.sh"

repo="jqlang/jq"
binary_name="jq"
install_dir=${JQ_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

latest_tag() {
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
        sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
        sed -n '1p'
}

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null |
        sed -n 's/^jq-\(.*\)$/\1/p' |
        sed -n '1p'
}

os_name=$(detect_os)
arch_name=$(detect_arch)
[ "$arch_name" != "riscv64" ] || fail "unsupported architecture: riscv64"

case "$os_name" in
    darwin) asset_os="macos" ;;
    linux) asset_os="linux" ;;
esac

tag=$(latest_tag)
[ -n "$tag" ] || fail "failed to resolve latest GitHub release"
version=${tag#jq-}

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

asset="jq-$asset_os-$arch_name"
checksums_asset="sha256sum.txt"
base_url="https://github.com/$repo/releases/download/$tag"
tmp_dir=$(make_tmp_dir)
download="$tmp_dir/$asset"
checksums="$tmp_dir/$checksums_asset"

cleanup() {
    cleanup_tmp_dir "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

curl -fsSL "$base_url/$asset" -o "$download"
curl -fsSL "$base_url/$checksums_asset" -o "$checksums"

expected=$(checksum_for "$checksums" "$asset")
[ -n "$expected" ] || fail "checksum not found for $asset"
verify_sha256 "$download" "$expected"

chmod +x "$download" 2>/dev/null || true
"$download" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

install_binary "$download" "$target"
log "installed $version to $target"
