FROM ubuntu:20.04
MAINTAINER NETINT - FAE

ENV REFRESHED_AT=2023-03-21
ARG NI_RELEASE_VERSION=3.5.0
ARG NI_PACKAGE_NAME="Codensity_T4XX_Software_Release_V${NI_RELEASE_VERSION}.tar.gz"
#FFMPEG_VERSION can be: n3.1.1, n3.4.2, n4.1.3, n4.2.1, n4.3, n4.3.1, n4.3.2, n4.4, n5.0, n5.1.2
ARG FFMPEG_VERSION=n5.0
ARG FFMPEG_PACKAGE_NAME="${FFMPEG_VERSION}.tar.gz"

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

#packages install
RUN apt-get update
RUN apt-get install -y pkg-config git gcc make g++ sudo wget uuid-runtime udev

#copy ni release package to docker /NI_Release directory
COPY $NI_PACKAGE_NAME /NI_Release/
WORKDIR /NI_Release
RUN wget -c https://github.com/FFmpeg/FFmpeg/archive/refs/tags/${FFMPEG_VERSION}.tar.gz

#nvme cli install
WORKDIR /NI_Release
RUN wget -c https://github.com/linux-nvme/nvme-cli/archive/refs/tags/v1.16.tar.gz
RUN tar -xzf v1.16.tar.gz
WORKDIR /NI_Release/nvme-cli-1.16/
RUN make
RUN make install
RUN nvme list

#yasm install
WORKDIR /NI_Release
RUN wget -c http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
RUN tar -zxf yasm-1.3.0.tar.gz
WORKDIR /NI_Release/yasm-1.3.0/
RUN ./configure
RUN make
RUN make install

#SW package install
WORKDIR /NI_Release
RUN tar -xzf "$NI_PACKAGE_NAME"
RUN tar -xzf "$FFMPEG_PACKAGE_NAME"
#ffmpeg install
RUN cp /NI_Release/release/FFmpeg-"$FFMPEG_VERSION"_t4xx_patch /NI_Release/FFmpeg-"$FFMPEG_VERSION"/
RUN mv /NI_Release/release/libxcoder_logan /NI_Release
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
#every time docker is run please run this command inside docker first: ni_rsrc_mon
