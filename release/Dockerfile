FROM --platform=linux/amd64 ubuntu:24.04 AS build

# Install build deps (from .github/scripts/utils.zsh/setup_ubuntu)
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential cmake ninja-build git curl ca-certificates jq pkg-config \
  libglib2.0-dev extra-cmake-modules lsb-release \
  libcurl4-openssl-dev \
  libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev \
  libswresample-dev libswscale-dev \
  libjansson-dev libx11-xcb-dev libgles2-mesa-dev \
  libwayland-dev libpipewire-0.3-dev libpulse-dev \
  libx264-dev libmbedtls-dev libgl1-mesa-dev \
  uthash-dev libsimde-dev \
  libluajit-5.1-dev python3-dev swig libcmocka-dev \
  libx11-dev libxcb-randr0-dev libxcb-shm0-dev libxcb-xinerama0-dev \
  libxcb-composite0-dev libxinerama-dev libxcb1-dev libx11-xcb-dev libxcb-xfixes0-dev \
  libxss-dev libglvnd-dev libxkbcommon-dev \
  libatk1.0-dev libatk-bridge2.0-dev libxcomposite-dev libxdamage-dev \
  libasound2-dev libfdk-aac-dev libfontconfig-dev libfreetype6-dev \
  libjack-jackd2-dev libsndio-dev libspeexdsp-dev \
  libudev-dev libv4l-dev libva-dev libvlc-dev libpci-dev libdrm-dev \
  nlohmann-json3-dev libwebsocketpp-dev libasio-dev libqrcodegencpp-dev \
  libffmpeg-nvenc-dev librist-dev libsrt-openssl-dev \
  qt6-base-dev libqt6svg6-dev qt6-base-private-dev \
  libvpl-dev libvpl2 libnss3-dev libnspr4-dev xz-utils file \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

# Download CEF (parse version from CMakePresets.json)
RUN CEF_VERSION=$(jq -r '.configurePresets[] | select(.name=="dependencies") | .vendor["obsproject.com/obs-studio"].dependencies.cef.version' CMakePresets.json) && \
    CEF_REVISION=$(jq -r '.configurePresets[] | select(.name=="dependencies") | .vendor["obsproject.com/obs-studio"].dependencies.cef.revision["ubuntu-x86_64"] // empty' CMakePresets.json) && \
    CEF_HASH=$(jq -r '.configurePresets[] | select(.name=="dependencies") | .vendor["obsproject.com/obs-studio"].dependencies.cef.hashes["ubuntu-x86_64"]' CMakePresets.json) && \
    mkdir -p .deps && cd .deps && \
    FILENAME="cef_binary_${CEF_VERSION}_linux_x86_64${CEF_REVISION:+_v${CEF_REVISION}}.tar.xz" && \
    curl -fSLO "https://cdn-fastly.obsproject.com/downloads/${FILENAME}" && \
    echo "${CEF_HASH}  ${FILENAME}" | sha256sum -c - && \
    mkdir -p "cef_binary_${CEF_VERSION}_linux_x86_64" && \
    tar --strip-components=1 -xJf "${FILENAME}" -C "cef_binary_${CEF_VERSION}_linux_x86_64"

# Configure + Build + Package
RUN CEF_VERSION=$(jq -r '.configurePresets[] | select(.name=="dependencies") | .vendor["obsproject.com/obs-studio"].dependencies.cef.version' CMakePresets.json) && \
    cmake -S . --preset ubuntu \
      -DCMAKE_BUILD_TYPE=Release \
      -DENABLE_BROWSER=ON \
      -DCEF_ROOT_DIR="/build/.deps/cef_binary_${CEF_VERSION}_linux_x86_64" && \
    cmake --build build_ubuntu --config Release --parallel && \
    cd build_ubuntu && cpack -C Release
