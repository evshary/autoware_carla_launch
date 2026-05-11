#!/usr/bin/env bash
set -e

export RMW_IMPLEMENTATION=rmw_zenoh_cpp

export VEHICLE_NAME="${1:-v1}"
if [[ "$VEHICLE_NAME" == "v1" ]]; then
    export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V1_CONFIG.json5
elif [[ "$VEHICLE_NAME" == "v2" ]]; then
    export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V2_CONFIG.json5
fi
export ZENOH_SESSION_CONFIG_URI=config/RMW_ZENOH_SESSION_CONFIG.json5

# Set namespace to match bridge key expressions
export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\""
# Enable Zenoh shared memory
# export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\";transport/shared_memory/enabled=true"
# export ZENOH_SHM_ALLOC_SIZE=$((128 * 1024 * 1024))
# export ZENOH_SHM_MESSAGE_SIZE_THRESHOLD=1024

# Source v2x_light overlay so ros2 run can find it in the parallel job below
source external/zenoh_autoware_v2x/install/setup.bash

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Run the program
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "RUST_LOG=debug ros2 run rmw_zenoh_cpp rmw_zenohd \
    	    2>&1 | tee ${LOG_PATH}/rmw_zenohd.log" \
    "sleep 5 && ros2 run v2x_light v2x_light -- -v ${VEHICLE_NAME} --map-info external/zenoh_autoware_v2x/map_info.json \
            2>&1 | tee ${LOG_PATH}/v2x_light.log"
