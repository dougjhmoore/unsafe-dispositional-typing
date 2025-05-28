#!/usr/bin/env bash
set -euo pipefail

# ---------------- configuration ----------------
PLUGIN=/tmp/plugin-build/libDispositionalPass.so    # path built in Dockerfile
SRC_DIR=/data/benchmarks/llvm-test-suite
BUILD_DIR=$SRC_DIR/build

# 1. clean build dir ---------------------------------------------------------
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd       "$BUILD_DIR"

# 2. configure all test-suite targets ---------------------------------------
cmake -G Ninja "$SRC_DIR" \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \

# 3. build & capture log -----------------------------------------------------
ninja | tee /data/benchmarks/llvm/llvm_raw.log

# 4. extract six-column CSV lines emitted by the pass ------------------------
mkdir -p /data/benchmarks/llvm
grep -E '([^,]*,){5}[^,]*' /data/benchmarks/llvm/llvm_raw.log \
  > /data/benchmarks/llvm/llvm_results.csv

echo "CSV written to benchmarks/llvm/llvm_results.csv"
