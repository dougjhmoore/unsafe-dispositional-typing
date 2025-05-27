#build_llvm.sh
#!/usr/bin/env bash
set -e
BUILD=/data/benchmarks/llvm-test-suite/build
mkdir -p "$BUILD" && cd "$BUILD"
cmake -G Ninja .. \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DLLVM_PLUGIN=/src/plugin/build/DispositionalPass.so \
  -DCMAKE_C_FLAGS="-fpass-plugin=/src/plugin/build/DispositionalPass.so -mllvm -passes=dispositional-pass"
cmake --build . --target test-suite                                           # compiles everything
echo "benchmark,function,unsafe_blocks,unsafe_removed,edges,cycles,commuting_cycles,time_ms" \
   > /data/benchmarks/llvm_results.csv                                         # placeholder CSV
