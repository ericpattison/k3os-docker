ARG TAG

FROM golang:1.16-alpine3.14 AS gobuild
RUN apk -U add git gcc linux-headers musl-dev make libseccomp libseccomp-dev bash
COPY scripts/gobuild /usr/bin/gobuild
RUN rm -f /bin/sh && ln -s /bin/bash /bin/sh && chmod +x /usr/bin/gobuild
WORKDIR /output

FROM k3os/base:${TAG} as k3s

ARG ARCH=amd64
ENV ARCH ${ARCH}
ENV VERSION v1.23.3+k3s1
ADD https://raw.githubusercontent.com/rancher/k3s/${VERSION}/install.sh /output/install.sh
ENV INSTALL_K3S_VERSION=${VERSION} \
    INSTALL_K3S_SKIP_START=true \
    INSTALL_K3S_BIN_DIR=/output
RUN chmod +x /output/install.sh
RUN /output/install.sh
RUN echo "${VERSION}" > /output/version

FROM ubuntu:focal
RUN apt-get --assume-yes update \
    && apt-get --assume-yes install \
        curl \
        initramfs-tools \
        kmod \
        lz4 \
        rsync \
        xz-utils \
        git \
    && echo 'r8152' >> /etc/initramfs-tools/modules \
    && echo 'hfs' >> /etc/initramfs-tools/modules \
    && echo 'hfsplus' >> /etc/initramfs-tools/modules \
    && echo 'nls_utf8' >> /etc/initramfs-tools/modules \
    && echo 'nls_iso8859_1' >> /etc/initramfs-tools/modules