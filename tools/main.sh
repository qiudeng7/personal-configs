#!/bin/sh

set -eu

tools_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

case "$(uname -s)" in
    Darwin)
        system_name=macos
        ;;
    Linux)
        if [ ! -r /etc/os-release ]; then
            echo "tools: cannot detect Linux distribution" >&2
            exit 1
        fi

        . /etc/os-release
        case "$ID" in
            arch) system_name=arch ;;
            ubuntu) system_name=ubuntu ;;
            *)
                echo "tools: unsupported Linux distribution: $ID" >&2
                exit 1
                ;;
        esac
        ;;
    *)
        echo "tools: unsupported system: $(uname -s)" >&2
        exit 1
        ;;
esac

installer="$tools_dir/$system_name/install.sh"
if [ ! -f "$installer" ]; then
    echo "tools: installer not found: $installer" >&2
    exit 1
fi

echo "tools: installing $system_name toolset"
sh "$installer" "$tools_dir"
