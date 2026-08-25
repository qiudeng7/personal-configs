#!/bin/sh

set -eu

common_dir=${1:?common source directory is required}
home_dir=${2:?home directory is required}
shift 2

tools_name="tools/common"
. "$common_dir/functions.sh"

[ "$#" -gt 0 ] || fail "at least one tool name is required"

for requested_tool do
    installer="$common_dir/$requested_tool/install.sh"
    [ -f "$installer" ] || fail "installer not found for $requested_tool: $installer"
done

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
need_cmd unzip
need_any_cmd "sha256 checker" shasum sha256sum

user_bin_dir="$home_dir/.local/bin"
mkdir -p "$user_bin_dir"

case ${PATH-} in
    "$user_bin_dir"|"$user_bin_dir":*) ;;
    *) PATH="$user_bin_dir${PATH:+:$PATH}" ;;
esac

: "${PNPM_HOME:=$user_bin_dir}"
: "${UV_TOOL_BIN_DIR:=$user_bin_dir}"
export PATH PNPM_HOME UV_TOOL_BIN_DIR

for requested_tool do
    installer="$common_dir/$requested_tool/install.sh"
    log "$requested_tool"
    sh "$installer" "$common_dir" "$home_dir"
done
