#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
PLUGIN=/tmp/plugin-build/libDispositionalPass.so     # path produced in Dockerfile
BUILD_DIR=/data/benchmarks/llvm-test-suite/build
SRC_DIR=/data/benchmarks/llvm-test-suite

mkdir -p "$BUILD_DIR"
cd       "$BUILD_DIR"

# ---------------------------------------------------------------------------
# Configure with CMake + Ninja
# ---------------------------------------------------------------------------
cmake -G Ninja "$SRC_DIR" \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DLLVM_PLUGIN="$PLUGIN" \
  -DCMAKE_C_FLAGS="-fpass-plugin=$PLUGIN -mllvm -passes=dispositional-pass" \
  -DCMAKE_CXX_FLAGS="-fpass-plugin=$PLUGIN -mllvm -passes=dispositional-pass"

# ---------------------------------------------------------------------------
# Build the whole test-suite; capture stdout for CSV extraction
# ---------------------------------------------------------------------------
ninja | tee /data/benchmarks/llvm/llvm_raw.log

# ---------------------------------------------------------------------------
# Extract CSV lines (comma appears 5 times → 6 columns)
# ---------------------------------------------------------------------------
mkdir -p /data/benchmarks/llvm
grep -E '([^,]*,){5}[^,]*' /data/benchmarks/llvm/llvm_raw.log \
  > /data/benchmarks/llvm/llvm_results.csv
echo "CSV written to benchmarks/llvm/llvm_results.csv"
