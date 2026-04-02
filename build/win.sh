#!/usr/bin/env bash
set -e

## Copyright 2017 Lovell Fuller and others.
## SPDX-License-Identifier: Apache-2.0

# Dependency version numbers
source /packaging/versions.properties

VERSION_VIPS_SHORT=${VERSION_VIPS%.[[:digit:]]*}

# Common options for curl
CURL="curl --silent --location --retry 3 --retry-max-time 30"

# Fetch and unzip
mkdir /vips
cd /vips

VARIANT=static

case "${PLATFORM#*-}" in
  x64) ARCH=x64 ;;
  x64.net462)
    ARCH=x64
    VARIANT=static-ffi
    ;;
  x86) ARCH=x86 ;;
  x86.net462)
    ARCH=x86
    VARIANT=static-ffi
    ;;
  arm64) ARCH=arm64 ;;
  arm64.net481)
    ARCH=arm64
    VARIANT=static-ffi
    ;;
esac

FILENAME="vips-dev-${ARCH}-web-${VERSION_VIPS}-${VARIANT}.zip"
URL="https://github.com/libvips/build-win64-mxe/releases/download/v${VERSION_VIPS}/${FILENAME}"
echo "Downloading $URL"
$CURL -O $URL
unzip $FILENAME

cd /vips/vips-dev-${VERSION_VIPS_SHORT}

# Move DLLs to the lib directory
cp bin/*.dll lib/

# Add third-party notices
$CURL -O https://raw.githubusercontent.com/kleisauke/libvips-packaging/main/THIRD-PARTY-NOTICES.md

# Create tarball
tar czf /packaging/libvips-${VERSION_VIPS}-${PLATFORM}.tar.gz \
  include \
  lib/glib-2.0 \
  lib/*.{dll,lib} \
  versions.json \
  THIRD-PARTY-NOTICES.md

# Allow tarballs to be read outside container
chmod 644 /packaging/libvips-${VERSION_VIPS}-${PLATFORM}.tar.gz

# Remove working directories
rm -rf lib include versions.json THIRD-PARTY-NOTICES.md
