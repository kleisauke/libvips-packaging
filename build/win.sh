#!/usr/bin/env bash
set -e

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
  x64) ARCH=w64 ;;
  x64.net462)
    ARCH=w64
    VARIANT=static-ffi
    ;;
  x86) ARCH=w32 ;;
  x86.net462)
    ARCH=w32
    VARIANT=static-ffi
    ;;
  arm64) ARCH=arm64 ;;
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
