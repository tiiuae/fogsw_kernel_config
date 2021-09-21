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
    autoconf \
    git
```
## Download sources
```
git clone https://github.com/tiiuae/linux.git -b <branch>
```
<branch> = tc-x86-5.10-dev|tc-x86-5.10-sec
<br>
If you don't need hardened kernel version, then you can use the following command which will download kernel sources from Ubuntu repositories.
<br>
NOTE: do not run the following command with sudo.
```
apt-get source linux-hwe-5.11-source-5.11.0
```

## Configure kernel
```
./config/defconfig_builder.sh -k ./linux -t x86_debug
```
Other configurations are: x86_kvm_release, x86_kvm_guest_release, x86_kvm_secure_release, x86_kvm_guest_secure_release and fog.
If you are using sources from Ubuntu repositories, then use the following command.
NOTE: configuration used in the example is *x86_kvm_release*.
```
./config/defconfig_builder.sh -k ./linux-hwe-5.11-5.11.0/ -t x86_debug
```

## Build debian package containing Linux Kernel image
```
cd linux/
make x86_debug_defconfig
fakeroot make-kpkg --initrd --revision=1 --jobs $(nproc) kernel_image
```
If you are using sources from Ubuntu repositories, then use the following command.
```
cd linux-hwe-5.11-5.11.0/
make x86_debug_defconfig
fakeroot make-kpkg --initrd --revision=1 --jobs $(nproc) kernel_image
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
docker cp fogsw-kernel-builder:/build/linux-image-5.11.22+fog_1_amd64.deb linux-image-5.11.22+fog_1_amd64.deb
```
Or the following command depending on the sources and platform you have used.
```
docker cp fogsw-kernel-builder:/build/linux-image-5.11.22_1_amd64.deb linux-image-5.11.22_1_amd64.deb
```
