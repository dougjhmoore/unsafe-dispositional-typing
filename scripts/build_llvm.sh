#!/usr/bin/env bash
set -euo pipefail
## build_llvm.sh ##
# ---------------------------------------------------------------------------
# Paths inside the Docker image
# ---------------------------------------------------------------------------
PLUGIN=/tmp/plugin-build/libDispositionalPass.so           # built in Dockerfile
SRC_DIR=/data/benchmarks/llvm-test-suite                   # git-cloned by driver
BUILD_DIR=$SRC_DIR/build

# ---------------------------------------------------------------------------
# 1.  Start fresh: remove any stale CMake cache
# ---------------------------------------------------------------------------
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd       "$BUILD_DIR"

# ---------------------------------------------------------------------------
# 2.  Configure test-suite with the Dispositional pass plugged into clang-17
#     -  new pass manager flag is mandatory for -passes=…
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# 3.  Build every benchmark; tee stdout so we can grep CSV later
# ---------------------------------------------------------------------------
ninja | tee /data/benchmarks/llvm/llvm_raw.log

# ---------------------------------------------------------------------------
# 4.  Extract CSV lines (6 comma-separated columns) emitted by our pass
# ---------------------------------------------------------------------------
mkdir -p /data/benchmarks/llvm
grep -E '([^,]*,){5}[^,]*' /data/benchmarks/llvm/llvm_raw.log \
  > /data/benchmarks/llvm/llvm_results.csv

echo "CSV written to benchmarks/llvm/llvm_results.csv"
