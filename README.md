# T4xx Docker Readme

## Instructions

The Dockerfile here can be used to create a docker image with Netint Logan
libxcoder and FFmpeg installed.

1. Copy the Netint SW release package(eg. 
   Codensity_T4XX_Software_Release_Vx.y.z.tar.gz) to same folder as Dockerfile

2. Generate docker image:

       sudo docker build --tag ni_logan_sw .

   Two `--build-arg` options are supported in Dockerfile:

       NI_RELEASE_VERSION=x.y.z    version number of Netint Logan SW release package
       FFMPEG_VERSION=n5.0         version number of FFmpeg to use

3. Start docker targeting logan NVMe device:

       sudo docker run -it --device=/dev/nvme0 --device=/dev/nvme0n1 ni_logan_sw /bin/bash
   
   Please make sure you are targeting the correct Logan NVMe device and block
   paths. If you want to give the container sudo permission to control the
   device, you can add `--privileged` arg.

4. Run the test program:

       cd /NI_Release/FFmpeg-n5.0
       bash run_ffmpeg_logan.sh

To export docker image:

    sudo docker save ni_logan_sw | gzip -c > Logan_Docker.tar.gz

To import docker image:

    gunzip Logan_Docker.tar.gz
    sudo docker load -i Logan_Docker.tar

If you need to upgrade Logan card firmware, use t4xx_auto_upgrade.sh in the
Netint FW release tarball (T4XX_V*.tar.gz)
