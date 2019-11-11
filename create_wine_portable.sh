#!/usr/bin/env bash

## Required packages: squashfs-tools wget

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
working_dir="${script_dir}"/wine-portable

# You can change urls below if you want to use different Wine build,
# different runtime or scripts
wine_url="https://github.com/Kron4ek/Wine-Builds/releases/download/4.19/wine-4.19-staging-amd64.tar.xz"
wine_runtime_url="https://github.com/Kron4ek/wine-portable-executable/raw/master/binaries/wine-runtime.tar.xz"
wine_start_script_url="https://raw.githubusercontent.com/Kron4ek/wine-portable-executable/master/wine.sh"
squashfs_start_script_url="https://raw.githubusercontent.com/Kron4ek/wine-portable-executable/master/squashfs-start.sh"
squashfuse_archive_url="https://github.com/Kron4ek/wine-portable-executable/raw/master/binaries/squashfuse.tar"

# Available compressors: gzip, lzma, lzo, lz4, xz, zstd
# See the mksquashfs documentation for more information
squashfs_compressor=lz4
compressor_arguments="-Xhc"

mkdir -p "${working_dir}"/squashfs-root

cd "${working_dir}"/squashfs-root || exit 1

if  [ ! -d wine ]; then
	wget -nv -O wine.tar.xz "${wine_url}" -q --show-progress
	tar xf wine.tar.xz
	rm wine.tar.xz
	mv wine* wine
fi

if [ ! -d wine-runtime ]; then
	if [ ! -f "${script_dir}"/binaries/wine-runtime.tar.xz ]; then
		wget -O wine-runtime.tar.xz "${wine_runtime_url}" -q --show-progress
		tar xf wine-runtime.tar.xz
		rm wine-runtime.tar.xz
	else
		tar xf "${script_dir}"/binaries/wine-runtime.tar.xz
	fi
fi

if [ ! -f wine.sh ]; then
	if [ ! -f "${script_dir}"/wine.sh ]; then
		wget -O wine.sh "${wine_start_script_url}" -q --show-progress
	else
		cp "${script_dir}"/wine.sh .
	fi
	
	chmod +x wine.sh
fi

cd "${working_dir}"

if [ ! -f squashfuse.tar ]; then
	if [ ! -f "${script_dir}"/binaries/squashfuse.tar ]; then
		wget -O squashfuse.tar "${squashfuse_archive_url}" -q --show-progress
	else
		cp "${script_dir}"/binaries/squashfuse.tar .
	fi
fi

if [ ! -f squashfs-start.sh ]; then
	if [ ! -f "${script_dir}"/squashfs-start.sh ]; then
		wget -O squashfs-start.sh "${squashfs_start_script_url}" -q --show-progress
	else
		cp "${script_dir}"/squashfs-start.sh .
	fi
	
	chmod +x squashfs-start.sh
fi

echo
echo "Creating portable Wine executable..."
# Create squashfs image
mksquashfs squashfs-root wine.squashfs -comp $squashfs_compressor $compressor_arguments

# Combine files into a single executable using cat
cat squashfs-start.sh squashfuse.tar wine.squashfs > wine-portable.sh
chmod +x wine-portable.sh

echo "Done"
