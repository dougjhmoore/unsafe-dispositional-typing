FROM ubuntu:22.04

# ---- install LLVM tool-chain (17) -----------------------------------------
RUN apt-get update && apt-get install -y wget gnupg software-properties-common
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository \
    "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main"

# ---- essential packages, incl. LLVM 17 ------------------------------------

RUN apt-get update && apt-get install -y \
    clang-17 llvm-17 llvm-17-dev lld-17 llvm-17-tools \
    libffi-dev libedit-dev libncurses-dev \
    tcl tk expect                         \
    git cmake ninja-build python3 python3-pip wget curl time zip




# build the Dispositional plug-in
COPY plugin /src/plugin
RUN rm -rf /src/plugin/build /src/plugin/CMakeCache.txt /src/plugin/CMakeFiles
RUN mkdir -p /tmp/plugin-build && \
    cmake -S /src/plugin -B /tmp/plugin-build -G Ninja \
          -DLLVM_DIR=/usr/lib/llvm-17/lib/cmake/llvm \
 && cmake --build /tmp/plugin-build --target DispositionalPass


# ---- copy driver scripts ---------------------------------------------------
COPY scripts /scripts

WORKDIR /data
ENTRYPOINT ["/bin/bash"]