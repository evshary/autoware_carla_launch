#!/bin/bash

DOCKER_IMAGE=zenoh-autoware-20251027
DOCKER_FILE=container/Dockerfile_autoware
AUTOWARE_VERSION=main
AUTOWARE_COMMIT=87d3928dc4d64977ffd943814b8261eb63173310 #20251027

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

rocker --nvidia --privileged --x11 --user --ipc host  --volume $(pwd):$HOME/autoware_carla_launch -- ${DOCKER_IMAGE}
