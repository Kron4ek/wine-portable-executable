#!/usr/bin/env bash

## Required packages: squashfs-tools wget

export working_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/wine-standalone

wine_url="https://github.com/Kron4ek/Wine-Builds/releases/download/4.19/wine-4.19-staging-amd64.tar.xz"
wine_runtime_url="https://github.com/Kron4ek/wine-portable-executable/raw/master/wine-runtime.tar.xz"
wine_start_script_url="https://raw.githubusercontent.com/Kron4ek/wine-portable-executable/master/wine-start.sh"
squashfs_start_script_url="https://raw.githubusercontent.com/Kron4ek/wine-portable-executable/master/squashfs-start.sh"
squashfuse_archive_url="https://github.com/Kron4ek/wine-portable-executable/raw/master/squashfuse.tar"

mkdir -p "${working_dir}"/squashfs-root

cd "${working_dir}"/squashfs-root || exit 1

if  [ ! -d wine ]; then
	wget -nv -O wine.tar.xz "${wine_url}" -q --show-progress
	tar xf wine.tar.xz
	rm wine.tar.xz
	mv wine* wine
fi

if [ ! -d wine-runtime ]; then
	wget -O wine-runtime.tar.xz "${wine_runtime_url}" -q --show-progress
	tar xf wine-runtime.tar.xz
	rm wine-runtime.tar.xz
fi

if [ ! -f wine.sh ]; then
	wget -O wine.sh "${wine_start_script_url}" -q --show-progress
	chmod +x wine.sh
fi

cd "${working_dir}"

if [ ! -f squashfuse.tar ]; then
	wget -O squashfuse.tar "${squashfuse_archive_url}" -q --show-progress
fi

if [ ! -f squashfs-start.sh ]; then
	wget -O squashfs-start.sh "${squashfs_start_script_url}" -q --show-progress
	chmod +x squashfs-start.sh
fi

echo "Creating portable Wine executable..."
mksquashfs squashfs-root wine.squashfs -comp lz4 -Xhc

cat squashfs-start.sh squashfuse.tar wine.squashfs > wine-standalone.sh
chmod +x wine-standalone.sh

echo "Done"
