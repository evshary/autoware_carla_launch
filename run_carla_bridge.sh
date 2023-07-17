#!/bin/bash

sleep 5
${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/target/release/zenoh_carla_bridge --zenoh-listen tcp/0.0.0.0:7447
