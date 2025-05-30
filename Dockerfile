# Dockerfile
FROM ubuntu:22.04

# 1. use a faster mirror for apt
RUN sed -i \
      -e 's|http://archive\.ubuntu\.com/ubuntu|http://mirror.init7.net/ubuntu|g' \
      -e 's|http://security\.ubuntu\.com/ubuntu|http://mirror.init7.net/ubuntu|g' \
    /etc/apt/sources.list

# 2. install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      gnupg \
      software-properties-common \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" \
    && apt-get update && apt-get install -y --no-install-recommends \
      clang-17 \
      clang-tools-17 \
      llvm-17 \
      llvm-17-dev \
      lld-17 \
      libffi-dev \
      libedit-dev \
      libncurses-dev \
      git \
      cmake \
      ninja-build \
      python3 \
      python3-pip \
      dos2unix \
      tcl \
      tk \
      expect \
      zip \
      curl \
      time \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. build LLVM plugin out-of-tree
COPY plugin /src/plugin
RUN rm -rf /src/plugin/build /src/plugin/CMakeCache.txt /src/plugin/CMakeFiles \
 && mkdir -p /tmp/plugin-build \
 && cmake -S /src/plugin -B /tmp/plugin-build -G Ninja \
      -DLLVM_DIR=/usr/lib/llvm-17/lib/cmake/llvm \
 && cmake --build /tmp/plugin-build --target DispositionalPass

# 4. pull in helper scripts
COPY scripts /scripts
RUN chmod +x /scripts/*.sh

WORKDIR /data
ENTRYPOINT ["/bin/bash"]
