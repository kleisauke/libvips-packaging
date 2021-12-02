FROM arm64v8/centos:7
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create CentOS 7 (glibc 2.17) container suitable for building Linux ARM64v8-A binaries

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:/opt/rh/devtoolset-10/root/usr/bin:$PATH"

# Build dependencies
RUN \
  yum update -y && \
  yum install -y epel-release centos-release-scl && \
  yum group install -y "Development Tools" && \
  yum install -y --setopt=tsflags=nodocs \
    advancecomp \
    cmake3 \
    devtoolset-10-gcc \
    devtoolset-10-gcc-c++ \
    glib2-devel \
    gobject-introspection-devel \
    gperf \
    gtk-doc \
    jq \
    nasm \
    prelink \
    python3 && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    --default-toolchain nightly && \
  rustup component add rust-src && \
  rustup target add aarch64-unknown-linux-gnu && \
  ln -s /usr/bin/cmake3 /usr/bin/cmake && \
  pip3 install --upgrade pip && \
  pip3 install meson ninja

# Rebuild the standard library of Rust to avoid collisions with system libraries.
# See: https://github.com/lovell/sharp-libvips/issues/109
RUN \
  printf "[unstable]\n\
build-std = [\"std\", \"panic_abort\"]\n\
build-std-features = [\"panic_immediate_abort\", \"compiler-builtins-c\"]\n\
[env]\n\
RUST_COMPILER_RT_ROOT = \"/root/compiler-rt\"" > $CARGO_HOME/config.toml

# `c` feature of the `compiler-builtins` crate needs the compiler-rt sources from LLVM
RUN \
  curl -Ls https://github.com/rust-lang/llvm-project/archive/rustc/13.0-2021-09-30.tar.gz | \
    tar -xzC /root --strip-components 1 llvm-project-rustc-13.0-2021-09-30/compiler-rt

# Compiler settings
ENV \
  PLATFORM="linux-arm64" \
  CARGO_BUILD_TARGET="aarch64-unknown-linux-gnu" \
  FLAGS="-march=armv8-a" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
