# Ubuntu installer for infisical.
# Depends on tools/functions.sh and home_dir from tools/ubuntu/install.sh.

install_infisical() (
    set -eu

    tools_name="infisical"
    repo="Infisical/cli"
    binary_name="infisical"
    install_dir=${INFISICAL_INSTALL_DIR:-"$home_dir/.local/bin"}
    target="$install_dir/$binary_name"
    os_name="linux"
    arch_name=$(detect_arch)

    [ "$arch_name" != "riscv64" ] || fail "unsupported architecture: riscv64"

    installed_version() {
        [ -x "$target" ] || return 0
        "$target" --version 2>/dev/null |
            sed -n 's/^infisical version //p' |
            sed -n '1p'
    }

    version=$(github_latest_version "$repo")
    [ -n "$version" ] || fail "failed to resolve latest GitHub release"

    current=$(installed_version)
    if [ "$current" = "$version" ]; then
        log "already latest ($version)"
        exit 0
    fi

    asset="cli_${version}_${os_name}_${arch_name}.tar.gz"
    checksums_asset="checksums.txt"
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

    tar -xzf "$archive" -C "$extract_dir"
    installed_binary="$extract_dir/$binary_name"
    [ -f "$installed_binary" ] || fail "extracted binary not found"
    chmod +x "$installed_binary" 2>/dev/null || true
    "$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

    install_binary "$installed_binary" "$target"
    log "installed $version to $target"
)
