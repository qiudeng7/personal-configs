#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

tools_name="tencentcloud-cli"
. "$_tools_dir/functions.sh"

uv_bin="$home_dir/.local/bin/uv"
if [ ! -x "$uv_bin" ]; then
    if command -v uv >/dev/null 2>&1; then
        uv_bin=$(command -v uv)
    else
        fail "uv is required before installing tccli"
    fi
fi

tool_bin_dir="$home_dir/.local/bin"
tool_dir="$home_dir/.local/share/tools/uv"
target="$tool_bin_dir/tccli"

installed_version() {
    [ -x "$target" ] || return 0
    "$target" --version 2>/dev/null | sed -n '1p'
}

before=$(installed_version)

UV_TOOL_BIN_DIR="$tool_bin_dir" \
UV_TOOL_DIR="$tool_dir" \
    "$uv_bin" tool install --upgrade tccli

after=$(installed_version)
[ -n "$after" ] || fail "tccli installation did not produce a working executable"

if [ "$before" = "$after" ]; then
    log "already latest ($after)"
else
    log "installed $after to $target"
fi
