#!/bin/bash
# Debug script for dispositional typing Docker build

set -euo pipefail

echo "=== Dispositional Typing Build Diagnostics ==="
echo "Date: $(date)"
echo "PWD: $(pwd)"
echo ""

# Check if we're in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "✅ Running in WSL"
else
    echo "⚠️  Not detected as WSL - make sure Docker Desktop is running"
fi

echo ""
echo "=== Pre-build Checks ==="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found - install Docker Desktop for Windows"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon not running - start Docker Desktop"
    exit 1
fi

echo "✅ Docker daemon running"

# Check current directory structure
echo ""
echo "=== Directory Structure Check ==="
echo "Current directory contents:"
ls -la

if [[ ! -f "Dockerfile" ]]; then
    echo "❌ Dockerfile not found in current directory"
    exit 1
fi

if [[ ! -d "plugin" ]]; then
    echo "❌ plugin/ directory not found"
    exit 1
fi

if [[ ! -d "scripts" ]]; then
    echo "❌ scripts/ directory not found"  
    exit 1
fi

echo "✅ Required directories found"

# Check plugin files
echo ""
echo "=== Plugin Files Check ==="
if [[ -f "plugin/DispositionalPass.cpp" ]]; then
    echo "✅ DispositionalPass.cpp found ($(wc -l < plugin/DispositionalPass.cpp) lines)"
else
    echo "❌ DispositionalPass.cpp missing"
fi

if [[ -f "plugin/CMakeLists.txt" ]]; then
    echo "✅ CMakeLists.txt found"
else
    echo "❌ CMakeLists.txt missing"
fi

# Test Docker build in stages
echo ""
echo "=== Stage 1: Testing Base Image ==="
echo "Building base Ubuntu with LLVM..."

cat > Dockerfile.test << 'EOF'
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget gnupg software-properties-common
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main"
RUN apt-get update && apt-get install -y clang-17 llvm-17-dev cmake ninja-build
RUN llvm-config-17 --version
EOF

if docker build -f Dockerfile.test -t test-base . ; then
    echo "✅ Base image builds successfully"
    docker rmi test-base
    rm Dockerfile.test
else
    echo "❌ Base image build failed"
    rm Dockerfile.test
    exit 1
fi

echo ""
echo "=== Stage 2: Testing Plugin Build ==="
echo "Attempting full build..."

# Clean any existing images
docker rmi unsafe_algebra_test 2>/dev/null || true

if docker build -t unsafe_algebra_test . 2>&1 | tee build.log; then
    echo "✅ Docker build completed"
    
    # Test the plugin
    echo ""
    echo "=== Testing Plugin Load ==="
    if docker run --rm unsafe_algebra_test bash -c "
        find /usr/local/lib/llvm-plugins -name '*.so' && 
        ls -la /usr/local/lib/llvm-plugins/
    "; then
        echo "✅ Plugin appears to be built correctly"
    else
        echo "❌ Plugin not found in expected location"
    fi
    
else
    echo "❌ Docker build failed"
    echo ""
    echo "=== Error Analysis ==="
    if [[ -f "build.log" ]]; then
        echo "Last 20 lines of build log:"
        tail -20 build.log
        echo ""
        echo "Searching for specific errors:"
        grep -i "error\|failed\|cannot" build.log | head -10
    fi
    exit 1
fi

echo ""
echo "=== Build Complete! ==="
echo "Next steps:"
echo "1. Run: docker run -it --rm -v \$PWD:/data unsafe_algebra_test"
echo "2. Inside container: /scripts/driver.sh --fetch"
echo "3. Then: /scripts/driver.sh --all"