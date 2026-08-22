#!/bin/sh

set -eu

_tools_dir=${1:?tools source directory is required}
_home_dir=${2:?home directory is required}

tools_name="tencentcloud-cli"
. "$_tools_dir/functions.sh"

log "skip: upstream GitHub release does not publish standalone macOS/Linux binaries"
