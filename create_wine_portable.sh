#!/usr/bin/env bash

## Required packages: squashfs-tools wget xz

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# You can change the url below if you want to use a different Wine build
# You can also put your directory (named wine) containing Wine build near the script
# If the script will see the directory named wine, then this URL will not be used
wine_url="https://github.com/Kron4ek/Wine-Builds/releases/download/5.15/wine-5.15-staging-amd64.tar.xz"

# Builtin suqashfuse supports only lz4 and zstd
# So choose either lz4 or zstd
squashfs_compressor="lz4"
compressor_arguments="-Xhc"

if ! command -v mksquashfs 1>/dev/null; then
	echo "squashfs-tools is required!"
	exit 1
fi

if ! command -v wget 1>/dev/null; then
	echo "wget is required!"
	exit 1
fi

if ! command -v xz 1>/dev/null; then
	echo "xz is required!"
	exit 1
fi

rm -rf "${script_dir}"/wine-portable
mkdir -p "${script_dir}"/wine-portable/squashfs-root

cd "${script_dir}"/wine-portable/squashfs-root || exit 1

# If there is no wine directory, then download Wine build from the URL
if  [ ! -d wine ]; then
	if [ ! -d "${script_dir}"/wine ]; then
		wget -nv -O wine.tar.xz "${wine_url}" -q --show-progress

		if [ $? -ne 0 ]; then
			echo "URL for downloading Wine is incorrect!"
			echo "Please set wine_url variable to correct URL"
			exit 1
		fi

		tar xf wine.tar.xz
		rm wine.tar.xz
		mv wine* wine

		cp -r wine "${script_dir}"
	else
		cp -r "${script_dir}"/wine .
	fi
fi

if [ ! -d wine-runtime ]; then
	if [ ! -f "${script_dir}"/binaries/wine-runtime.tar.xz ]; then
		echo "binaries/wine-runtime.tar.xz is required!"
		exit 1
	elif [ "$(stat -c%s "${script_dir}"/binaries/wine-runtime.tar.xz)" -lt 10000 ]; then
		echo "Seems like binaries/wine-runtime.tar.xz is corrupted!"
		exit 1
	else
		tar xf "${script_dir}"/binaries/wine-runtime.tar.xz
	fi
fi

if [ ! -f wine.sh ]; then
	if [ ! -f "${script_dir}"/wine.sh ]; then
		echo "wine.sh is required!"
		exit 1
	else
		cp "${script_dir}"/wine.sh .
	fi

	chmod +x wine.sh
fi

if [ ! -f winetricks ]; then
	if [ ! -f "${script_dir}"/winetricks ]; then
		wget -nv -O winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -q --show-progress
		cp winetricks "${script_dir}"
	else
		cp "${script_dir}"/winetricks .
	fi

	chmod +x winetricks
fi

cd "${script_dir}"/wine-portable

if [ ! -f squashfuse.tar ]; then
	if [ ! -f "${script_dir}"/binaries/squashfuse.tar ]; then
		echo "binaries/squashfuse.tar is required!"
		exit 1
	elif [ "$(stat -c%s "${script_dir}"/binaries/squashfuse.tar)" -lt 10000 ]; then
		echo "Seems like binaries/squashfuse.tar is corrupted!"
		exit 1
	else
		cp -L "${script_dir}"/binaries/squashfuse.tar .
	fi
fi

if [ ! -f squashfs-start.sh ]; then
	if [ ! -f "${script_dir}"/squashfs-start.sh ]; then
		echo "squashfs-start.sh is required!"
		exit 1
	else
		cp "${script_dir}"/squashfs-start.sh .
	fi

	chmod +x squashfs-start.sh
fi

echo
echo "Creating a portable Wine executable..."
echo

# Create the squashfs image
rm -f wine.squashfs
mksquashfs squashfs-root wine.squashfs -comp $squashfs_compressor $compressor_arguments

# Combine the files into a single executable using cat
cat squashfs-start.sh squashfuse.tar wine.squashfs > wine-portable.sh
chmod +x wine-portable.sh

mv wine-portable.sh "${script_dir}"
cd "${script_dir}" && rm -r wine-portable

clear
echo "wine-portable.sh created and ready to use!"
