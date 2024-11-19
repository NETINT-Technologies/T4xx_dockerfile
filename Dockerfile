FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="NETINT Technologies" \
      org.opencontainers.image.description="Docker file example for NETINT VPU using the SDK Release Package"

ARG NI_RELEASE_VERSION=3.5.1
ARG NI_PACKAGE_NAME="T4xx-Release-v${NI_RELEASE_VERSION}.zip"
#FFMPEG_VERSION can be: n3.1.1, n3.4.2, n4.1.3, n4.2.1, n4.3, n4.3.1, n4.3.2, n4.4, n5.0, n5.1.2 n6.1
ARG FFMPEG_VERSION=n5.0
ARG FFMPEG_PACKAGE_NAME="${FFMPEG_VERSION}.tar.gz"

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

#packages install
RUN apt-get update
RUN apt-get install -y pkg-config git gcc make g++ sudo wget uuid-runtime udev nvme-cli yasm unzip

#copy ni release package to docker /NI_Release directory
COPY $NI_PACKAGE_NAME /NI_Release/
WORKDIR /NI_Release
RUN wget -c https://github.com/FFmpeg/FFmpeg/archive/refs/tags/${FFMPEG_VERSION}.tar.gz

#SW package install
WORKDIR /NI_Release
RUN tar -xzf "$FFMPEG_PACKAGE_NAME"
RUN unzip "$NI_PACKAGE_NAME"
WORKDIR /NI_Release/V"$NI_RELEASE_VERSION"/
RUN tar -xvf Codensity_T4XX_Software_Release_V"$NI_RELEASE_VERSION".tar.gz
#ffmpeg install
RUN cp /NI_Release/V"$NI_RELEASE_VERSION"/release/FFmpeg-"$FFMPEG_VERSION"_t4xx_patch /NI_Release/FFmpeg-"$FFMPEG_VERSION"/
RUN mv /NI_Release/V"$NI_RELEASE_VERSION"/release/libxcoder_logan /NI_Release
WORKDIR /NI_Release/libxcoder_logan
RUN echo 'y' | bash ./build.sh
WORKDIR /NI_Release/FFmpeg-"$FFMPEG_VERSION"
RUN patch -t -p 1 < FFmpeg-"$FFMPEG_VERSION"_t4xx_patch
RUN chmod u+x *.sh
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig/
RUN echo 'y' | bash ./build_ffmpeg.sh --ffprobe --shared
RUN make install

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
RUN ldconfig
CMD echo "------end-----"
