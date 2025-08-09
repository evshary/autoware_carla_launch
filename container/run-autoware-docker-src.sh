#!/bin/bash

DOCKER_IMAGE=zenoh-autoware-20250725
DOCKER_FILE=container/Dockerfile_autoware
AUTOWARE_VERSION=main
AUTOWARE_COMMIT=8e44ac3 #20250725

if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
    echo "${DOCKER_IMAGE} does not exist. Creating..."
    docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
fi

# Download Autoware source code
if [ ! -d autoware ]; then
    git clone https://github.com/autowarefoundation/autoware.git -b ${AUTOWARE_VERSION}
    if [ -n "${AUTOWARE_COMMIT}" ]; then
        cd autoware
        echo "Checking out commit ${AUTOWARE_COMMIT}"
        git checkout ${AUTOWARE_COMMIT}
        cd -
    fi
fi

rocker --nvidia --privileged --x11 --user --volume $(pwd):$HOME/autoware_carla_launch -- ${DOCKER_IMAGE}
