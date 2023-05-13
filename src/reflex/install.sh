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

# compute the SHA256 hash of a file
compute_sha256() {
    FILE=$1
    if [ "$(uname)" = "Darwin" ]; then
        shasum -a 256 $FILE | awk '{ print $1 }'
    else
        sha256sum $FILE | awk '{ print $1 }'
    fi
}

# install dependencies
check_packages curl ca-certificates tar jq

# fetch latest version of reflex if needed
if [ "${VERSION}" = "latest" ] || [ "${VERSION}" = "lts" ]; then
    tag=$(curl -s --retry 3 https://api.github.com/repos/cespare/reflex/releases/latest | jq -r .tag_name)
    export VERSION="${tag:1}"
fi

if ! reflex -h 2>&1 >/dev/null | grep 'Usage: reflex' &> /dev/nul ; then
    echo "Installing reflex v${VERSION}..."

    if [ "${architecture}" == "arm64" ] || [ "${architecture}" == "aarch64" ]; then
        arch="arm64"
    else
        arch="amd64"
    fi

    TARFILE="reflex_${os}_${arch}.tar.gz"
    SHAFILE="${TARFILE}.sha256"

    curl -fsSLO --compressed "https://github.com/cespare/reflex/releases/download/v${VERSION}/${TARFILE}"
    curl -fsSLO "https://github.com/cespare/reflex/releases/download/v${VERSION}/${SHAFILE}"

    ACTUAL_SHA=$(compute_sha256 $TARFILE)
    EXPECTED_SHA=$(awk '{ print $1 }' $SHAFILE)

    if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
        echo "The tarball is NOT valid."
        exit 1
    fi

    tar -xzf "${TARFILE}"
    mv "reflex_${os}_${arch}/reflex" /usr/local/bin/reflex
    rm -rf "${TARFILE}" "${SHAFILE}" "reflex_${os}_${arch}"
else
    echo "reflex already installed"
fi

# clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"