#!/usr/bin/env bash

VERSION="${VERSION:-"latest"}"

set -e

# clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "$(uname -s)" != "Linux" ] ; then
    echo "(!) OS $(uname -s) unsupported."
    exit 1
fi

architecture="$(uname -m)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "x86_64" ] && [ "${architecture}" != "arm64" ] && [ "${architecture}" != "aarch64" ]; then
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

# checks if apt-get update is needed, and runs it if so
apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# install dependencies
check_packages curl ca-certificates tar jq

# fetch latest version of mockery if needed
if [ "${VERSION}" = "latest" ] || [ "${VERSION}" = "lts" ]; then
    tag=$(curl -s https://api.github.com/repos/vektra/mockery/releases/latest | jq -r .tag_name)
    export VERSION="${tag:1}"
fi

if ! mockery --version &> /dev/null ; then
    echo "Installing mockery v${VERSION}..."

    if [ "${architecture}" == "arm64" ] || [ "${architecture}" == "aarch64" ]; then
        arch="arm64"
    else
        arch="x86_64"
    fi

    tar_file="mockery_${VERSION}_Linux_${arch}.tar.gz"
    checksum_file="checksum.txt"

    curl -fsSLO --compressed "https://github.com/vektra/mockery/releases/download/v${VERSION}/${tar_file}"
    curl -fsSLO "https://github.com/vektra/mockery/releases/download/v${VERSION}/${checksum_file}"

    actual_checksum=$(sha256sum "${tar_file}" | awk '{ print $1 }')
    stored_checksum=$(grep "${tar_file}" "${checksum_file}" | awk '{ print $1 }')

    if [ "${actual_checksum}" != "${stored_checksum}" ]; then
        echo "(!) The tarball is NOT valid."
        exit 1
    fi

    tar -xzf "${tar_file}"
    mv mockery /usr/local/bin/mockery
    rm -rf "${tar_file}" "${checksum_file}"
else
    echo "mockery already installed"
fi

# clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"