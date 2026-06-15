#!/usr/bin/env bash
set -e

export RMW_IMPLEMENTATION=rmw_zenoh_cpp

export VEHICLE_NAME=v1
export CARLA_VEHICLE=v1
export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V1_CONFIG.json5
export ZENOH_SESSION_CONFIG_URI=config/RMW_ZENOH_SESSION_CONFIG.json5

export CARLA_SIMULATOR_IP=172.17.0.1

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Per-vehicle rviz config: generated from the template by swapping the traffic-light camera topic
RVIZ_TEMPLATE=${AUTOWARE_CARLA_ROOT}/src/autoware_carla_launch/rviz/autoware.rviz
RVIZ_CONFIG=${LOG_PATH}/autoware_${VEHICLE_NAME}.rviz
sed "s#/carla/v[0-9]\+/traffic_light/image#/carla/${VEHICLE_NAME}/traffic_light/image#g" "${RVIZ_TEMPLATE}" > "${RVIZ_CONFIG}"

# Load Town01 up front so the world is ready before Autoware starts.
python3 ${AUTOWARE_CARLA_ROOT}/script/autoware_rmw_zenoh/load_town01.py ${CARLA_SIMULATOR_IP}

# Run the program
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml rviz_config:=${RVIZ_CONFIG} \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "RUST_LOG=debug ros2 run rmw_zenoh_cpp rmw_zenohd \
            2>&1 | tee ${LOG_PATH}/rmw_zenohd.log"
