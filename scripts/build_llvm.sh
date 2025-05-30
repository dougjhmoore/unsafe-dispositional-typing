#!/usr/bin/env bash
set -euo pipefail

PLUGIN=/tmp/plugin-build/libDispositionalPass.so
SRC_DIR=/data/benchmarks/llvm-test-suite
BUILD_DIR=$SRC_DIR/build

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake -G Ninja "$SRC_DIR" \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DCMAKE_C_FLAGS="\
    -fpass-plugin=$PLUGIN \
    -mllvm -passes=dispositional-pass" \
  -DCMAKE_CXX_FLAGS="\
    -fpass-plugin=$PLUGIN \
    -mllvm -passes=dispositional-pass" \
  -DTEST_SUITE_COLLECT_CODE_SIZE=OFF \
  -DTEST_SUITE_ENABLE_SQLITE=OFF

ninja -j"$(nproc)"
ctest -j"$(nproc)" --output-on-failure
