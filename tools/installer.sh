#!/bin/sh

set -eu

tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "tools: missing required command: $1" >&2
        return 1
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

    echo "tools: missing required command group: $label ($*)" >&2
    return 1
}

need_cmd sh
need_cmd uname
need_cmd curl
need_cmd sed
need_cmd grep
need_cmd mktemp
need_cmd chmod
need_cmd mkdir
need_cmd mv
need_cmd rm
need_cmd rmdir
need_cmd tar
need_any_cmd "sha256 checker" shasum sha256sum

echo "tools: installing/updating managed tools"

for tool_dir in "$tools_dir"/*; do
    [ -d "$tool_dir" ] || continue
    [ -f "$tool_dir/install.sh" ] || continue

    tool_name=${tool_dir##*/}
    echo "tools: $tool_name"
    sh "$tool_dir/install.sh" "$tools_dir" "$home_dir"
done

echo "tools: done"
