#!/usr/bin/env bash
set -euo pipefail

DEST=/data/benchmarks/llvm-test-suite      # where the repo lives inside the image

if [ -d "$DEST/.git" ]; then
    echo "LLVM test-suite already fetched – pulling latest..."
    git -C "$DEST" pull --ff-only
else
    echo "Cloning LLVM test-suite..."
    git clone --depth 1 https://github.com/llvm/llvm-test-suite.git "$DEST"
fi

echo "Fetch step complete."
