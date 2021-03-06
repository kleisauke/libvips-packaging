FROM alpine:3.11
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create Alpine 3.11 (musl 1.1.24) container suitable for cross-compiling musl-based Linux ARM64v8-A binaries

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:$PATH"

# Build dependencies
RUN \
  apk update && apk upgrade && \
  apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    build-base \
    cmake \
    curl \
    findutils \
    git \
    glib-dev \
    gobject-introspection-dev \
    gperf \
    gtk-doc \
    intltool \
    jq \
    libtool \
    linux-headers \
    nasm \
    ninja \
    python3 \
    py3-pip \
    shared-mime-info \
    texinfo && \
  apk --update --no-cache --repository https://alpine.global.ssl.fastly.net/alpine/edge/community/ add advancecomp && \
  curl -Ls https://github.com/lovell/aarch64-linux-musl-crosstools/archive/main.tar.gz | tar -hxzC / --strip-components=2 && \
  ln -s /usr/bin/pkg-config /bin/aarch64-linux-musl-pkg-config && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    --default-toolchain nightly && \
  rustup component add rust-src && \
  rustup target add aarch64-unknown-linux-musl && \
  pip3 install meson

# Rebuild the standard library of Rust to avoid collisions with system libraries.
# See: https://github.com/lovell/sharp-libvips/pull/73#issuecomment-783403636
RUN \
  printf "[unstable]\n\
build-std = [\"std\", \"panic_abort\"]\n\
build-std-features = [\"panic_immediate_abort\"]" > /usr/local/cargo/config.toml

# Compiler settings
ENV \
  PKG_CONFIG="/bin/aarch64-linux-musl-pkg-config" \
  PLATFORM="linux-musl-arm64" \
  CHOST="aarch64-linux-musl" \
  RUST_TARGET="aarch64-unknown-linux-musl" \
  FLAGS="-march=armv8-a" \
  MESON="--cross-file=/root/meson.ini"

# Musl defaults to static libs but we need them to be dynamic for host toolchain.
# The toolchain will produce static libs by default.
# We also need to add the directory containing libc.a to the library search path.
ENV \
  RUSTFLAGS="-C target-feature=-crt-static -L/aarch64-linux-musl/lib"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
