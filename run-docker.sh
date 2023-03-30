#!/bin/bash

DOCKER_IMAGE=autoware-carla-bridge

if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
    echo "${DOCKER_IMAGE} does not exist. Creating..."
    docker build -t ${DOCKER_IMAGE} .
fi

rocker --nvidia --network host --privileged --x11 --user --volume $(pwd):$HOME/autoware_carla_launch -- ${DOCKER_IMAGE}

