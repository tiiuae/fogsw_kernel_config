# fog-sw BUILDER
FROM ros:foxy-ros-base as fog-sw-builder

ARG BUILD_NUMBER
ARG DISTRIBUTION
ARG ARCHITECTURE
ARG COMMIT_ID
ARG GIT_VER
ARG PACKAGE_SUBDIR
ARG MODULE_GEN_CONFIG
ARG ROS

# workaround for ROS GPG Key Expiration Incident
RUN rm /etc/apt/sources.list.d/ros2-latest.list && \
    apt-get update && \
    apt-get install -y curl && \
    curl http://repo.ros2.org/repos.key | sudo apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu focal main" > /etc/apt/sources.list.d/ros2-latest.list && \
    apt-get update

RUN echo "deb [trusted=yes] https://artifactory.ssrc.fi/artifactory/debian-public-local focal fog-sw" >> /etc/apt/sources.list

# Install build dependencies
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    dh-make debhelper \
    cmake \
    git-core \
    fakeroot \
    python3-bloom \
    && rm -rf /var/lib/apt/lists/*

### INCLUDE_DEPENDENCIES
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Helsinki"

RUN apt-get update -y && apt-get install -y --install-recommends \
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
    && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/# deb-src http\:\/\/archive\.ubuntu\.com\/ubuntu\/ focal main restricted/deb-src http:\/\/archive.ubuntu.com\/ubuntu\/ focal main restricted/g" /etc/apt/sources.list \
    && sed -i "s/# deb-src http\:\/\/archive\.ubuntu\.com\/ubuntu\/ focal-updates main restricted/deb-src http:\/\/archive.ubuntu.com\/ubuntu\/ focal-updates main restricted/g" /etc/apt/sources.list \
    && apt-get update -y

WORKDIR /build
RUN git clone https://github.com/tiiuae/linux.git -b tc-x86-5.10-sec

WORKDIR /build

COPY . .

RUN params="-m $(realpath .) " \
    && [ ! "${BUILD_NUMBER}" = "" ] && params="$params -b ${BUILD_NUMBER}" || : \
    && [ ! "${DISTRIBUTION}" = "" ] && params="$params -d ${DISTRIBUTION}" || : \
    && [ ! "${ARCHITECTURE}" = "" ] && params="$params -a ${ARCHITECTURE}" || : \
    && [ ! "${COMMIT_ID}" = "" ] && params="$params -c ${COMMIT_ID}" || : \
    && [ ! "${GIT_VER}" = "" ] && params="$params -g ${GIT_VER}" || : \
    && [ ! "${PACKAGE_SUBDIR}" = "" ] && params="$params -s ${PACKAGE_SUBDIR}" || : \
    && [ ! "${ROS}" = "" ] && params="$params -r" || : \
    && [ ! "${MODULE_GEN_CONFIG}" = "" ] && params="$params -k ${MODULE_GEN_CONFIG}" || : \
    && ./${PACKAGE_SUBDIR}/packaging/common/package.sh $params

FROM scratch
COPY --from=fog-sw-builder /*.deb /packages/
