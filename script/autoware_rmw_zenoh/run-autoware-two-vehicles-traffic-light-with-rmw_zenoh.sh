#!/usr/bin/env bash
set -e

export RMW_IMPLEMENTATION=rmw_zenoh_cpp

export VEHICLE_NAME="${1:-v1}"
export CARLA_VEHICLE="${VEHICLE_NAME}"
if [[ "$VEHICLE_NAME" == "v1" ]]; then
    export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V1_CONFIG.json5
    export CARLA_SPAWN_POSITION=87.687683,145.671295,0.3,0.0,90.000053,0.0
elif [[ "$VEHICLE_NAME" == "v2" ]]; then
    export ZENOH_ROUTER_CONFIG_URI=config/RMW_ZENOH_ROUTER_V2_CONFIG.json5
    export CARLA_SPAWN_POSITION=92.109985,227.220001,0.3,0.0,-90.000298,0.0
fi
export ZENOH_SESSION_CONFIG_URI=config/RMW_ZENOH_SESSION_CONFIG.json5

export CARLA_SIMULATOR_IP=172.17.0.1

# Rename the camera topics in Autoware's traffic-light launch files to CARLA's.
TL_DIR=/opt/autoware/tier4_perception_launch/share/tier4_perception_launch/launch/traffic_light_recognition
sudo sed -i \
    -e "s#/sensing/camera/{namespace}/image_raw#/carla/${VEHICLE_NAME}/traffic_light/image#g" \
    -e "s#/sensing/camera/{namespace}/camera_info#/carla/${VEHICLE_NAME}/traffic_light/camera_info#g" \
    "${TL_DIR}"/*.launch.py

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Per-vehicle rviz config: generated from the template by swapping the traffic-light camera topic
RVIZ_TEMPLATE=${AUTOWARE_CARLA_ROOT}/src/autoware_carla_launch/rviz/autoware.rviz
RVIZ_CONFIG=${LOG_PATH}/autoware_${VEHICLE_NAME}.rviz
sed "s#/carla/v[0-9]\+/traffic_light/image#/carla/${VEHICLE_NAME}/traffic_light/image#g" "${RVIZ_TEMPLATE}" > "${RVIZ_CONFIG}"

# Run the program
parallel --verbose --lb ::: \
    "ros2 launch autoware_carla_launch autoware_zenoh.launch.xml \
            use_traffic_light_recognition:=true \
            rviz_config:=${RVIZ_CONFIG} \
            2>&1 | tee ${LOG_PATH}/autoware.log" \
    "RUST_LOG=debug ros2 run rmw_zenoh_cpp rmw_zenohd \
            2>&1 | tee ${LOG_PATH}/rmw_zenohd.log"
