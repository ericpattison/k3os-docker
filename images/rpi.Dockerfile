ARG REPO
ARG TAG
FROM ${REPO}/package:${TAG} as package

ARG REPO
ARG TAG
FROM ${REPO}/base:${TAG} as base

#TODO Move to base?
RUN apk add binutils p7zip

ARG RPI_FIRMWARE=1.20221104
RUN wget -O raspberrypi-firmware.tar.gz https://github.com/raspberrypi/firmware/archive/${RPI_FIRMWARE}.tar.gz
RUN wget -O rpi-firmware-nonfree-buster.zip https://github.com/RPi-Distro/firmware-nonfree/archive/buster.zip

RUN wget -O libc6-arm64.deb https://launchpadlibrarian.net/365857916/libc6_2.27-3ubuntu1_arm64.deb
RUN wget -O busybox-arm64.deb https://launchpadlibrarian.net/414117084/busybox_1.27.2-2ubuntu3.2_arm64.deb
RUN wget -O libcom-err2-arm64.deb https://launchpadlibrarian.net/444344115/libcom-err2_1.44.1-1ubuntu1.2_arm64.deb
RUN wget -O libblkid1-arm64.deb https://launchpadlibrarian.net/438655401/libblkid1_2.31.1-0.4ubuntu3.4_arm64.deb
RUN wget -O libmount1-arm64.deb https://launchpadlibrarian.net/497838944/libmount1_2.31.1-0.4ubuntu3.7_arm64.deb
RUN wget -O libsmartcols1-arm64.deb https://launchpadlibrarian.net/497838945/libsmartcols1_2.31.1-0.4ubuntu3.7_arm64.deb
RUN wget -O libuuid1-arm64.deb https://launchpadlibrarian.net/438655406/libuuid1_2.31.1-0.4ubuntu3.4_arm64.deb
RUN wget -O libext2fs2-arm64.deb https://launchpadlibrarian.net/444344116/libext2fs2_1.44.1-1ubuntu1.2_arm64.deb
RUN wget -O e2fsprogs-arm64.deb https://launchpadlibrarian.net/444344112/e2fsprogs_1.44.1-1ubuntu1.2_arm64.deb
RUN wget -O parted-arm64.deb https://launchpadlibrarian.net/415806982/parted_3.2-20ubuntu0.2_arm64.deb
RUN wget -O libparted2-arm64.deb https://launchpadlibrarian.net/415806981/libparted2_3.2-20ubuntu0.2_arm64.deb
RUN wget -O libreadline7-arm64.deb https://launchpadlibrarian.net/354246199/libreadline7_7.0-3_arm64.deb
RUN wget -O libtinfo5-arm64.deb https://launchpadlibrarian.net/371711519/libtinfo5_6.1-1ubuntu1.18.04_arm64.deb
RUN wget -O libdevmapper1-arm64.deb https://launchpadlibrarian.net/431292125/libdevmapper1.02.1_1.02.145-4.1ubuntu3.18.04.1_arm64.deb
RUN wget -O libselinux1-arm64.deb https://launchpadlibrarian.net/359065467/libselinux1_2.7-2build2_arm64.deb
RUN wget -O libudev1-arm64.deb https://launchpadlibrarian.net/444834685/libudev1_237-3ubuntu10.31_arm64.deb
RUN wget -O libpcre3-arm64.deb https://launchpadlibrarian.net/355683636/libpcre3_8.39-9_arm64.deb
RUN wget -O util-linux-arm64.deb https://launchpadlibrarian.net/438655410/util-linux_2.31.1-0.4ubuntu3.4_arm64.deb


RUN mkdir -p /usr/src/package
COPY --from=package /output/ /usr/src/package

COPY config/ /usr/src/config
COPY scripts/rpi-filesystem /usr/bin
COPY scripts/init.preinit /usr/src/
COPY scripts/init.resizefs /usr/src/

RUN mkdir ouptput

CMD ["rpi-filesystem"]