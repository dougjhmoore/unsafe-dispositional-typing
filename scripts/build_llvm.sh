#!/usr/bin/env bash
set -euo pipefail

# ---------------- configuration ----------------
PLUGIN=/tmp/plugin-build/libDispositionalPass.so      # ← only this path!
SRC_DIR=/data/benchmarks/llvm-test-suite
BUILD_DIR=$SRC_DIR/build

# 1. start with a clean build directory -----------
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd       "$BUILD_DIR"

# 2. configure test-suite so every compile uses our pass plug-in
cmake -G Ninja "$SRC_DIR" \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DCMAKE_C_FLAGS="\
      -fexperimental-new-pass-manager \
      -fpass-plugin=$PLUGIN \
      -mllvm -passes=dispositional-pass" \
  -DCMAKE_CXX_FLAGS="\
      -fexperimental-new-pass-manager \
      -fpass-plugin=$PLUGIN \
      -mllvm -passes=dispositional-pass"

# 3. build everything & capture stdout -----------
ninja | tee /data/benchmarks/llvm/llvm_raw.log

# 4. extract the 6-column CSV lines -------------
mkdir -p /data/benchmarks/llvm
grep -E '([^,]*,){5}[^,]*' /data/benchmarks/llvm/llvm_raw.log \
  > /data/benchmarks/llvm/llvm_results.csv
echo "CSV written to benchmarks/llvm/llvm_results.csv"
