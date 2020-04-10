#!/usr/bin/env bash

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -z "$DISABLE_RUNTIME" ]; then
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${script_dir}/wine-runtime/lib:${script_dir}/wine-runtime/lib32"
fi

export WINE="${script_dir}"/wine/bin/wine
export WINE64="${script_dir}"/wine/bin/wine64
export WINESERVER="${script_dir}"/wine/bin/wineserver
export WINETRICKS="${script_dir}"/winetricks

if [ "$1" = "winetricks" ]; then
	if [ $# -ge 2 ]; then
		shift
		"${WINETRICKS}" "$@"
	else
		"${WINETRICKS}" --help
	fi
else
	"${WINE}" "$@"
	"${WINESERVER}" -w
fi
