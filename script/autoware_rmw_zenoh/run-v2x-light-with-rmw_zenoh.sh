#!/usr/bin/env bash
set -e

VEHICLE_NAME="${1:-v1}"

# Match the env exported by run-autoware-with-rmw_zenoh.sh
# so v2x_light's rclpy uses the same RMW + Zenoh session as Autoware.
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ZENOH_SESSION_CONFIG_URI=config/RMW_ZENOH_SESSION_CONFIG.json5
export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\""

source external/zenoh_autoware_v2x/install/setup.bash
ros2 run v2x_light v2x_light -- -v "${VEHICLE_NAME}" --map-info external/zenoh_autoware_v2x/map_info.json
