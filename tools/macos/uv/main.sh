# macOS installer for uv and uv-managed tools.
# Depends on tools/functions.sh, home_dir, and system_dir from tools/macos/install.sh.

install_uv() (
    set -eu

    tools_name="uv"
    repo="astral-sh/uv"
    binary_name="uv"
    install_dir=${UV_INSTALL_DIR:-"$home_dir/.local/bin"}
    target="$install_dir/$binary_name"
    arch_name=$(detect_arch)

    case "$arch_name" in
        arm64) target_triple="aarch64-apple-darwin" ;;
        amd64) target_triple="x86_64-apple-darwin" ;;
        *) fail "unsupported architecture: $arch_name" ;;
    esac

    installed_version() {
        [ -x "$target" ] || return 0
        "$target" --version 2>/dev/null |
            sed -n 's/^uv \([^[:space:]]*\).*/\1/p' |
            sed -n '1p'
    }

    install_uv_tool() {
        package=$1

        before=""
        if command -v "$package" >/dev/null 2>&1; then
            before=$("$package" --version 2>/dev/null | sed -n '1p' || true)
        fi

        "$target" tool install --upgrade "$package"

        command -v "$package" >/dev/null 2>&1 || fail "$package installation did not produce an executable"
        after=$("$package" --version 2>/dev/null | sed -n '1p' || true)
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
        asset="uv-$target_triple.tar.gz"
        checksum_asset="$asset.sha256"
        base_url="https://github.com/$repo/releases/download/$version"
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

        expected=$(sed 's/[[:space:]].*//' "$checksum" | sed -n '1p')
        [ -n "$expected" ] || fail "checksum not found for $asset"
        verify_sha256 "$archive" "$expected"

        tar -xzf "$archive" -C "$extract_dir"
        installed_binary="$extract_dir/uv-$target_triple/$binary_name"
        [ -f "$installed_binary" ] || fail "extracted binary not found"
        chmod +x "$installed_binary" 2>/dev/null || true
        "$installed_binary" --version >/dev/null 2>&1 || fail "downloaded binary failed version check"

        install_binary "$installed_binary" "$target"
        log "installed $version to $target"
    fi

    list_file="$system_dir/uv/list.txt"
    [ -f "$list_file" ] || exit 0

    while IFS= read -r package || [ -n "$package" ]; do
        case "$package" in
            ""|\#*) continue ;;
        esac
        install_uv_tool "$package"
    done <"$list_file"
)
