#!/usr/bin/env bash

set -e

echo "WARNING: The $(basename "$0") script is deprecated." >&2
echo "WARNING: Please run 'boostrap-build-linux.sh' in the future." >&2
echo "WARNING: For now, $(basename "$0") will just call the new script." >&2
echo "" >&2

exec "$(dirname "$0")"/bootstrap-build-linux.sh
