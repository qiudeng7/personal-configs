# Ubuntu installer for pnpm and pnpm-managed global tools.
# Depends on tools/functions.sh and home_dir from tools/ubuntu/install.sh.

install_pnpm() (
    set -eu

    tools_name="pnpm"
    repo="pnpm/pnpm"
    binary_name="pnpm"
    install_dir=${PNPM_INSTALL_DIR:-"$home_dir/.local/bin"}
    store_dir=${PNPM_STORE_DIR:-"$home_dir/.local/share/tools/pnpm"}
    target="$install_dir/$binary_name"
    arch_name=$(detect_arch)

    case "$arch_name" in
        amd64) asset_arch="x64" ;;
        arm64) asset_arch="arm64" ;;
        *) fail "unsupported architecture: $arch_name" ;;
    esac

    asset="pnpm-linux-$asset_arch.tar.gz"

    installed_version() {
        [ -x "$target" ] || return 0
        "$target" --version 2>/dev/null | sed -n '1p'
    }

    install_pnpm_package() {
        package=$1
        global_bin_dir=$("$target" bin -g)
        command_path="$global_bin_dir/$package"

        before=""
        if [ -x "$command_path" ]; then
            before=$("$command_path" --version 2>/dev/null | sed -n '1p' || true)
        fi

        "$target" add -g "$package"

        [ -x "$command_path" ] || fail "$package installation did not produce an executable"
        after=$("$command_path" --version 2>/dev/null | sed -n '1p' || true)
        [ -n "$after" ] || fail "$package installation did not produce a working executable"

        if [ "$before" = "$after" ]; then
            log "$package already latest ($after)"
        else
            log "$package installed $after"
        fi
    }

    version=$(github_latest_version "$repo")
    [ -n "$version" ] || fail "failed to resolve latest GitHub release"

    current=$(installed_version)
    if [ "$current" = "$version" ]; then
        log "already latest ($version)"
    else
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
        tar -xzf "$archive" -C "$extract_dir"

        installed_binary="$extract_dir/$binary_name"
        [ -f "$installed_binary" ] || fail "extracted binary not found"
        chmod +x "$installed_binary" 2>/dev/null || true
        "$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

        rm -R "$store_dir" 2>/dev/null || true
        mkdir -p "$store_dir"
        mv "$extract_dir/$binary_name" "$store_dir/$binary_name"
        mv "$extract_dir/dist" "$store_dir/dist"
        write_exec_wrapper "$target" "$store_dir/$binary_name"
        log "installed $version to $target"
    fi

    for package in wrangler; do
        install_pnpm_package "$package"
    done
)
