#!/usr/bin/env bash
set -e

export VEHICLE_NAME="${1:-v1}"
export ZENOH_CARLA_IP_PORT="${2:-'127.0.0.1:7447'}"
export ZENOH_FMS_IP_PORT="${3:-'127.0.0.1:7887'}"

# Add default port for Zenoh IP in Carla and FMS
if [[ ${ZENOH_CARLA_IP_PORT} != *":"* ]]; then
    export ZENOH_CARLA_IP_PORT="${ZENOH_CARLA_IP_PORT}:7447"
fi
if [[ ${ZENOH_FMS_IP_PORT} != *":"* ]]; then
    export ZENOH_FMS_IP_PORT="${ZENOH_FMS_IP_PORT}:7887"
fi

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Overwrite the behavior_planning.launch.xml with the default (multi-threaded) version.
# This version uses the original container configuration, running behavior_path_planner
# with the default multi-threaded executor
# Use this to revert any prior single-threaded replacement and ensure default behavior.
# Set destination path and SUDO variable based on Autoware build type
if [[ "$AMENT_PREFIX_PATH" == *"/autoware/install"* ]]; then
    DEST_PATH="autoware/src/universe/autoware_universe/launch/tier4_planning_launch/launch/scenario_planning/lane_driving/behavior_planning/behavior_planning.launch.xml"
    SUDO=""
else
    DEST_PATH="/opt/autoware/share/tier4_planning_launch/launch/scenario_planning/lane_driving/behavior_planning/behavior_planning.launch.xml"
    SUDO="sudo"
fi
$SUDO cp "$AUTOWARE_CARLA_ROOT/script/replace/behavior_planning.launch.xml" "$DEST_PATH"

# Run the program
# If is_simulation is true, planning behavior will change and doesn't care about the traffic light recognition. So we make it false.
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml is_simulation:=false use_traffic_light_recognition:=true \
            input/pointcloud:="/sensing/lidar/top/pointcloud" \
            input_pointcloud:="/sensing/lidar/top/pointcloud" \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "${AUTOWARE_CARLA_ROOT}/external/zenoh-plugin-ros2dds/target/release/zenoh-bridge-ros2dds \
            -n /${VEHICLE_NAME} -d ${ROS_DOMAIN_ID} -c ${ZENOH_BRIDGE_ROS2DDS_CONFIG} -e tcp/${ZENOH_CARLA_IP_PORT} -e tcp/${ZENOH_FMS_IP_PORT} \
            2>&1 | tee ${LOG_PATH}/zenoh_bridge_ros2dds.log"
