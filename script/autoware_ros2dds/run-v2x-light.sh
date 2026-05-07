#!/usr/bin/env bash
set -e

VEHICLE_NAME="${1:-v1}"

source external/zenoh_autoware_v2x/install/setup.bash
ros2 run v2x_light v2x_light -- -v "${VEHICLE_NAME}" --map-info external/zenoh_autoware_v2x/map_info.json
