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
* libgcc1 (gcc-libs)
* libasound2 (sound libraries)
* libgl (videodriver)
* libgnutls30
* libgmp10
* libvulkan1 (if you want to use DXVK/D9VK or run Vulkan games)

It's important to install both the 32-bit and 64-bit versions of these libraries.

**GLIBC 2.27** or newer is required as the runtime is from Ubuntu 18.04.

---

## How to use portable Wine executables

You can download ready-to-use portable Wine/Proton executables from the [releases](https://github.com/Kron4ek/wine-portable-executable/releases) page.

Root rights are **not required**!

Make the script executable and run it. For example:

    chmod +x wine-portable-4.19-staging-amd64.sh
    ./wine-portable-4.19-staging-amd64.sh application.exe

To run winecfg (you can run regedit the same way):

    ./wine-portable-4.19-staging-amd64.sh winecfg
    
For testing purposes or if installing libraries is not a problem for you (but you like SquashFS and the idea of a single Wine executable), you can disable the included libraries (runtime), in which case Wine will use only system libraries:

    export DISABLE_RUNTIME=1
    ./wine-portable-4.19-staging-amd64.sh application.exe

---

## How to create portable Wine executables

Use **create_wine_portable.sh**. 

This script will use ready-to-use binaries to create portable Wine executable.

If you want to create a runtime, squashfuse and Wine build from the scratch, then read the next section below.

---

## From the scratch / Sources

All components used in this project (the runtime, the squashfuse and the Wine builds) were created using the official sources.

For my and your convenience i regularly upload ready-to-use runtime, squashfuse and Wine builds.

If you want, you can create everything yourself using the available scripts.

Available scripts:

* **create_ubuntu_chroots.sh** creates two Ubuntu chroots (32-bit and 64-bit).
* **build_wine.sh** compiles Wine builds using two Ubuntu chroots (32-bit and 64-bit).
* **create_wine_runtime.sh** creates runtime by copying libraries from two Ubuntu chroots (32-bit and 64-bit).
* **build_squashfuse.sh** compiles squashfuse, lz4 and zstd in 64-bit Ubuntu chroot and creates squashfuse.tar with them included.

The first two scripts are available in another my project: https://github.com/Kron4ek/Wine-Builds

---

### Notes

Keep in mind that this project is new and it has not been thoroughly tested. Please report any problems you find.
