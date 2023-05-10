#!/usr/bin/env bash

VERSION="${VERSION:-"latest"}"

set -e

# clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

architecture="$(uname -m)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "arm64" ]; then
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# install dependencies
check_packages curl ca-certificates tar

# fetch latest version of reflex if needed
if [ "${VERSION}" = "latest" ] || [ "${VERSION}" = "lts" ]; then
    export VERSION=$(curl -s https://api.github.com/repos/cespare/reflex/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
fi

echo "Installing reflex..."

curl -fsSLO --compressed "https://github.com/cespare/reflex/releases/download/v${VERSION}/reflex_linux_${architecture}.tar.gz"
tar -xzf "reflex_linux_${architecture}.tar.gz"
mv "reflex_linux_${architecture}/reflex" /usr/local/bin/reflex
rm -rf "reflex_linux_${architecture}.tar.gz" "reflex_linux_${architecture}"

# clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"