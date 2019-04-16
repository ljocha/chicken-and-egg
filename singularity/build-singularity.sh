#!/bin/bash

apk add --update  build-essential libssl-dev uuid-dev libgpgme11-dev libseccomp-dev pkg-config squashfs-tools || exit 1

cd singularity

export VERSION=1.11.4 OS=linux ARCH=amd64

wget -O /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz && \
tar -C /usr/local -xzf /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz || exit 1

GOPATH=$HOME/go
export GOPATH

PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin

mkdir -p ${GOPATH}/src/github.com/sylabs && \
  cd ${GOPATH}/src/github.com/sylabs && \
  git clone https://github.com/sylabs/singularity.git && \
  cd singularity

git checkout v3.2.0

./mconfig && \
  cd ./builddir && \
  make && \
  make install

