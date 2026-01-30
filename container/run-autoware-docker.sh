#!/bin/bash

DOCKER_IMAGE=zenoh-autoware-1.5.0
DOCKER_FILE=container/Dockerfile_autoware

# Set the maximum locked memory inside the container.
MEMLOCK=$((32 * 1024 * 1024 * 1024)) # 32 GB

if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
    echo "${DOCKER_IMAGE} does not exist. Creating..."
    docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
fi

rocker --nvidia --privileged --x11 --user --ipc host --ulimit memlock=${MEMLOCK}:${MEMLOCK} --volume $(pwd):$HOME/autoware_carla_launch -- ${DOCKER_IMAGE}
