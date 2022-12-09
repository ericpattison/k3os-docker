
FROM library/ubuntu:bionic as bionic
ARG DOWNLOADS=/usr/src/downloads
ARG LINUX_FIRMWARE=linux-firmware=1.173.18
ARG LINUX_SOURCE=linux-source-5.0.0=5.0.0-47.51~18.04.1

RUN set -x \
    && apt-get --assume-yes update \
    && apt-get --assume-yes download \
        ${LINUX_FIRMWARE} \
        ${LINUX_SOURCE} \
    && mkdir -vp ${DOWNLOADS} \
    && mv -vf linux-firmware* ${DOWNLOADS}/ubuntu-firmware.deb \
    && mv -vf linux-source* ${DOWNLOADS}/ubuntu-kernel.deb

FROM gcc:9.2
ARG DOWNLOADS=/usr/src/downloads
COPY --from=bionic ${DOWNLOADS}/ ${DOWNLOADS}/
RUN apt update \
    && apt install -y \
        kernel-wedge \
        libncurses-dev \
        fakeroot \
        cpio \
        bison \
        flex \
        ccache \
        vim \
        gnupg2 \
        locales \
        bc \
        kmod \
        libelf-dev \
        rsync \
        gawk \
        libudev-dev \
#        pciutils-dev \
    && rm -f /bin/sh && ln -s /bin/bash /bin/sh

RUN mkdir -p ${DOWNLOADS}/kernel ${DOWNLOADS}/firmware && \
    mkdir -p build/kernel && \
    dpkg-deb -x ${DOWNLOADS}/ubuntu-kernel.deb ${DOWNLOADS}/kernel && \
    rsync -a ${DOWNLOADS}/kernel/usr/src/linux-source-*/debian* ./build/kernel/ && \
    tar xf ${DOWNLOADS}/kernel/usr/src/linux-source-*/linux-source*.tar.bz2 -C ./build/kernel/. --strip-components=1

COPY patches /var/patches
COPY scripts /var/scripts
RUN chmod +x /var/scripts/* \
    && /var/scripts/patch

#build
WORKDIR /build/kernel
RUN mkdir -p /build/kernel/debian/stamps \
    && chmod -R +x /build/kernel/debian/scripts \
    && debian/rules clean \
    && /var/scripts/module \
    && debian/rules binary-headers binary-generic do_zfs=false do_dkms_nvidia=false