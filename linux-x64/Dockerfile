FROM centos:7
LABEL maintainer "Kleis Auke Wolthuizen <info@kleisauke.nl>"

# Create CentOS 7 (glibc 2.17) container suitable for building Linux x64 binaries

# Build dependencies
RUN \
  yum update -y \
  && yum install -y epel-release centos-release-scl scl-utils \
  && yum group install -y "Development Tools" \
  && yum install -y --setopt=tsflags=nodocs \
    advancecomp \
    cmake3 \
    devtoolset-8-make \
    devtoolset-8-gcc \
    devtoolset-8-gcc-c++ \
    git \
    glib-devel \
    gperf \
    gtk-doc \
    jq \
    nasm \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y \
  && ln -s /usr/bin/cmake3 /usr/bin/cmake

# Create a file that is sourced each time the shell session is opened
RUN \
  echo "unset BASH_ENV PROMPT_COMMAND ENV" > /usr/local/bin/scl_enable \
  && echo "source scl_source enable devtoolset-8" >> /usr/local/bin/scl_enable \
  && chgrp -R 0 /usr/local/bin \
  && chmod -R g+rx /usr/local/bin

# Enable the SCL for all bash scripts
ENV \
  PATH="/opt/rh/devtoolset-8/root/usr/bin:$PATH" \
  BASH_ENV="/usr/local/bin/scl_enable" \
  ENV="/usr/local/bin/scl_enable" \
  PROMPT_COMMAND=". /usr/local/bin/scl_enable"

# Compiler settings
ENV \
  PATH="/root/.cargo/bin:$PATH" \
  PLATFORM="linux-x64" \
  FLAGS="-O3"

COPY Toolchain.cmake /root/
