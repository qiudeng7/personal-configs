tools_name=${tools_name:-tools}

log() {
    echo "$tools_name: $*"
}

fail() {
    echo "$tools_name: $*" >&2
    exit 1
}

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        fail "missing required command: $1"
    fi
}

need_any_cmd() {
    label=$1
    shift

    for candidate in "$@"; do
        if command -v "$candidate" >/dev/null 2>&1; then
            return 0
        fi
    done

    fail "missing required command group: $label ($*)"
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

github_latest_version() {
    repo=$1

    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
        sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' |
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

    grep "[[:space:]]\\*\\{0,1\\}$asset\$" "$checksums" |
        sed 's/[[:space:]].*//' |
        sed -n '1p'
}

make_tmp_dir() {
    mktemp -d "${TMPDIR:-/tmp}/tools-$tools_name.XXXXXX"
}

cleanup_tmp_dir() {
    tmp_dir=$1

    [ -n "$tmp_dir" ] || return 0
    [ -d "$tmp_dir" ] || return 0

    rm -R "$tmp_dir" 2>/dev/null || true
}

install_binary() {
    source_file=$1
    target_file=$2

    mkdir -p "${target_file%/*}"
    mv "$source_file" "$target_file"
    chmod +x "$target_file" 2>/dev/null || true
}
