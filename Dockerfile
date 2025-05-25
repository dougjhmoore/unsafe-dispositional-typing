FROM ubuntu:22.04

# essential packages
RUN apt-get update && apt-get install -y \
    clang-17 llvm-17 llvm-17-dev lld-17 \
    git cmake ninja-build python3 python3-pip wget curl time zip

# build the Dispositional plug-in
COPY plugin /src/plugin
RUN cmake -S /src/plugin -B /src/plugin/build -G Ninja \
 && cmake --build /src/plugin/build --target DispositionalPass

# copy driver scripts
COPY scripts /scripts

# default working directory when you run the container
WORKDIR /data

ENTRYPOINT ["/bin/bash"]

