#!/bin/bash

export VEHICLE_NAME="${1:-v1}"
export ZENOH_CARLA_IP_PORT="${2:-'127.0.0.1:7447'}"
export ZENOH_FMS_IP_PORT="${3:-'127.0.0.1:7887'}"


LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "${AUTOWARE_CARLA_ROOT}/external/zenoh-plugin-dds/target/release/zenoh-bridge-dds \
            -s ${VEHICLE_NAME} -d ${ROS_DOMAIN_ID} -c ${ZENOH_BRIDGE_DDS_CONFIG} -e tcp/${ZENOH_CARLA_IP_PORT} -e tcp/${ZENOH_FMS_IP_PORT} \
            2>&1 | tee ${LOG_PATH}/zenoh_bridge_dds.log"
