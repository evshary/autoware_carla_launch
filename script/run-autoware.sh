#!/bin/bash

VEHICLE_NAME="${1:-v1}"

VEHICLE_NAME=${VEHICLE_NAME} ros2 launch autoware_carla_launch autoware_zenoh.launch.xml

