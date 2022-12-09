ARG REPO
ARG TAG
FROM ubuntu:focal as kernel-stage1

RUN apt-get --assume-yes update \
 && apt-get --assume-yes install \
    curl \
    initramfs-tools \
    kmod \
    lz4 \
    rsync \
    xz-utils \
 && echo 'r8152' >> /etc/initramfs-tools/modules \
 && echo 'hfs' >> /etc/initramfs-tools/modules \
 && echo 'hfsplus' >> /etc/initramfs-tools/modules \
 && echo 'nls_utf8' >> /etc/initramfs-tools/modules \
 && echo 'nls_iso8859_1' >> /etc/initramfs-tools/modules

ARG ARCH
ENV KVERSION=5.4.0-88-generic
ENV URL=https://github.com/rancher/k3os-kernel/releases/download/5.4.0-88.99-rancher1
ENV KERNEL_XZ=${URL}/kernel-generic_${ARCH}.tar.xz
ENV KERNEL_EXTRA_XZ=${URL}/kernel-extra-generic_${ARCH}.tar.xz
ENV KERNEL_HEADERS_XZ=${URL}/kernel-headers-generic_${ARCH}.tar.xz

# Download kernel
RUN mkdir -p /usr/src
RUN curl -fL $KERNEL_XZ -o /usr/src/kernel.tar.xz
RUN curl -fL $KERNEL_EXTRA_XZ -o /usr/src/kernel-extra.tar.xz
RUN curl -fL $KERNEL_HEADERS_XZ -o /usr/src/kernel-headers.tar.xz

# Extract to /usr/src/root
RUN mkdir -p /usr/src/root && \
    cd /usr/src/root && \
    tar xvf /usr/src/kernel.tar.xz && \
    tar xvf /usr/src/kernel-extra.tar.xz && \
    tar xvf /usr/src/kernel-headers.tar.xz

# Create initrd
RUN mkdir /usr/src/initrd && \
    rsync -a /usr/src/root/lib/ /lib/ && \
    depmod $KVERSION && \
    mkinitramfs -k $KVERSION -c lz4 -o /usr/src/initrd.tmp

# Generate initrd firmware and module lists
RUN mkdir -p /output/lib && \
    mkdir -p /output/headers && \
    cd /usr/src/initrd && \
    lz4cat /usr/src/initrd.tmp | cpio -idmv && \
    find lib/modules -name \*.ko > /output/initrd-modules && \
    echo lib/modules/${KVERSION}/modules.order >> /output/initrd-modules && \
    echo lib/modules/${KVERSION}/modules.builtin >> /output/initrd-modules && \
    find lib/firmware -type f > /output/initrd-firmware && \
    find usr/lib/firmware -type f | sed 's!usr/!!' >> /output/initrd-firmware

# Copy output assets
RUN cd /usr/src/root && \
    cp -r usr/src/linux-headers* /output/headers && \
    cp -r lib/firmware /output/lib/firmware && \
    cp -r lib/modules /output/lib/modules && \
    cp boot/System.map* /output/System.map && \
    cp boot/config* /output/config && \
    cp boot/vmlinuz-* /output/vmlinuz && \
    echo ${KVERSION} > /output/version

ARG REPO
ARG TAG
FROM ${REPO}/bin:${TAG} as bin

FROM ${REPO}/base:${TAG}
ARG TAG
RUN apk add squashfs-tools
COPY --from=kernel-stage1 /output/ /usr/src/kernel/

RUN mkdir -p /usr/src/initrd/lib && \
    cd /usr/src/kernel && \
    tar cf - -T initrd-modules -T initrd-firmware | tar xf - -C /usr/src/initrd/ && \
    depmod -b /usr/src/initrd $(cat /usr/src/kernel/version)

RUN mkdir -p /output && \
    cd /usr/src/kernel && \
    depmod -b . $(cat /usr/src/kernel/version) && \
    mksquashfs . /output/kernel.squashfs

RUN cp /usr/src/kernel/version /output/ && \
    cp /usr/src/kernel/vmlinuz /output/

COPY --from=bin /output/ /usr/src/k3os/
RUN cd /usr/src/initrd && \
    mkdir -p k3os/system/k3os/${TAG} && \
    cp /usr/src/k3os/k3os k3os/system/k3os/${TAG} && \
    ln -s ${TAG} k3os/system/k3os/current && \
    ln -s /k3os/system/k3os/current/k3os init
    
RUN cd /usr/src/initrd && \
    find . | cpio -H newc -o | gzip -c -1 > /output/initrd