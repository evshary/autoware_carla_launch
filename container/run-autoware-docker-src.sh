#!/bin/bash

DOCKER_IMAGE=zenoh-autoware-1.7.1-jazzy
DOCKER_FILE=container/Dockerfile_autoware
AUTOWARE_VERSION=1.7.1

if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
    echo "${DOCKER_IMAGE} does not exist. Creating..."
    docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
fi

# Download Autoware source code
if [ ! -d autoware ]; then
    git clone https://github.com/autowarefoundation/autoware.git -b ${AUTOWARE_VERSION}
fi

rocker --nvidia --privileged --x11 --user --ipc host  --volume $(pwd):$HOME/autoware_carla_launch -- ${DOCKER_IMAGE}
