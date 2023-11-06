#!/bin/bash

PYTHON_AGENT_PATH=${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/carla_agent
# Log folder
LOG_PATH=bridge_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Note bridge should run later because it needs to configure Carla sync setting.
# Python script will overwrite the settings if bridge run first.
if [[ ${BRIDGE_TYPE} == "ros2" ]]; then
    parallel --verbose --lb ::: \
            "sleep 5 && RUST_LOG=z=info ${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/target/release/zenoh_carla_bridge \
                    --mode ros2 --zenoh-listen tcp/0.0.0.0:7447 2>&1 | tee ${LOG_PATH}/bridge.log" \
            "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
                    --host ${CARLA_SIMULATOR_IP} --rolename ${VEHICLE_NAME} \
                    2>&1 | tee ${LOG_PATH}/vehicle.log"
else
    parallel --verbose --lb ::: \
            "sleep 5 && RUST_LOG=z=info ${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/target/release/zenoh_carla_bridge \
                    --zenoh-listen tcp/0.0.0.0:7447 2>&1 | tee ${LOG_PATH}/bridge.log" \
            "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
                    --host ${CARLA_SIMULATOR_IP} --rolename ${VEHICLE_NAME} \
                    2>&1 | tee ${LOG_PATH}/vehicle.log"
fi
