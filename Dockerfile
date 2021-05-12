# Kernel source builder.
FROM ubuntu:20.04 as fogsw-kernel-builder

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Helsinki"

# Dependencies needed for kernel build.
# Enable source packages in sources.list.
RUN sed -i "s/# deb-src http\:\/\/archive\.ubuntu\.com\/ubuntu\/ focal main restricted/deb-src http:\/\/archive.ubuntu.com\/ubuntu\/ focal main restricted/g" /etc/apt/sources.list \
    && sed -i "s/# deb-src http\:\/\/archive\.ubuntu\.com\/ubuntu\/ focal-updates main restricted/deb-src http:\/\/archive.ubuntu.com\/ubuntu\/ focal-updates main restricted/g" /etc/apt/sources.list \
    && apt-get update -y && apt-get install -y --install-recommends \
    build-essential \
    kernel-package \
    libncurses-dev \
    gawk \
    flex \
    bison \
    openssl \
    libssl-dev \
    dkms \
    libelf-dev \
    libudev-dev \
    libpci-dev \
    libiberty-dev \
    autoconf \
    git \
    gcc-9-plugin-dev \
    && apt-get clean \
    && apt-get autoremove -y

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /build

RUN git clone https://github.com/tiiuae/linux.git -b tc-x86-5.10-sec
