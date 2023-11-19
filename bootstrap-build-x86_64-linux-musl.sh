#!/usr/bin/env bash

# Boostraps and builds an x86_64-linux-musl toolchain using config.mak.default.

# Exit on error.
set -e

# Ensure we are running on an x86_64 host (todo: cross-compilation?).
if [ "$(uname -m)" != "x86_64" ]; then
  echo "Error: This script must be run on an x86_64 host system." >&2
  exit 1
fi

# Ensure config.mak.default exists.
if [ ! -e config.mak.default ]; then
  echo "Error: config.mak.default does not exist." >&2
  exit 1
fi

# Create a temporary directory for storing the bootstrap toolchain.
tooldir="$(mktemp -d)"

# Download the bootstrap toolchain.
curl -L https://musl.cc/x86_64-linux-musl-native.tgz -o "${tooldir}"/bstrap.tgz

# Extract the bootstrap toolchain.
tar -xf "${tooldir}"/bstrap.tgz -C "${tooldir}" --strip-components=1

# Add toolchain bin directory to PATH.
export PATH="${PATH}:${tooldir}/bin"

# Cleanup first.
make -j1 distclean
rm -rf x86_64-linux-musl-toolchain

# Copy config.mak.default to config.mak.
cp -f config.mak.default config.mak

# Start the bootstrap build.
make -j$(nproc)

# Install the bootstrap build.
make -j1 install

# Overwrite the temporary toolchain with the new build.
cp -af output/* "${tooldir}"
rm -rf output

# Clean up the stage 1 build.
make -j1 distclean

# Start the final build.
make -j$(nproc)

# Install the final build.
make -j1 install

# Package the tarball.
mv output x86_64-linux-musl-toolchain
tar -cJvf x86_64-linux-musl-toolchain.tar.xz x86_64-linux-musl-toolchain

# Clean up.
make -j1 distclean
rm -rf x86_64-linux-musl-toolchain
rm -f config.mak

# Final message.
echo -e "\nDone. Output tarball is 'x86_64-linux-musl-toolchain.tar.xz'."
