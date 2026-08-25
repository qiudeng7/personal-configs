# Arch Linux installer for aliyun-cli.
# Depends on tools/functions.sh and home_dir from tools/arch/install.sh.

install_aliyun_cli() (
    set -eu

    tools_name="aliyun-cli"
    repo="aliyun/aliyun-cli"
    binary_name="aliyun"
    install_dir=${ALIYUN_CLI_INSTALL_DIR:-"$home_dir/.local/bin"}
    target="$install_dir/$binary_name"
    platform="linux"
    arch_name="amd64"

    installed_version() {
        [ -x "$target" ] || return 0
        "$target" version 2>/dev/null | sed -n '1p'
    }

    version=$(github_latest_version "$repo")
    [ -n "$version" ] || fail "failed to resolve latest GitHub release"

    current=$(installed_version)
    if [ "$current" = "$version" ]; then
        log "already latest ($version)"
        exit 0
    fi

    asset="aliyun-cli-$platform-$version-$arch_name.tgz"
    checksums_asset="SHASUMS256.txt"
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
    "$installed_binary" version >/dev/null 2>&1 || fail "downloaded binary failed version check"

    install_binary "$installed_binary" "$target"
    log "installed $version to $target"
)
