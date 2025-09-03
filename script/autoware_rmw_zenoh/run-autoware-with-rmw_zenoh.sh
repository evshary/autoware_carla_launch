#!/usr/bin/env bash
set -e

export RMW_IMPLEMENTATION=rmw_zenoh_cpp
source rmw_zenoh_ws/install/setup.bash

export VEHICLE_NAME="${1:-v1}"
if [[ "$VEHICLE_NAME" == "v1" ]]; then
    export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V1_CONFIG.json5
elif [[ "$VEHICLE_NAME" == "v2" ]]; then
    export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V2_CONFIG.json5
fi
export ZENOH_SESSION_CONFIG_URI=config/RMW_ZENOH_SESSION_CONFIG.json5

# Enable Zenoh shared memory
export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\";transport/shared_memory/enabled=true"
export ZENOH_SHM_ALLOC_SIZE=$((512 * 1024 * 1024))
export ZENOH_SHM_MESSAGE_SIZE_THRESHOLD=1024

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Overwrite the default behavior_planning.launch.xml with the single-threaded version
# It runs behavior_path_planner in a separate container with one thread
# to avoid a GuardCondition use-after-free issue when using rmw_zenoh with multi-threaded executor.
# Known issue in ROS 2 Humble; fixed in Rolling (2025.04+), not backported.
sudo cp "$AUTOWARE_CARLA_ROOT/script/replace/behavior_planning_singlethread.launch.xml" \
   /opt/autoware/share/tier4_planning_launch/launch/scenario_planning/lane_driving/behavior_planning/behavior_planning.launch.xml

# Run the program
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "RUST_LOG=debug ros2 run rmw_zenoh_cpp rmw_zenohd \
    	    2>&1 | tee ${LOG_PATH}/rmw_zenohd.log"
