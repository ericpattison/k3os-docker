ARG REPO
ARG TAG
FROM ${REPO}/rootfs:${TAG} as rootfs

ARG REPO
ARG TAG
FROM ${REPO}/progs:${TAG} as progs

ARG REPO
ARG TAG
FROM ${REPO}/base:${TAG}

COPY --from=rootfs /output/rootfs.squashfs /usr/src/
COPY scripts/install.sh /output/k3os-install.sh
COPY --from=progs /output/k3os /output/k3os
RUN echo -n "_sqmagic_" >> /output/k3os
RUN cat /usr/src/rootfs.squashfs >> /output/k3os