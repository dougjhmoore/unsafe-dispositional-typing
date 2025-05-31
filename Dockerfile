FROM ubuntu:22.04

# --------------------------------------------------------------------------
# 1. fast mirrors
RUN sed -i \
      -e 's|http://archive\.ubuntu\.com/ubuntu|http://mirror.init7.net/ubuntu|g' \
      -e 's|http://security\.ubuntu\.com/ubuntu|http://mirror.init7.net/ubuntu|g' \
      /etc/apt/sources.list

# 2. minimal bootstrap tools (wget, gnupg, add-apt-repository)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget gnupg software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# 3. LLVM apt key + repo
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main"

# 4. ***install the real tool-chain BEFORE we build the plug-in***
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        clang-17 llvm-17 llvm-17-dev lld-17 llvm-17-tools \
        libffi-dev libedit-dev libncurses-dev \
        tcl tk expect \
        git cmake ninja-build \
        python3 python3-pip wget curl time zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------------------
# 5. build DispositionalPass out-of-tree
COPY plugin /src/plugin
RUN rm -rf /src/plugin/build /src/plugin/CMake* && \
    mkdir -p /tmp/plugin-build && \
    cmake -S /src/plugin -B /tmp/plugin-build -G Ninja \
          -DLLVM_DIR=/usr/lib/llvm-17/lib/cmake/llvm \
          -DCMAKE_C_COMPILER=clang-17 -DCMAKE_CXX_COMPILER=clang++-17 && \
    cmake --build /tmp/plugin-build --target DispositionalPass

# --------------------------------------------------------------------------
COPY scripts /scripts
RUN chmod +x /scripts/*.sh

WORKDIR /data
ENTRYPOINT ["/bin/bash"]
