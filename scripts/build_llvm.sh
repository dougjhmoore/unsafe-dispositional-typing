#!/usr/bin/env bash
set -euo pipefail

PLUGIN=/tmp/plugin-build/libDispositionalPass.so        # <-- correct path
BUILD_DIR=/data/benchmarks/llvm-test-suite/build
SRC_DIR=/data/benchmarks/llvm-test-suite

mkdir -p "$BUILD_DIR"
cd       "$BUILD_DIR"

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

ninja | tee /data/benchmarks/llvm/llvm_raw.log
grep -E '([^,]*,){5}[^,]*' /data/benchmarks/llvm/llvm_raw.log \
  > /data/benchmarks/llvm/llvm_results.csv
echo "CSV written to benchmarks/llvm/llvm_results.csv"
