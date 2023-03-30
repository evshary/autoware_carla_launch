FROM ghcr.io/autowarefoundation/autoware-universe:galactic-20220901-prebuilt-cuda-amd64

# Download necessary packages
RUN apt-get update
# Useful tools
RUN apt-get install -y wget unzip tmux inetutils-ping curl vim
RUN python3 -m pip install gdown
# Used by zenoh-bridge-dds
RUN apt-get install -y llvm-dev libclang-dev cmake 
# Used by my carla-bridge
RUN apt-get install -y ros-galactic-moveit-msgs

CMD bash

