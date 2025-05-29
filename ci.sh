#!/bin/bash

if which nproc > /dev/null; then
    MAKEOPTS="-j$(nproc)"
else
    MAKEOPTS="-j$(sysctl -n hw.ncpu)"
fi

# Ensure known OPEN_MAX (NO_FILES) limit.
ulimit -n 1024

CI_UNIX_OPTS_QEMU_MIPSEL=(
    CROSS_COMPILE=mipsel-linux-gnu-
    VARIANT=coverage
    MICROPY_STANDALONE=1
)

function ci_unix_build_helper {
    make ${MAKEOPTS} -C mpy-cross
    make ${MAKEOPTS} -C ports/unix "$@" submodules
    make ${MAKEOPTS} -C ports/unix "$@" clean
    make ${MAKEOPTS} -C ports/unix "$@" deplibs
    make ${MAKEOPTS} -C ports/unix "$@"
}

function ci_unix_build_ffi_lib_helper {
    $1 $2 -shared -o tests/ports/unix/ffi_lib.so tests/ports/unix/ffi_lib.c
}

function ci_unix_qemu_mipsel_setup {
    sudo apt-get update
    sudo apt-get install build-essential git python3 pkg-config libffi-dev
    sudo apt install autoconf libtool
    sudo apt-get install gcc-mipsel-linux-gnu g++-mipsel-linux-gnu libc6-mipsel-cross
    sudo apt-get install qemu-user
    qemu-mipsel --version
    sudo mkdir /etc/qemu-binfmt
    sudo ln -s /usr/mipsel-linux-gnu/ /etc/qemu-binfmt/mipsel
}

function ci_unix_qemu_mipsel_build {
    ci_unix_build_helper "${CI_UNIX_OPTS_QEMU_MIPSEL[@]}"
    ci_unix_build_ffi_lib_helper mipsel-linux-gnu-gcc
}

function ci_unix_qemu_mipsel_run_tests {
    file ./ports/unix/build-coverage/micropython
    (cd tests && MICROPY_MICROPYTHON=../ports/unix/build-coverage/micropython ./run-tests.py)
}
