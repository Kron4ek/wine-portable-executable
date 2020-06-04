#!/usr/bin/env bash

## This script creates squashfuse archive by using Ubuntu chroot

scriptdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

CHROOT_X64="/home/builder/chroots/bionic64_chroot"

if [ ! -d "${CHROOT_X64}" ]; then
	echo "Chroot is required for squashfuse compilation!"
	exit 1
fi

if [ "$EUID" != 0 ]; then
	echo "Root rights are required for squashfuse compilation!"
	exit 1
fi

build_in_chroot () {
	CHROOT_PATH="$CHROOT_X64"

	echo "Unmounting chroot directories"
	umount -Rl "$CHROOT_PATH"

	echo "Mount directories for chroot"
	mount --bind "$CHROOT_PATH" "$CHROOT_PATH"
	mount --bind /dev "$CHROOT_PATH/dev"
	mount --bind /dev/shm "$CHROOT_PATH/dev/shm"
	mount --bind /dev/pts "$CHROOT_PATH/dev/pts"
	mount --bind /proc "$CHROOT_PATH/proc"
	mount --bind /sys "$CHROOT_PATH/sys"

	echo "Chrooting into $CHROOT_PATH"
	chroot "$CHROOT_PATH" /usr/bin/env LANG=en_US.UTF-8 TERM=xterm PATH="/bin:/sbin:/usr/bin:/usr/sbin" /opt/build.sh

	echo "Unmounting chroot directories"
	umount -Rl "$CHROOT_PATH"
}

create_build_scripts () {
	echo '#!/bin/bash' > $MAINDIR/build.sh
	echo 'apt-get update' >> $MAINDIR/build.sh
	echo 'apt-get -y install libfuse-dev' >> $MAINDIR/build.sh
	echo 'mkdir /opt/build_squashfuse' >> $MAINDIR/build.sh
	echo 'cd /opt/build_squashfuse' >> $MAINDIR/build.sh
	echo 'wget -O lz4.tar.gz https://github.com/lz4/lz4/archive/v1.9.2.tar.gz' >> $MAINDIR/build.sh
	echo 'wget -O zstd.tar.gz https://github.com/facebook/zstd/archive/v1.4.5.tar.gz' >> $MAINDIR/build.sh
	echo 'wget -O squashfuse.tar.gz https://github.com/vasi/squashfuse/archive/0.1.103.tar.gz' >> $MAINDIR/build.sh
	echo 'tar xf lz4.tar.gz' >> $MAINDIR/build.sh
	echo 'tar xf zstd.tar.gz' >> $MAINDIR/build.sh
	echo 'tar xf squashfuse.tar.gz' >> $MAINDIR/build.sh
	echo 'cd lz4-1.9.2 && make -j$(nproc) && make install' >> $MAINDIR/build.sh
	echo 'cd ../zstd-1.4.5 && make -j$(nproc) && make install' >> $MAINDIR/build.sh
	echo 'cd ../squashfuse-0.1.103 && ./autogen.sh' >> $MAINDIR/build.sh
	echo 'mkdir ../build && cd ../build' >> $MAINDIR/build.sh
	echo '../squashfuse-0.1.103/configure --without-zlib --without-xz --without-lzo' >> $MAINDIR/build.sh
	echo 'make -j$(nproc) && make install' >> $MAINDIR/build.sh
	echo 'cd /opt && rm -r /opt/build_squashfuse' >> $MAINDIR/build.sh

	chmod +x "$MAINDIR/build.sh"
	mv "$MAINDIR/build.sh" "$CHROOT_X64/opt"
}

create_build_scripts
build_in_chroot

rm "$CHROOT_X64/opt/build.sh"

rm -rf "${scriptdir}"/squashfuse
mkdir -p "${scriptdir}"/squashfuse/squashfuse-amd64

cp "${CHROOT_X64}"/usr/local/lib/libsquashfuse.so.0 "${scriptdir}"/squashfuse/squashfuse-amd64
cp "${CHROOT_X64}"/usr/local/lib/libfuseprivate.so.0 "${scriptdir}"/squashfuse/squashfuse-amd64
cp "${CHROOT_X64}"/usr/local/lib/liblz4.so.1 "${scriptdir}"/squashfuse/squashfuse-amd64
cp "${CHROOT_X64}"/usr/local/lib/libzstd.so.1 "${scriptdir}"/squashfuse/squashfuse-amd64
cp "${CHROOT_X64}"/usr/local/bin/squashfuse "${scriptdir}"/squashfuse/squashfuse-amd64

cd "${scriptdir}" || exit 1

tar -cf squashfuse.tar squashfuse

rm -r squashfuse

if [ -d binaries ]; then ln -sfr squashfuse.tar binaries; fi

clear; echo "Done"
