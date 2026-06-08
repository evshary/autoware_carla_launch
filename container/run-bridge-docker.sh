#!/bin/bash

DOCKER_IMAGE=zenoh-carla-bridge-jazzy-1.8.0
DOCKER_FILE=container/Dockerfile_carla_bridge

# Set the maximum locked memory inside the container.
MEMLOCK=$((32 * 1024 * 1024 * 1024)) # 32 GB

if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
    echo "${DOCKER_IMAGE} does not exist. Creating..."
    docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
fi

rocker --nvidia --network host --privileged --x11 --ipc host --ulimit memlock=${MEMLOCK}:${MEMLOCK} \
    --env HOST_UID=$(id -u) HOST_GID=$(id -g) \
    --volume $(pwd):/home/aw/autoware_carla_launch -- ${DOCKER_IMAGE}
