FROM ghcr.io/autowarefoundation/autoware-universe:humble-20230616-prebuilt-cuda-amd64

# Download necessary packages
RUN apt-get update
# Useful tools
RUN apt-get install -y wget unzip tmux inetutils-ping curl vim
RUN python3 -m pip install gdown
# Used by zenoh-bridge-dds
RUN apt-get install -y llvm-dev libclang-dev cmake 

# Refer to https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user#_creating-a-nonroot-user
ARG USERNAME=adlink
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

CMD bash
