#!/usr/bin/env bash
set -e

PYTHON_AGENT_PATH=${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/carla_agent
# Log folder
LOG_PATH=bridge_log/`date '+%Y-%m-%d_%H:%M:%S'`/
mkdir -p ${LOG_PATH}

# Enable Zenoh shared memory
# export ZENOH_CONFIG_OVERRIDE="transport/shared_memory/enabled=true"
# export ZENOH_SHM_ALLOC_SIZE=$((512 * 1024 * 1024))
# export ZENOH_SHM_MESSAGE_SIZE_THRESHOLD=1024

# Note bridge should run later because it needs to configure Carla sync setting.
# Python script will overwrite the settings if bridge run first.
parallel --verbose --lb ::: \
        "sleep 5 && RUST_LOG=z=info ${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/target/release/zenoh_carla_bridge \
                --mode rmw-zenoh --zenoh-listen tcp/0.0.0.0:7447 \
                --zenoh-config ${RMW_ZENOH_CARLA_BRIDGE_CONFIG} \
                --carla-address ${CARLA_SIMULATOR_IP} 2>&1 \
                | tee ${LOG_PATH}/bridge.log" \
        "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
                --host ${CARLA_SIMULATOR_IP} --rolename ${VEHICLE_NAME} \
                2>&1 | tee ${LOG_PATH}/vehicle.log"
