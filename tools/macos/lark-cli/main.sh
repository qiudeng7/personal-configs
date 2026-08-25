# macOS installer for lark-cli.
# Depends on tools/functions.sh and home_dir from tools/macos/install.sh.

install_lark_cli() (
    set -eu

    tools_name="lark-cli"
    repo="larksuite/cli"
    binary_name="lark-cli"
    install_dir=${LARK_CLI_INSTALL_DIR:-"$home_dir/.local/bin"}
    target="$install_dir/$binary_name"
    os_name="darwin"
    arch_name=$(detect_arch)
    extension="tar.gz"

    [ "$arch_name" != "riscv64" ] || fail "unsupported platform: darwin-riscv64"

    installed_version() {
        if [ ! -x "$target" ]; then
            return 0
        fi

        "$target" --version 2>/dev/null |
            sed -n 's/^lark-cli version //p' |
            sed -n '1p'
    }

    extract_binary() {
        archive=$1
        destination=$2

        tar -xzf "$archive" -C "$destination" "$binary_name"
    }

    version=$(github_latest_version "$repo")
    [ -n "$version" ] || fail "failed to resolve latest GitHub release"

    current=$(installed_version)
    if [ "$current" = "$version" ]; then
        log "already latest ($version)"
        exit 0
    fi

    asset="$binary_name-$version-$os_name-$arch_name.$extension"
    base_url="https://github.com/$repo/releases/download/v$version"
    tmp_dir=$(make_tmp_dir)
    archive="$tmp_dir/$asset"
    checksums="$tmp_dir/checksums.txt"
    extract_dir="$tmp_dir/extract"

    cleanup() {
        cleanup_tmp_dir "$tmp_dir"
    }
    trap cleanup EXIT HUP INT TERM

    mkdir -p "$extract_dir"
    curl -fsSL "$base_url/$asset" -o "$archive"
    curl -fsSL "$base_url/checksums.txt" -o "$checksums"

    expected=$(checksum_for "$checksums" "$asset")
    [ -n "$expected" ] || fail "checksum not found for $asset"
    verify_sha256 "$archive" "$expected"

    extract_binary "$archive" "$extract_dir"

    installed_binary="$extract_dir/$binary_name"
    [ -f "$installed_binary" ] || fail "extracted binary not found"
    chmod +x "$installed_binary" 2>/dev/null || true
    "$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

    install_binary "$installed_binary" "$target"
    log "installed $version to $target"
)
