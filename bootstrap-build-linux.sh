#!/usr/bin/env bash

# Boostraps and builds an up-to-date musl-based statically linked toolchain
# targetting Linux systems.

# Only x86_64 and aarch64 architectures have currently been tested, and
# cross-compilation is (currently) unsupported; you must build from the same
# architecture you intend to deploy for.

# Exit on error.
set -e

# Ensure config.mak.default exists.
if [ ! -e config.mak.bootstrap-build-linux ]; then
  echo "Error: config.mak.bootstrap-build-linux does not exist." >&2
  exit 1
fi

# Detect architeture.
export ARCH="$(uname -m)"
echo -e "--> Building toolchain for '$ARCH-linux-musl'.\n"

# Create a temporary directory for storing the bootstrap toolchain.
tooldir="$(mktemp -d)"

# Download the bootstrap toolchain.
curl -L https://musl.cc/"$ARCH"-linux-musl-native.tgz -o "${tooldir}"/bstrap.tgz

# Extract the bootstrap toolchain.
tar -xf "${tooldir}"/bstrap.tgz -C "${tooldir}" --strip-components=1

# Add toolchain bin directory to PATH.
export PATH="${PATH}:${tooldir}/bin"

# Cleanup first.
make -j1 distclean
rm -rf "$ARCH"-linux-musl-toolchain
rm -f config.mak

# Copy config.mak.bootstrap-build-linux to config.mak, editing as necessary.
sed "s|%ARCH%|$ARCH|g" config.mak.bootstrap-build-linux > config.mak

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
mv output "$ARCH"-linux-musl-toolchain
tar -cJvf "$ARCH"-linux-musl-toolchain.tar.xz "$ARCH"-linux-musl-toolchain

# Clean up.
make -j1 distclean
rm -rf "$ARCH"-linux-musl-toolchain
rm -f config.mak

# Final message.
echo -e "\n--> Done. Output tarball is '$ARCH-linux-musl-toolchain.tar.xz'."
