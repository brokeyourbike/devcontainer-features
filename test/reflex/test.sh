#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "help" reflex -h 2>&1 >/dev/null | grep 'Usage: reflex'

# Report result
reportResults