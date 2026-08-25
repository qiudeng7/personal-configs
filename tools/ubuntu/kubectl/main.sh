# Ubuntu installer for kubectl.
# Depends on tools/functions.sh and home_dir from tools/ubuntu/install.sh.

install_kubectl() (
    set -eu

    tools_name="kubectl"
    binary_name="kubectl"
    install_dir=${KUBECTL_INSTALL_DIR:-"$home_dir/.local/bin"}
    target="$install_dir/$binary_name"
    os_name="linux"
    arch_name=$(detect_arch)

    [ "$arch_name" != "riscv64" ] || fail "unsupported architecture: riscv64"

    installed_version() {
        [ -x "$target" ] || return 0
        "$target" version --client=true 2>/dev/null |
            sed -n 's/^Client Version: v\([^[:space:]]*\).*/\1/p' |
            sed -n '1p'
    }

    version=$(curl -fsSL https://dl.k8s.io/release/stable.txt | sed 's/^v//')
    [ -n "$version" ] || fail "failed to resolve latest Kubernetes release"

    current=$(installed_version)
    if [ "$current" = "$version" ]; then
        log "already latest ($version)"
        exit 0
    fi

    base_url="https://dl.k8s.io/release/v$version/bin/$os_name/$arch_name"
    tmp_dir=$(make_tmp_dir)
    download="$tmp_dir/$binary_name"
    checksum="$tmp_dir/$binary_name.sha256"

    cleanup() {
        cleanup_tmp_dir "$tmp_dir"
    }
    trap cleanup EXIT HUP INT TERM

    curl -fsSL "$base_url/$binary_name" -o "$download"
    curl -fsSL "$base_url/$binary_name.sha256" -o "$checksum"

    expected=$(sed 's/[[:space:]].*//' "$checksum" | sed -n '1p')
    [ -n "$expected" ] || fail "checksum not found for $binary_name"
    verify_sha256 "$download" "$expected"

    chmod +x "$download" 2>/dev/null || true
    "$download" version --client=true >/dev/null 2>&1 || fail "downloaded binary failed version check"

    install_binary "$download" "$target"
    log "installed $version to $target"
)
