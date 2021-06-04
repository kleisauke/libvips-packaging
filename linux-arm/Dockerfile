FROM centos:7
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create CentOS 7 container suitable for cross-compiling Linux ARMv7-A binaries

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:/x-tools/armv7-unknown-linux-gnueabihf/bin:$PATH"

# Build dependencies
RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum group install -y "Development Tools" && \
  yum install -y --setopt=tsflags=nodocs \
    advancecomp \
    cmake3 \
    glib2-devel \
    gobject-introspection-devel \
    gperf \
    gtk-doc \
    help2man \
    jq \
    nasm \
    ncurses-devel \
    ninja-build \
    prelink \
    python3-devel \
    texinfo && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal && \
  rustup target add arm-unknown-linux-gnueabihf && \
  ln -s /usr/bin/cmake3 /usr/bin/cmake && \
  pip3 install meson

# Download and install the latest version of crosstool-ng
RUN \
  git clone -b master --single-branch --depth 1 \
    https://github.com/crosstool-ng/crosstool-ng.git

WORKDIR /crosstool-ng
RUN \
  ./bootstrap && \
  ./configure --prefix=/usr/local && \
  make -j$(nproc) && \
  make install && \
  cd .. && \
  rm -rf crosstool-ng

# Build cross-compiler (GCC 11.1.0 - glibc 2.17)
WORKDIR /x-tools/build

COPY armv7-linux-gnueabihf.config /x-tools/build/.config

RUN \
  ct-ng olddefconfig && \
  CT_ALLOW_BUILD_AS_ROOT_SURE=y ct-ng build || (cat build.log && exit 1) && \
  cd .. && \
  rm -rf build

WORKDIR /

# Compiler settings
ENV \
  CC="armv7-unknown-linux-gnueabihf-gcc" \
  CXX="armv7-unknown-linux-gnueabihf-g++" \
  AR="armv7-unknown-linux-gnueabihf-ar" \
  STRIP="armv7-unknown-linux-gnueabihf-strip" \
  RANLIB="armv7-unknown-linux-gnueabihf-ranlib" \
  OBJDUMP="armv7-unknown-linux-gnueabihf-objdump" \
  PLATFORM="linux-arm" \
  CHOST="arm-linux-gnueabihf" \
  RUST_TARGET="arm-unknown-linux-gnueabihf" \
  FLAGS="-marm -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
