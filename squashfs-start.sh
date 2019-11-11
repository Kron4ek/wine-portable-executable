#!/usr/bin/env bash

## Required packages: fuse

# Prevent launching as root
if [ $EUID = 0 ]; then
   echo "Do not run this app as root!"
   
   exit 1
fi

# Full path to the script
script="$(readlink -f "${BASH_SOURCE[0]}")"

# Working directory where squashfs image will be mounted
# Default path: /tmp/scriptname_username_randomnumber
working_dir=/tmp/"$(basename "$0")"_"$(id -un)"_$RANDOM

# It's important to set correct sizes below, otherwise there will be
# a problem with mounting the squashfs image due to an incorrectly calculated offset.

# The size of this script
scriptsize=3147

# The size of the squashfuse.tar archive
# Squashfuse.tar contains squashfuse binaries
sfusesize=2375680

# Offset where the squashfs image is stored
offset=$((scriptsize+sfusesize))

appname="Wine (amd64) Portable SquashFS"

# Enable this if packed Wine requires a 64-bit OS to work
app_arch_amd64=1

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo -e "-e \tExtract app files"
	echo -e "-o \tShow squashfs offset"
	echo -e "-b \tUse builtin squashfuse"

	exit
elif [ "$1" = "-e" ]; then
	if command -v unsquashfs 1>/dev/null; then
		unsquashfs -o $offset -d "$(basename "$0")"_files "${script}"
	else
		echo "To extract the image install squashfs-tools."
	fi
	
	exit
elif [ "$1" = "-o" ]; then
	echo $offset
	
	exit
fi

# If the app is 64-bit, then check if the OS is 64-bit too
if [ $app_arch_amd64 = 1 ] && [ $(getconf LONG_BIT) != 64 ]; then
	echo "64-bit OS is required for this app to work!"
	
	exit 1
fi

# Check if FUSE is installed
if ! command -v fusermount 1>/dev/null; then
	echo "Please install fuse and run the app again"
	
	exit 1
fi

echo "$appname"
echo

# Check if squashfuse is installed, and if it's not, then use the builtin binaries
if ! command -v squashfuse 1>/dev/null || [ "$1" = "-b" ]; then
	mkdir -p "${working_dir}"
	tail -c +$((scriptsize+1)) "${script}" | head -c $sfusesize > "${working_dir}"/squashfuse.tar
	tar -C "${working_dir}" -xf "${working_dir}"/squashfuse.tar
	rm "${working_dir}"/squashfuse.tar

	if ! command -v squashfuse 1>/dev/null; then
		echo "Squashfuse is not installed"
	fi
	echo "Using builtin squashfuse binary"
	echo

	if [ $(getconf LONG_BIT) = 64 ]; then
		export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${working_dir}/squashfuse/squashfuse-amd64"
		sfuse="${working_dir}"/squashfuse/squashfuse-amd64/squashfuse
	else
		export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${working_dir}/squashfuse/squashfuse-i386"
		sfuse="${working_dir}"/squashfuse/squashfuse-i386/squashfuse
	fi
	
	chmod +x "${sfuse}"
else
	sfuse=squashfuse
fi

mkdir -p "${working_dir}"/mnt
fusermount -u "${working_dir}"/mnt 2>/dev/null || umount "${working_dir}"/mnt 2>/dev/null

"${sfuse}" -o offset=$offset "${script}" "${working_dir}"/mnt
if [ $? = 0 ]; then
	if [ "$1" = "-b" ]; then shift; fi
	if [ "$1" = "wine" ]; then shift; fi
	if [ "$1" = "wine64" ]; then shift; fi
	
	env -u LD_LIBRARY_PATH "${working_dir}"/mnt/wine.sh "$@"

	fusermount -uz "${working_dir}"/mnt 2>/dev/null || umount --lazy "${working_dir}"/mnt 2>/dev/null
else
	echo "Mounting the squashfs image failed!"
	
	exit 1
fi

rm -rf "${working_dir}"

exit
