#!/bin/bash

DOCKER_IMAGE=zenoh-autoware-jazzy-1.8.0
DOCKER_FILE=container/Dockerfile_autoware
AUTOWARE_VERSION=1.8.0

if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
    echo "${DOCKER_IMAGE} does not exist. Creating..."
    docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
fi

# Download Autoware source code
if [ ! -d autoware ]; then
    git clone https://github.com/autowarefoundation/autoware.git -b ${AUTOWARE_VERSION}
fi

rocker --nvidia --privileged --x11 --ipc host \
    --env HOST_UID=$(id -u) HOST_GID=$(id -g) \
    --volume $(pwd):/home/aw/autoware_carla_launch -- ${DOCKER_IMAGE}
