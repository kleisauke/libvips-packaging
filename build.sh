#!/usr/bin/env bash
set -e

if [ $# -lt 1 ]; then
  echo
  echo "Usage: $0 VERSION [PLATFORM]"
  echo "Build shared libraries for libvips and its dependencies via containers"
  echo
  echo "Please specify the libvips VERSION, e.g. 8.8.1"
  echo
  echo "Optionally build for only one PLATFORM, defaults to building for all"
  echo
  echo "Possible values for PLATFORM are:"
  echo "- win-x64"
  echo "- win-x86"
  echo "- linux-x64"
  echo "- linux-musl-x64"
  echo
  exit 1
fi

version_vips="$1"
version_vips_major=$(echo $version_vips | cut -d. -f1)
version_vips_minor=$(echo $version_vips | cut -d. -f2)
platform="${2:-all}"

# Is docker available?
if ! type docker >/dev/null; then
  echo "Please install docker"
  exit 1
fi

# Update base images
for baseimage in centos:7 debian:stretch alpine:3.10; do
  docker pull $baseimage
done

# Windows (x64 and x86)
for flavour in win-x64 win-x86; do
  if [ $platform = "all" ] || [ $platform = $flavour ]; then
    case "${flavour#*-}" in
      x64) arch="x86_64" ;;
      x86) arch="i686" ;;
    esac

    echo "Building $flavour..."
    cd build-win64-mxe
    . build.sh $version_vips_major.$version_vips_minor web $arch static

    cd ../
    echo "Packaging $flavour..."
    docker build -t vips-dev-win32 win32
    docker run --rm -e "VERSION_VIPS=${version_vips}" -e "PLATFORM=${flavour}" -v $PWD:/packaging vips-dev-win32 sh -c "/packaging/build/win.sh"
  fi
done

# Linux (x64)
for flavour in linux-x64 linux-musl-x64; do
  if [ $platform = "all" ] || [ $platform = $flavour ]; then
    echo "Building $flavour..."
    docker build -t vips-dev-$flavour $flavour
    docker run --rm -e "VERSION_VIPS=${version_vips}" -v $PWD:/packaging vips-dev-$flavour sh -c "/packaging/build/lin.sh"
  fi
done

# Display checksums
sha256sum *.tar.gz
