#!/bin/bash

PYTHON_AGENT_PATH=${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/carla_agent
# Note bridge should run later because it needs to configure Carla sync setting.
# Python script will overwrite the settings if bridge run first.
parallel --verbose --lb --header :  --results bridge_log ::: "`date '+%Y-%m-%d_%H:%M:%S'`" \
                       "sleep 5 && RUST_LOG=z=info ${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/target/release/zenoh_carla_bridge" \
                       "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
                               --host ${CARLA_SIMULATOR_IP} --rolename ${VEHICLE_NAME}"
