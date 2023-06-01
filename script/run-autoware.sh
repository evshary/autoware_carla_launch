#!/bin/bash

VEHICLE_NAME="${1:-v1}"
ZENOH_CARLA_IP="${2:-127.0.0.1}"

VEHICLE_NAME=${VEHICLE_NAME} ZENOH_CARLA_IP=${ZENOH_CARLA_IP} ros2 launch autoware_carla_launch autoware_zenoh.launch.xml
