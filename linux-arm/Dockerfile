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
    gperf \
    help2man \
    jq \
    nasm \
    ncurses-devel \
    python3-devel \
    texinfo \
    which && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    --default-toolchain nightly && \
  rustup target add arm-unknown-linux-gnueabihf && \
  ln -s /usr/bin/cmake3 /usr/bin/cmake && \
  pip3 install --upgrade pip && \
  pip3 install meson ninja

# Download and install crosstool-ng 1.25.0
WORKDIR /crosstool-ng
RUN \
  curl -sL https://github.com/crosstool-ng/crosstool-ng/releases/download/crosstool-ng-1.25.0/crosstool-ng-1.25.0.tar.xz | \
    tar xJC /crosstool-ng --strip-components=1 && \
  ./bootstrap && \
  ./configure --prefix=/usr/local && \
  make -j$(nproc) && \
  make install && \
  cd .. && \
  rm -rf crosstool-ng

# Build cross-compiler (GCC 11.2.0 - glibc 2.17)
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
  PKG_CONFIG="pkg-config --static" \
  PLATFORM="linux-arm" \
  CHOST="arm-linux-gnueabihf" \
  RUST_TARGET="arm-unknown-linux-gnueabihf" \
  FLAGS="-marm -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
