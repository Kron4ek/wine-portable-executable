## Description

This project allows you to pack Wine and almost all of its required libraries into a single portable executable that should work on most Linux distributions. This project uses SquashFS as the container for Wine and its libraries (similar to what AppImage does).

What are the benefits compared to regular Wine builds? The main benefit is that fewer libraries need to be installed. Another benefit is that SquashFS supports fast compression algorithms (such as lz4 or zstd), so Wine can launch faster and use less disk space.

This is the structure of the portable executables generated (from the beginning to the end of the file):

1. A script that mounts the bundled squashfs image and runs Wine
2. The squashfuse binary and its libraries, in case squashfuse isn't installed
3. The squashfs image that contains Wine, its required libraries (wine-runtime)
and a custom launch script

---

## Requirements

First of all, **FUSE** is required.

Despite that most required libraries are included into the squashfs image, some libraries still need to be installed. This is the list of libraries that need to be installed:

* libc6 (glibc)
* libstdc++6 (gcc-libs)
* libcgcc1 (gcc-libs)
* libasound2 (sound libraries)
* libgl (videodriver)
* libgnutls30
* libgmp10

It's important to install both the 32-bit and 64-bit versions of these libraries.

**GLIBC 2.27** or newer is required as the runtime is from Ubuntu 18.04.

---

## How to use portable Wine executables

Root rights are **not required**!

Make the script executable and run it. For example:

    chmod +x wine-portable-4.19-amd64.sh
    ./wine-portable-4.19-amd64.sh application.exe

Or to run winecfg:

    ./wine-portable-4.19-amd64.sh winecfg
    
You can download ready-to-use portable Wine/Proton executables from the [releases](https://github.com/Kron4ek/wine-portable-executable/releases) page.

---

## How to create portable Wine executables

Use **create_wine_portable.sh**.

---

### Notes

Keep in mind that this project is new and it has not been thoroughly tested. Please report any problems you find.
