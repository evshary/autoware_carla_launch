#!/usr/bin/env bash
set -e

export CARLA_SIMULATOR_IP=172.17.0.1

V2X_PATH=${AUTOWARE_CARLA_ROOT}/external/zenoh_autoware_v2x/

# Log folder
LOG_PATH=autoware_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Load Town01 up front so the world is ready before Autoware starts.
python3 ${AUTOWARE_CARLA_ROOT}/script/autoware_rmw_zenoh/load_town01.py ${CARLA_SIMULATOR_IP}

# Run the two managers; they connect directly to the CARLA Zenoh router (no local router needed).
parallel --verbose --lb ::: \
    "python3 ${V2X_PATH}/traffic_manager/main.py \
            -e tcp/${CARLA_SIMULATOR_IP}:7447 \
            2>&1 | tee ${LOG_PATH}/v2x_traffic_manager.log" \
    "python3 ${V2X_PATH}/intersection_manager/main.py \
            --host ${CARLA_SIMULATOR_IP} \
            -e tcp/${CARLA_SIMULATOR_IP}:7447 \
            2>&1 | tee ${LOG_PATH}/v2x_intersection_manager.log"
