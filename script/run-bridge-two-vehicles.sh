#!/bin/bash

PYTHON_AGENT_PATH=${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/carla_agent
parallel --verbose --lb --header :  --results bridge_log ::: "`date '+%Y-%m-%d_%H:%M:%S'`" \
                       "RUST_LOG=z=info ${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/target/release/zenoh_carla_bridge --zenoh-listen tcp/0.0.0.0:7447" \
                       "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
                               --host ${CARLA_SIMULATOR_IP} --rolename 'v1' \
                               --position 87.687683,145.671295,0.300000,0.000000,90.000053,0.000000" \
                       "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
                               --host ${CARLA_SIMULATOR_IP} --rolename 'v2' \
                               --position 92.109985,227.220001,0.300000,0.000000,-90.000298,0.000000"
