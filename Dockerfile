# Dockerfile for Dispositional Typing - IEEE TSE 2025
# Pre-built environment for easy reviewer reproduction

FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # LLVM 17 and development tools
    wget \
    gnupg \
    software-properties-common \
    build-essential \
    cmake \
    git \
    # Python environment
    python3 \
    python3-pip \
    python3-venv \
    # Utilities
    tree \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add LLVM 17 repository and install
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
    llvm-17 \
    llvm-17-dev \
    clang-17 \
    libclang-17-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up LLVM environment
ENV LLVM_DIR=/usr/lib/llvm-17
ENV PATH="/usr/lib/llvm-17/bin:${PATH}"

# Create working directory
WORKDIR /dispositional-typing

# Copy project files
COPY . .

# Set up Python environment
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r scripts/requirements.txt

# Pre-build the Clang plugin to save reviewer time
RUN . venv/bin/activate && \
    cd tools/clang-plugin && \
    mkdir -p build && \
    cd build && \
    cmake -DLLVM_DIR=/usr/lib/llvm-17/lib/cmake/llvm .. && \
    make

# Create convenience scripts
RUN echo '#!/bin/bash\n\
cd /dispositional-typing\n\
. venv/bin/activate\n\
exec "$@"' > /usr/local/bin/run-analysis && \
    chmod +x /usr/local/bin/run-analysis

# Set default command
CMD ["/bin/bash"]

# Labels for metadata
LABEL maintainer="Douglas J. Huntington Moore <djhmoore@alumni.unimelb.edu.au>"
LABEL description="Dispositional Typing: IEEE TSE 2025 Reproducibility Container"
LABEL version="1.0"
LABEL paper="Dispositional Typing: Eliminating Unsafe Annotations in C, C++, and Rust"
