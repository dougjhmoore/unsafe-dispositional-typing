#!/usr/bin/env bash
set -euo pipefail

# ---------------- configuration ----------------
PLUGIN=/tmp/plugin-build/libDispositionalPass.so
SRC_DIR=/data/benchmarks/llvm-test-suite
BUILD_DIR=$SRC_DIR/build

# 1. start with a clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd       "$BUILD_DIR"

# 2. configure the test suite so every compile uses our pass plug-in,
#    and disable both code-size collection and the SQLite/Tcl tests.
cmake -G Ninja "$SRC_DIR" \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DCMAKE_C_FLAGS="\
    -fpass-plugin=$PLUGIN \
    -mllvm=-passes=dispositional-pass" \
  -DCMAKE_CXX_FLAGS="\
    -fpass-plugin=$PLUGIN \
    -mllvm=-passes=dispositional-pass" \
  -DTEST_SUITE_COLLECT_CODE_SIZE=OFF \
  -DTEST_SUITE_ENABLE_SQLITE=OFF

# 3. build
ninja -j"$(nproc)"

# 4. run all the benchmarks/tests and emit the CSV
#    (this is whatever your existing script does—e.g. lit or ctest)
ctest -j"$(nproc)" --output-on-failure
