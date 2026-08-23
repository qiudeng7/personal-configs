#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="ffmpeg"
. "$_tools_dir/functions.sh"

install_dir=${FFMPEG_INSTALL_DIR:-"$home_dir/.local/bin"}

os_name=$(detect_os)
arch_name=$(detect_arch)
[ "$arch_name" != "riscv64" ] || fail "unsupported architecture: riscv64"

case "$os_name" in
    darwin) platform="macos" ;;
    linux) platform="linux" ;;
esac

base_url="https://ffmpeg.martin-riedl.de/redirect/latest/$platform/$arch_name/snapshot"
tmp_dir=$(make_tmp_dir)
extract_dir="$tmp_dir/extract"

installed_version() {
    binary_path=$1
    [ -x "$binary_path" ] || return 0
    "$binary_path" -version 2>/dev/null |
        sed -n 's/^[^[:space:]]* version \(N-[^[:space:]]*\)-https.*/\1/p' |
        sed -n '1p'
}

url_version() {
    url=$1
    echo "$url" | sed -n 's|.*/[0-9][0-9]*_\(N-[^/]*\)/.*|\1|p'
}

cleanup() {
    cleanup_tmp_dir "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$extract_dir"

for binary_name in ffmpeg ffprobe; do
    target="$install_dir/$binary_name"
    archive="$tmp_dir/$binary_name.zip"
    checksum="$tmp_dir/$binary_name.zip.sha256"
    probe="$tmp_dir/$binary_name.url-probe"

    effective_url=$(curl -fsSL -r 0-0 -w '%{url_effective}' "$base_url/$binary_name.zip" -o "$probe")
    version=$(url_version "$effective_url")
    current=$(installed_version "$target")
    if [ -n "$version" ] && [ "$current" = "$version" ]; then
        log "$binary_name already latest ($version)"
        continue
    fi

    curl -fsSL "$effective_url" -o "$archive"
    curl -fsSL "$effective_url.sha256" -o "$checksum"

    expected=$(sed 's/[[:space:]].*//' "$checksum" | sed -n '1p')
    [ -n "$expected" ] || fail "checksum not found for $binary_name"
    verify_sha256 "$archive" "$expected"

    unzip -q "$archive" -d "$extract_dir/$binary_name"
    installed_binary="$extract_dir/$binary_name/$binary_name"
    [ -f "$installed_binary" ] || fail "extracted binary not found"
    chmod +x "$installed_binary" 2>/dev/null || true
    "$installed_binary" -version >/dev/null 2>&1 || fail "downloaded $binary_name failed version check"

    install_binary "$installed_binary" "$target"
    log "installed $binary_name to $target"
done
