# Dispositional Typing Analysis Environment - Network Resilient
FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Network resilience: Use multiple mirror strategies and retry logic
RUN echo "Trying multiple Ubuntu mirror strategies..." && \
    # Try US mirrors first, then fallback strategies
    (sed -i 's|http://archive.ubuntu.com/ubuntu|http://us.archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list || true) && \
    (sed -i 's|http://security.ubuntu.com/ubuntu|http://security.ubuntu.com/ubuntu|g' /etc/apt/sources.list || true) && \
    \
    # Add timeout and retry settings for apt
    echo 'Acquire::http::Timeout "60";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::http::Pipeline-Depth "0";' >> /etc/apt/apt.conf.d/99timeout && \
    \
    # Multiple update attempts with different strategies
    (apt-get update -o Acquire::ForceIPv4=true || \
     apt-get update -o Acquire::http::No-Cache=true || \
     apt-get update) && \
    \
    # Install minimal base packages first
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Second stage: Add repositories and install development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    python3 \
    software-properties-common \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Third stage: LLVM installation with fallback
RUN echo "Installing LLVM 17..." && \
    # Try LLVM official repository first
    (wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
     echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" > /etc/apt/sources.list.d/llvm.list && \
     apt-get update && \
     apt-get install -y --no-install-recommends \
        llvm-17 \
        llvm-17-dev \
        llvm-17-tools \
        clang-17 \
        clang-tools-17 \
        lld-17) || \
    \
    # Fallback: Install from Ubuntu repos (older version but works)
    (apt-get update && \
     apt-get install -y --no-install-recommends \
        llvm-14 \
        llvm-14-dev \
        llvm-14-tools \
        clang-14 \
        clang-tools-14 \
        lld-14 && \
     # Create symlinks for version compatibility
     ln -sf /usr/bin/llvm-config-14 /usr/bin/llvm-config-17 && \
     ln -sf /usr/bin/clang-14 /usr/bin/clang-17 && \
     ln -sf /usr/bin/clang++-14 /usr/bin/clang++-17 && \
     ln -sf /usr/bin/lld-14 /usr/bin/lld-17) \
    && rm -rf /var/lib/apt/lists/*

# Set up LLVM environment (works with either version)
ENV LLVM_CONFIG=llvm-config-17
ENV CC=clang-17  
ENV CXX=clang++-17

# Create working directories
RUN mkdir -p /data/results /data/benchmarks /usr/local/lib/llvm-plugins

# Set working directory
WORKDIR /data

# Verify installation and provide diagnostics
RUN echo "=== LLVM Installation Verification ===" && \
    (llvm-config-17 --version || llvm-config-14 --version || echo "LLVM version detection failed") && \
    (clang-17 --version || clang-14 --version || echo "Clang version detection failed") && \
    echo "=== Environment Ready ==="

# Default command
CMD ["bash"]