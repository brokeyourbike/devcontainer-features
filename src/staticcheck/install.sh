#!/usr/bin/env bash

VERSION="${VERSION:-"latest"}"

set -e

# clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

os=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "${os}" != "linux" ] && [ "${os}" != "darwin" ] ; then
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

# fetch latest version of staticcheck if needed
if [ "${VERSION}" = "latest" ] || [ "${VERSION}" = "lts" ]; then
    export VERSION=$(curl -s https://api.github.com/repos/dominikh/go-tools/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
fi

if ! staticcheck -version &> /dev/null ; then
    echo "Installing staticcheck v${VERSION}..."

    if [ "${architecture}" == "arm64" ] || [ "${architecture}" == "aarch64" ]; then
        arch="arm64"
    else
        arch="amd64"
    fi

    curl -fsSLO --compressed "https://github.com/dominikh/go-tools/releases/download/${VERSION}/staticcheck_${os}_${arch}.tar.gz"
    tar -xzf "staticcheck_${os}_${arch}.tar.gz"
    mv staticcheck/staticcheck /usr/local/bin/staticcheck
    rm -rf "staticcheck_${os}_${arch}.tar.gz" staticcheck
else
    echo "staticcheck already installed"
fi

# clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"