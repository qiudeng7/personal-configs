# Ubuntu installer for fnm.
# Depends on tools/functions.sh and home_dir from tools/ubuntu/install.sh.

install_fnm() (
    set -eu

    tools_name="fnm"
    repo="Schniz/fnm"
    binary_name="fnm"
    install_dir=${FNM_INSTALL_DIR:-"$home_dir/.local/bin"}
    target="$install_dir/$binary_name"
    arch_name=$(detect_arch)

    [ "$arch_name" = "amd64" ] || fail "unsupported linux architecture: $arch_name"
    asset="fnm-linux.zip"

    installed_version() {
        [ -x "$target" ] || return 0
        "$target" --version 2>/dev/null |
            sed -n 's/^fnm //p' |
            sed -n '1p'
    }

    version=$(github_latest_version "$repo")
    [ -n "$version" ] || fail "failed to resolve latest GitHub release"

    current=$(installed_version)
    if [ "$current" = "$version" ]; then
        log "already latest ($version)"
        exit 0
    fi

    base_url="https://github.com/$repo/releases/download/v$version"
    tmp_dir=$(make_tmp_dir)
    archive="$tmp_dir/$asset"
    extract_dir="$tmp_dir/extract"

    cleanup() {
        cleanup_tmp_dir "$tmp_dir"
    }
    trap cleanup EXIT HUP INT TERM

    mkdir -p "$extract_dir"
    curl -fsSL "$base_url/$asset" -o "$archive"
    unzip -q "$archive" -d "$extract_dir"

    installed_binary="$extract_dir/$binary_name"
    [ -f "$installed_binary" ] || fail "extracted binary not found"
    chmod +x "$installed_binary" 2>/dev/null || true
    "$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

    install_binary "$installed_binary" "$target"
    log "installed $version to $target"
)
