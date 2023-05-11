#!/usr/bin/env bash

VERSION="${VERSION:-"latest"}"

set -e

# clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

os=$(uname -s)
if [ "${os}" != "Linux" ] && [ "${os}" != "Darwin" ] ; then
    echo "(!) OS ${os} unsupported"
    exit 1
fi

architecture="$(uname -m)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "x86_64" ] && [ "${architecture}" != "arm64" ] && [ "${architecture}" != "aarch64" ]; then
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

# fetch latest version of mockery if needed
if [ "${VERSION}" = "latest" ] || [ "${VERSION}" = "lts" ]; then
    export VERSION=$(curl -s https://api.github.com/repos/vektra/mockery/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
fi

if ! mockery --version &> /dev/null ; then
    echo "Installing mockery v${VERSION}..."

    if [ "${architecture}" == "arm64" ] || [ "${architecture}" == "aarch64" ]; then
        arch="arm64"
    else
        arch="x86_64"
    fi

    url="https://github.com/vektra/mockery/releases/download/v${VERSION}/mockery_${VERSION}_${os}_${arch}.tar.gz"
    echo "Downloading from: ${url}"

    curl -fsSLO --compressed "${url}"
    tar -xzf "mockery_${VERSION}_${os}_${arch}.tar.gz"
    mv mockery /usr/local/bin/mockery
    rm -rf "mockery_${VERSION}_${os}_${arch}.tar.gz"
else
    echo "mockery already installed"
fi

# clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"