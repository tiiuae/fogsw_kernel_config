This repo contains Linux Kernel configurations of FOG drone. <br>
Current version compiles Linux Kernel sources from Ubuntu repositories. FOG drone does not have own repository yet.

# Build instructions in local machine
## Install dependencies
```
sudo sed -i "s/# deb-src http\:\/\/archive\.ubuntu\.com\/ubuntu\/ focal main restricted/deb-src http:\/\/archive.ubuntu.com\/ubuntu\/ focal main restricted/g" /etc/apt/sources.list \
sudo sed -i "s/# deb-src http\:\/\/archive\.ubuntu\.com\/ubuntu\/ focal-updates main restricted/deb-src http:\/\/archive.ubuntu.com\/ubuntu\/ focal-updates main restricted/g" /etc/apt/sources.list \
sudo apt-get update -y && apt-get install -y --install-recommends \
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
    autoconf
```
## Download sources
NOTE: do not run the following command with sudo.
```
apt-get source linux-hwe-5.8-source-5.8.0
```

## Configure kernel
NOTE: configuration used in the example is *x86_kvm_release*.
```
./config/defconfig_builder.sh -k ./linux-hwe-5.8-5.8.0/ -t x86_kvm_release
```

## Build debian package containing Linux Kernel image
```
cd linux-hwe-5.8-5.8.0/
make x86_kvm_release_defconfig
fakeroot make-kpkg --initrd --revision=1.0.custom --jobs $(nproc) kernel_image
```
The output will be a debian package.


# Build instructions using Docker
## Build docker image
```
docker build -t fogsw-kernel-build .
```

## Run build container
```
docker run --rm -i --name fogsw-kernel-builder -v $(pwd)/config:/build/config -t fogsw-kernel-build:latest /bin/bash
```

## Configure kernel
See [Configure kernel](README.md#Configure-kernel).

## Build debian package containing Linux Kernel image
See [Build debian package containing Linux Kernel image](README.md#Build-debian-package-containing-Linux-Kernel-image)

## Copy debian package from container
```
docker cp fogsw-kernel-builder:/build/linux-image-5.8.18_1.0.custom_amd64.deb linux-image-5.8.18_1.0.custom_amd64.deb
```
