#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="yq"
. "$_tools_dir/functions.sh"

repo="mikefarah/yq"
binary_name="yq"
install_dir=${YQ_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null |
        sed -n 's/.* version v\{0,1\}\([0-9][^[:space:]]*\).*/\1/p' |
        sed -n '1p'
}

yq_checksum_for() {
    checksums=$1
    asset=$2

    set -- $(grep "^$asset[[:space:]]" "$checksums" | sed -n '1p')
    [ "$#" -ge 19 ] || return 0

    shift 18
    echo "$1"
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

asset="yq_${os_name}_${arch_name}"
checksums_asset="checksums"
base_url="https://github.com/$repo/releases/download/v$version"
tmp_dir=$(make_tmp_dir)
download="$tmp_dir/$asset"
checksums="$tmp_dir/$checksums_asset"

cleanup() {
    cleanup_tmp_dir "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

curl -fsSL "$base_url/$asset" -o "$download"
curl -fsSL "$base_url/$checksums_asset" -o "$checksums"

expected=$(yq_checksum_for "$checksums" "$asset")
[ -n "$expected" ] || fail "checksum not found for $asset"
verify_sha256 "$download" "$expected"

chmod +x "$download" 2>/dev/null || true
"$download" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

install_binary "$download" "$target"
log "installed $version to $target"
