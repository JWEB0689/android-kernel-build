FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    bc \
    bison \
    flex \
    git \
    curl \
    wget \
    openssh-client \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-dev \
    clang \
    lld \
    llvm \
    android-sdk-build-tools \
    device-tree-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global user.email "builder@lineage.local" && \
    git config --global user.name "Lineage Builder"

WORKDIR /build

COPY build.sh /build/build.sh
RUN chmod +x /build/build.sh

ENTRYPOINT ["/build/build.sh"]
