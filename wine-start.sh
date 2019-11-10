#!/usr/bin/env bash

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -z "$DISABLE_RUNTIME" ]; then
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${script_dir}/wine-runtime/lib:${script_dir}/wine-runtime/lib32"
fi

"${script_dir}"/wine/bin/wine "$@"
"${script_dir}"/wine/bin/wineserver -w
