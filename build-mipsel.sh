extract_versions() {
  # Define the architecture
  ARCH="mipsel"

  # Function to extract Micropython version using awk (try adjusted pattern)
  extract_version() {
    "$1" --version 2>&1 | awk '/MicroPython/ {for (i=2; i<=NF; i++) if ($i ~ /^v[0-9]+\./) {print $i; exit}}' || echo "unknown"
  }

  # Extract Micropython version
  "./build/micropython" --version 
  MICROPYTHON_VERSION=$(extract_version "./build/micropython")
  echo "Micropython Version: $MICROPYTHON_VERSION"
  MICROPYTHON_FILENAME="micropython-${ARCH}-${MICROPYTHON_VERSION}"
  mv build/micropython "build/$MICROPYTHON_FILENAME"
  echo "Renamed build/micropython to build/$MICROPYTHON_FILENAME"
  echo "micropython_version=$MICROPYTHON_VERSION"
  echo "micropython_arch=$ARCH"

  # Extract mpy-cross version
  "./build/mpy-cross" --version 
  MPYCROSS_VERSION=$(extract_version "./build/mpy-cross")
  echo "mpy-cross Version: $MPYCROSS_VERSION"
  MPYCROSS_FILENAME="mpy-cross-${ARCH}-${MPYCROSS_VERSION}"
  mv build/mpy-cross "build/$MPYCROSS_FILENAME"
  echo "Renamed build/mpy-cross to build/$MPYCROSS_FILENAME"
  echo "mpycross_version=$MPYCROSS_VERSION"
  echo "mpycross_arch=$ARCH"
}

cd micropython

echo "DEBUG: Git status in micropython submodule:"
git status
echo "DEBUG: Git describe --tags --always --dirty in micropython submodule:"
git describe --tags --always --dirty

# Setup, build, and run tests
source ../ci.sh && ci_unix_qemu_mipsel_setup
source ../ci.sh && ci_unix_qemu_mipsel_build
source ../ci.sh && ci_unix_qemu_mipsel_run_tests

cd ../
mkdir -p build
echo "*" > build/.gitignore
cp micropython/mpy-cross/build/mpy-cross build/mpy-cross
cp micropython/ports/unix/build-coverage/micropython build/micropython
chmod +x build/*
extract_versions
ls build
