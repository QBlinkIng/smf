#!/bin/bash

# Copyright 2018 SMF Authors
#

set -e

function debs() {
  if [ -n "${USE_CLANG}" ]; then
    extra=clang
  fi
  apt-get update
  apt-get install -y \
    pkg-config \
    build-essential \
    cmake \
    libaio-dev \
    libcrypto++-dev \
    xfslibs-dev \
    libunwind-dev \
    systemtap-sdt-dev \
    libsctp-dev \
    libxml2-dev \
    libpciaccess-dev \
    ninja-build \
    doxygen \
    stow \
    python ${extra}
}

function rpms() {
  yumdnf="yum"
  if command -v dnf > /dev/null; then
    yumdnf="dnf"
  fi

  ${yumdnf} install -y redhat-lsb-core
  case $(lsb_release -si) in
    CentOS)
      MAJOR_VERSION=$(lsb_release -rs | cut -f1 -d.)
      $SUDO yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/$MAJOR_VERSION/x86_64/
      $SUDO yum install --nogpgcheck -y epel-release
      $SUDO rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$MAJOR_VERSION
      $SUDO rm -f /etc/yum.repos.d/dl.fedoraproject.org*
      ;;
  esac

  if [ -n "${USE_CLANG}" ]; then
    extra=clang
  fi
  ${yumdnf} install -y \
    cmake \
    gcc-c++ \
    make \
    libpciaccess-devel \
    libaio-devel \
    libunwind-devel \
    libxml2-devel \
    xfsprogs-devel \
    systemtap-sdt-devel \
    lksctp-tools-devel \
    ninja-build \
    doxygen \
    stow \
    python ${extra}
}

source /etc/os-release
case $ID in
  debian|ubuntu|linuxmint)
    debs
    ;;

  centos|fedora)
    rpms
    ;;

  *)
    echo "$ID not supported. Install dependencies manually."
    exit 1
    ;;
esac
