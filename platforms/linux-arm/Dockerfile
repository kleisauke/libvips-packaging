FROM amazonlinux:2
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create Amazon Linux 2 (glibc 2.26) container suitable for cross-compiling Linux ARMv7-A binaries

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:/x-tools/armv7-unknown-linux-gnueabihf/bin:$PATH"

# Build dependencies
RUN \
  yum update -y && \
  amazon-linux-extras install epel -y && \
  yum group install -y "Development Tools" && \
  yum install -y --setopt=tsflags=nodocs \
    cmake3 \
    gperf \
    jq \
    openssl-devel \
    python3 \
    # Needed by crosstool-ng
    help2man \
    ncurses-devel \
    texinfo \
    which \
    && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    --target arm-unknown-linux-gnueabihf \
    --default-toolchain nightly \
    && \
  cargo install cargo-c --locked && \
  ln -s /usr/bin/cmake3 /usr/bin/cmake && \
  pip3 install meson ninja tomli

# Download and install crosstool-ng 1.27.0
WORKDIR /crosstool-ng
RUN \
  curl -sL https://github.com/crosstool-ng/crosstool-ng/releases/download/crosstool-ng-1.27.0/crosstool-ng-1.27.0.tar.xz | \
    tar xJC /crosstool-ng --strip-components=1 && \
  ./bootstrap && \
  ./configure --prefix=/usr/local && \
  make -j$(nproc) && \
  make install && \
  cd .. && \
  rm -rf crosstool-ng

# Build cross-compiler (GCC 14.2.0 - glibc 2.26)
WORKDIR /x-tools/build

COPY patches/ /x-tools/patches/
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
  RUSTFLAGS="-Zlocation-detail=none -Zfmt-debug=none" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
