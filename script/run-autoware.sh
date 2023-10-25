#!/bin/bash

VEHICLE_NAME="${1:-v1}"
ZENOH_CARLA_IP_PORT="${2:-'127.0.0.1:7447'}"
ZENOH_FMS_IP_PORT="${3:-'127.0.0.1:7887'}"

VEHICLE_NAME=${VEHICLE_NAME} ZENOH_CARLA_IP_PORT=${ZENOH_CARLA_IP_PORT} ZENOH_FMS_IP_PORT=${ZENOH_FMS_IP_PORT} ros2 launch autoware_carla_launch autoware_zenoh.launch.xml
