FROM rockylinux:8
LABEL maintainer="Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create Rocky Linux 8 (glibc 2.28) container suitable for cross-compiling Linux ARMv7-A binaries

# Path settings
ENV \
  RUSTUP_HOME="/usr/local/rustup" \
  CARGO_HOME="/usr/local/cargo" \
  PATH="/usr/local/cargo/bin:/x-tools/armv7-unknown-linux-gnueabihf/bin:/opt/rh/gcc-toolset-15/root/usr/bin:$PATH"

# Build dependencies
RUN \
  dnf update -y && \
  dnf install -y epel-release && \
  dnf config-manager --set-enabled powertools && \
  dnf install -y --setopt=tsflags=nodocs \
    autoconf \
    automake \
    bzip2 \
    cmake \
    curl-devel \
    findutils \
    gcc-toolset-15-gcc \
    gcc-toolset-15-gcc-c++ \
    gettext \
    git \
    gperf \
    jq \
    make \
    openssl-devel \
    patch \
    pkgconf \
    python3.12-pip \
    tar \
    xz \
    # Needed by crosstool-ng
    bison \
    file \
    flex \
    help2man \
    libtool \
    ncurses-devel \
    texinfo \
    unzip \
    which \
    && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --profile minimal \
    --target arm-unknown-linux-gnueabihf \
    --default-toolchain nightly \
    && \
  cargo install cargo-c --locked && \
  pip3.12 install meson ninja

# Download and install crosstool-ng 1.28.0
WORKDIR /crosstool-ng
RUN \
  curl -sL https://github.com/crosstool-ng/crosstool-ng/releases/download/crosstool-ng-1.28.0/crosstool-ng-1.28.0.tar.xz | \
    tar xJC /crosstool-ng --strip-components=1 && \
  ./bootstrap && \
  ./configure --prefix=/usr/local && \
  make -j$(nproc) && \
  make install && \
  cd .. && \
  rm -rf crosstool-ng

# Build cross-compiler (GCC 15.2.0 - glibc 2.28)
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
  PKG_CONFIG="armv7-linux-gnueabihf-pkgconf --static" \
  PLATFORM="linux-arm" \
  CHOST="arm-linux-gnueabihf" \
  RUST_TARGET="arm-unknown-linux-gnueabihf" \
  FLAGS="-marm -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" \
  RUSTFLAGS="-Zlocation-detail=none -Zfmt-debug=none" \
  MESON="--cross-file=/root/meson.ini"

COPY Toolchain.cmake /root/
COPY meson.ini /root/
COPY armv7-linux-gnueabihf-pkgconf /usr/bin
