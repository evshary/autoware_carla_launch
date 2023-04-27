FROM ghcr.io/autowarefoundation/autoware-universe:humble-20230215-prebuilt-cuda-amd64

# Download necessary packages
RUN apt-get update
# Useful tools
RUN apt-get install -y wget unzip tmux inetutils-ping curl vim
RUN python3 -m pip install gdown
# Used by zenoh-bridge-dds
RUN apt-get install -y llvm-dev libclang-dev cmake 
# Used by my carla-bridge
RUN apt-get install -y ros-humble-moveit-msgs
# Used by pyenv
RUN apt-get install -y build-essential libssl-dev zlib1g-dev \
                       libbz2-dev libreadline-dev libsqlite3-dev curl \
                       libncursesw5-dev xz-utils tk-dev libxml2-dev \
                       libxmlsec1-dev libffi-dev liblzma-dev

CMD bash

