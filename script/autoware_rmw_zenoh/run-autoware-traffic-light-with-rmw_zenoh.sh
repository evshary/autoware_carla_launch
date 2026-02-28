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

# Set namespace to match bridge key expressions
export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\""
# Enable Zenoh shared memory
# export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\";transport/shared_memory/enabled=true"
# export ZENOH_SHM_ALLOC_SIZE=$((256 * 1024 * 1024))
# export ZENOH_SHM_MESSAGE_SIZE_THRESHOLD=1024

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Run the program
# If is_simulation is true, planning behavior will change and doesn't care about the traffic light recognition. So we make it false.
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml \
            use_traffic_light_recognition:=true \
            lidar_detection_model:=${LIDAR_DETECTION_MODEL}/${CENTERPOINT_MODEL_NAME} \
            traffic_light_recognition/camera_namespaces:=[traffic_light] \
            input/pointcloud:="/sensing/lidar/top/pointcloud_raw_ex" \
            input_pointcloud:="/sensing/lidar/top/pointcloud_raw_ex" \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "RUST_LOG=debug ros2 run rmw_zenoh_cpp rmw_zenohd \
    	    2>&1 | tee ${LOG_PATH}/rmw_zenohd.log"
