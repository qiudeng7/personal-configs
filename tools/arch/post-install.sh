#!/bin/sh

# Post-install stage for Docker on Arch Linux.
# Depends on docker and containerd being installed by install.sh.
# Group membership is refreshed only after the user logs out and back in.

set -eu

docker_user=${1:?Docker user is required}

if ! id "$docker_user" >/dev/null 2>&1; then
    echo "tools: Docker user does not exist: $docker_user" >&2
    exit 1
fi

if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
fi

sudo usermod -aG docker "$docker_user"
sudo systemctl enable --now docker.service containerd.service

echo "tools: $docker_user was added to the docker group; log out and back in to apply it"
