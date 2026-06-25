#!/usr/bin/env bash
set -e

export RMW_IMPLEMENTATION=rmw_zenoh_cpp

export VEHICLE_NAME=v1
export CARLA_VEHICLE=v1
export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V1_CONFIG.json5
export ZENOH_SESSION_CONFIG_URI=config/RMW_ZENOH_SESSION_CONFIG.json5
export CARLA_SPAWN_POSITION=87.687683,145.671295,0.3,0.0,90.000053,0.0

export CARLA_SIMULATOR_IP=172.17.0.1

V2X_PATH=${AUTOWARE_CARLA_ROOT}/external/zenoh_autoware_v2x/

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Per-vehicle rviz config: generated from the template by swapping the traffic-light camera topic
RVIZ_TEMPLATE=${AUTOWARE_CARLA_ROOT}/src/autoware_carla_launch/rviz/autoware.rviz
RVIZ_CONFIG=${LOG_PATH}/autoware_${VEHICLE_NAME}.rviz
sed "s#/carla/v[0-9]\+/traffic_light/image#/carla/${VEHICLE_NAME}/traffic_light/image#g" "${RVIZ_TEMPLATE}" > "${RVIZ_CONFIG}"

# Run the program
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml rviz_config:=${RVIZ_CONFIG} \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "RUST_LOG=debug ros2 run rmw_zenoh_cpp rmw_zenohd \
    	    2>&1 | tee ${LOG_PATH}/rmw_zenohd.log" \
    "sleep 5 && python3 ${V2X_PATH}/v2x_light/main.py \
            --mode native -v ${VEHICLE_NAME} --map-info ${V2X_PATH}/map_info.json \
            --config config/RMW_ZENOH_V2X_LIGHT_CONFIG.json5 \
            -e tcp/127.0.0.1:7447 -e tcp/${CARLA_SIMULATOR_IP}:7447 \
            2>&1 | tee ${LOG_PATH}/v2x_light.log"
