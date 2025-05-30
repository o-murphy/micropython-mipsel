cd micropython

source ../ci.sh && ci_unix_qemu_mipsel_setup
source ../ci.sh && ci_unix_qemu_mipsel_build
source ../ci.sh && ci_unix_qemu_mipsel_run_tests

cd ../
mkdir -p build
echo "*" > build/.gitignore
cp micropython/mpy-cross/build/mpy-cross build/mpy-cross
cp micropython/ports/unix/build-coverage/micropython build/micropython
chmod +x build/*

ls build

