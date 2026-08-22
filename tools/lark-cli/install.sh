#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

repo="larksuite/cli"
binary_name="lark-cli"
install_dir=${LARK_CLI_INSTALL_DIR:-"$home_dir/.local/bin"}
target="$install_dir/$binary_name"

log() {
    echo "lark-cli: $*"
}

fail() {
    echo "lark-cli: $*" >&2
    exit 1
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "darwin" ;;
        Linux) echo "linux" ;;
        *) fail "unsupported OS: $(uname -s)" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        arm64|aarch64) echo "arm64" ;;
        x86_64|amd64) echo "amd64" ;;
        riscv64) echo "riscv64" ;;
        *) fail "unsupported architecture: $(uname -m)" ;;
    esac
}

latest_version() {
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
        sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' |
        sed -n '1p'
}

installed_version() {
    if [ ! -x "$target" ]; then
        return 0
    fi

    "$target" --version 2>/dev/null |
        sed -n 's/^lark-cli version //p' |
        sed -n '1p'
}

sha256_file() {
    file=$1

    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | sed 's/[[:space:]].*//'
        return 0
    fi
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | sed 's/[[:space:]].*//'
        return 0
    fi

    fail "no sha256 checker found"
}

checksum_for() {
    checksums=$1
    asset=$2

    grep "  $asset\$" "$checksums" | sed 's/[[:space:]].*//' | sed -n '1p'
}

extract_binary() {
    archive=$1
    destination=$2

    tar -xzf "$archive" -C "$destination" "$binary_name"
}

os_name=$(detect_os)
arch_name=$(detect_arch)
extension="tar.gz"

if [ "$os_name" = "darwin" ] && [ "$arch_name" = "riscv64" ]; then
    fail "unsupported platform: darwin-riscv64"
fi

version=$(latest_version)
[ -n "$version" ] || fail "failed to resolve latest GitHub release"

current=$(installed_version)
if [ "$current" = "$version" ]; then
    log "already latest ($version)"
    exit 0
fi

asset="$binary_name-$version-$os_name-$arch_name.$extension"
base_url="https://github.com/$repo/releases/download/v$version"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/lark-cli.XXXXXX")
archive="$tmp_dir/$asset"
checksums="$tmp_dir/checksums.txt"
extract_dir="$tmp_dir/extract"

cleanup() {
    if [ -n "${tmp_dir:-}" ] && [ -d "$tmp_dir" ]; then
        [ -f "$archive" ] && rm "$archive" 2>/dev/null || true
        [ -f "$checksums" ] && rm "$checksums" 2>/dev/null || true
        rmdir "$extract_dir" 2>/dev/null || true
        rmdir "$tmp_dir" 2>/dev/null || true
    fi
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$extract_dir"
curl -fsSL "$base_url/$asset" -o "$archive"
curl -fsSL "$base_url/checksums.txt" -o "$checksums"

expected=$(checksum_for "$checksums" "$asset")
[ -n "$expected" ] || fail "checksum not found for $asset"

actual=$(sha256_file "$archive")
[ "$actual" = "$expected" ] || fail "checksum mismatch for $asset"

extract_binary "$archive" "$extract_dir"

installed_binary="$extract_dir/$binary_name"
[ -f "$installed_binary" ] || fail "extracted binary not found"

chmod +x "$installed_binary" 2>/dev/null || true
"$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

mkdir -p "$install_dir"
mv "$installed_binary" "$target"
chmod +x "$target" 2>/dev/null || true

log "installed $version to $target"
