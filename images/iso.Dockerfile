ARG REPO
ARG TAG
FROM ${REPO}/package:${TAG} as package

ARG REPO
ARG TAG
FROM ${REPO}/base:${TAG} as base

ARG ARCH
ARG VERSION
RUN apk add xorriso grub grub-efi mtools libvirt qemu-img qemu-modules
RUN if [ "${ARCH}" == "amd64" ]; then \
        apk add qemu-system-x86_64 grub-bios ovmf \
    ;elif [ "${ARCH}" == "arm64" ]; then \
        apk add qemu-system-aarch64 \
    ;fi
RUN ln -s /usr/bin/qemu-system-* /usr/bin/qemu-system
RUN qemu-img create -f qcow2 /hd.img 40G
COPY scripts/run-kvm.sh /usr/bin
COPY grub.cfg /usr/src/iso/boot/grub/grub.cfg

COPY --from=package /output/ /usr/src/iso/
COPY config.yaml /usr/src/iso/k3os/system

RUN mkdir -p /output && \
    grub-mkrescue -o /output/k3os.iso /usr/src/iso/. -- -volid K3OS -joliet on && \
    [ -e /output/k3os.iso ]
RUN mkdir -p /dist && 
    cp /output/k3os.iso /dist/k3os-{VERSION}.iso
CMD ["run-kvm.sh"]