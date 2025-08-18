# Packaging scripts

libvips and its dependencies are provided as pre-compiled shared libraries
for the most common operating systems and CPU architectures.

## Used by NetVips and pyvips

These are packaged[^1][^2] and published to both [NuGet](
https://www.nuget.org/packages/NetVips.Native) and [PyPI](
https://pypi.org/project/pyvips-binary/).

The version number of these packages is in sync with libvips' version number.

## Creating a tarball

Most people will not need to do this; proceed with caution.

Run the top-level [build script](build.sh) without parameters for help.

### Linux

One [build script](build/posix.sh) is used to (cross-)compile
the same shared libraries within multiple containers.

* [x64 glibc](platforms/linux-x64/Dockerfile)
* [x64 musl](platforms/linux-musl-x64/Dockerfile)
* [ARMv7-A glibc](platforms/linux-arm/Dockerfile)
* [ARM64v8-A glibc](platforms/linux-arm64/Dockerfile)
* [ARM64v8-A musl](platforms/linux-musl-arm64/Dockerfile)

### Windows

The output of libvips' [build-win64-mxe](https://github.com/libvips/build-win64-mxe)
static "web" releases are [post-processed](build/win.sh) within a [container](platforms/win32/Dockerfile).

### macOS

Uses a macOS virtual machine hosted by GitHub to compile the shared libraries.
The dylib files are compiled within the same build script as Linux.

* x64
* ARM64

Dependency paths are modified to use the relative `@loader_path` with `install_name_tool`.

## Licences

These scripts are licensed under the terms of the [Apache 2.0 Licence](LICENSE).

The shared libraries contained in the tarballs are distributed under
the terms of [various licences](THIRD-PARTY-NOTICES.md), all of which
are compatible with the Apache 2.0 Licence.

[^1]: https://github.com/kleisauke/net-vips/blob/master/build/Build.cs
[^2]: https://github.com/kleisauke/pyvips-binary/blob/main/.github/workflows/ci.yml
