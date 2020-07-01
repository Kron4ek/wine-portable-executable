#!/usr/bin/env bash

## This script creates runtime for Wine by using two Ubuntu chroots

scriptdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

CHROOT_X64="${HOME}/chroots/bionic64_chroot"
CHROOT_X32="${HOME}/chroots/bionic32_chroot"

if [ ! -d "${CHROOT_X64}" ] || [ ! -d "${CHROOT_X32}" ]; then
	echo "Chroots are required for the runtime creation!"
	exit 1
fi

if [ ! -f "${scriptdir}"/runtime_libs_list.txt ]; then
	echo "runtime_libs_list.txt is required!"
	exit 1
fi

rm -rf "${scriptdir}"/wine-runtime
mkdir -p "${scriptdir}"/wine-runtime/lib32
mkdir -p "${scriptdir}"/wine-runtime/lib

echo "Copying libraries..."
while read lib; do
	if [ -f "${CHROOT_X32}"/usr/local/lib/"${lib}" ]; then
		cp "${CHROOT_X32}"/usr/local/lib/"${lib}" "${scriptdir}"/wine-runtime/lib32 2>/dev/null
	else
		cp "${CHROOT_X32}"/lib/i386-linux-gnu/"${lib}" "${scriptdir}"/wine-runtime/lib32 2>/dev/null
		cp "${CHROOT_X32}"/usr/lib/i386-linux-gnu/"${lib}" "${scriptdir}"/wine-runtime/lib32 2>/dev/null
	fi

	if [ -f "${CHROOT_X64}"/usr/local/lib/"${lib}" ]; then
		cp "${CHROOT_X64}"/usr/local/lib/"${lib}" "${scriptdir}"/wine-runtime/lib 2>/dev/null
	else
		cp "${CHROOT_X64}"/lib/x86_64-linux-gnu/"${lib}" "${scriptdir}"/wine-runtime/lib 2>/dev/null
		cp "${CHROOT_X64}"/usr/lib/x86_64-linux-gnu/"${lib}" "${scriptdir}"/wine-runtime/lib 2>/dev/null
	fi
done < "${scriptdir}"/runtime_libs_list.txt

cd "${scriptdir}" || exit 1

find wine-runtime -type f -exec strip --strip-unneeded {} \;

echo "Creating and compressing archive..."
tar -cf wine-runtime.tar wine-runtime
xz -9 wine-runtime.tar

rm -r wine-runtime

if [ -d binaries ]; then ln -sfr wine-runtime.tar.xz binaries; fi

echo "Done"
