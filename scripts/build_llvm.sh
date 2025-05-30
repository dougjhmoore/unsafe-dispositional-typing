#!/usr/bin/env bash
set -euo pipefail

# ---- configuration ----
PLUGIN=/tmp/plugin-build/libDispositionalPass.so
SRC_DIR=/data/benchmarks/llvm-test-suite
BUILD_DIR=$SRC_DIR/build

# 1. clean slate
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 2. configure, disabling code size & sqlite, enabling new pass manager
cmake -G Ninja "$SRC_DIR" \
  -DLLVM_USE_LINKER=lld \
  -DTEST_SUITE_COLLECT_CODE_SIZE=OFF \
  -DTEST_SUITE_ENABLE_SQLITE=OFF \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DCMAKE_C_FLAGS="\
    -fexperimental-new-pass-manager \
    -fpass-plugin=$PLUGIN \
    -mllvm=-passes=dispositional-pass" \
  -DCMAKE_CXX_FLAGS="\
    -fexperimental-new-pass-manager \
    -fpass-plugin=$PLUGIN \
    -mllvm=-passes=dispositional-pass"

# 3. build just the lit/runtests driver
cmake --build . --target check-all
