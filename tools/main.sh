#!/bin/sh

set -eu

tools_dir=${1:?tools source directory is required}
home_dir=${2:?home directory is required}

. "$tools_dir/functions.sh"

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

echo "tools: installing/updating managed tools"

for tool_dir in "$tools_dir"/*; do
    [ -d "$tool_dir" ] || continue
    [ -f "$tool_dir/install.sh" ] || continue

    tool_name=${tool_dir##*/}
    [ "$tool_name" = "functions.sh" ] && continue
    echo "tools: $tool_name"
    sh "$tool_dir/install.sh" "$tools_dir" "$home_dir"
done

echo "tools: done"
