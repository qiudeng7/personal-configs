#!/bin/sh

# Preparation stage for the Ubuntu toolset.
# Docker packages in install.sh depend on Docker's apt source and signing key.
# ca-certificates and curl must exist before that repository can be configured.

set -eu

if ! command -v apt-get >/dev/null 2>&1; then
    echo "tools: apt-get is required on Ubuntu" >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y ca-certificates curl

for conflicting_package in \
    docker.io \
    docker-compose \
    docker-compose-v2 \
    docker-doc \
    docker-buildx \
    podman-docker \
    containerd \
    runc
do
    if dpkg-query -W -f='${Status}' "$conflicting_package" 2>/dev/null |
        grep -q '^install ok installed$'
    then
        sudo apt-get remove -y "$conflicting_package"
    fi
done

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
docker_suite=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
if [ -z "$docker_suite" ]; then
    echo "tools: cannot determine Ubuntu codename for Docker repository" >&2
    exit 1
fi

docker_arch=$(dpkg --print-architecture)
{
    printf '%s\n' \
        'Types: deb' \
        'URIs: https://download.docker.com/linux/ubuntu' \
        "Suites: $docker_suite" \
        'Components: stable' \
        "Architectures: $docker_arch" \
        'Signed-By: /etc/apt/keyrings/docker.asc'
} | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null

sudo apt-get update
