# Project Root
ENV_PATH=`realpath ${0//-}` # In tmux, $0 will become -bash, so we need to remove -
export AUTOWARE_CARLA_ROOT=`dirname ${ENV_PATH}`

# Setup environmental variables for different environments
shell=`cat /proc/$$/cmdline | tr -d '\0' | tr -d '-'`
if [ -d /opt/ros/humble/ ] && [ -f ${AUTOWARE_CARLA_ROOT}/install/setup.${shell} ]; then  # zenoh-bridge-dds & Autoware

    # Source workspace
    source ${AUTOWARE_CARLA_ROOT}/install/setup.${shell}

    # Export the config of zenoh-bridge-dds
    export ZENOH_BRIDGE_DDS_CONFIG=${AUTOWARE_CARLA_ROOT}/zenoh-bridge-dds-conf.json5
    # Export the config of zenoh-bridge-ros2dds
    export ZENOH_BRIDGE_ROS2DDS_CONFIG=${AUTOWARE_CARLA_ROOT}/zenoh-bridge-ros2dds-conf.json5

    # ROS configuration
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    export ROS_LOCALHOST_ONLY=1
    sudo ip link set lo multicast on  # Enable multicast for DDS

else  # Python agent & zenoh_carla_bridge

    # Export Carla simulator IP
    export CARLA_SIMULATOR_IP=127.0.0.1

    # Poetry path (Only needed while using docker)
    if [ -f /.dockerenv ]; then
        POETRY_PATH=${AUTOWARE_CARLA_ROOT}/poetry
        PYENV_PATH=${AUTOWARE_CARLA_ROOT}/pyenv

        export POETRY_HOME=${POETRY_PATH}
        export PATH="${POETRY_PATH}/bin:$PATH"
        export PYENV_ROOT="${PYENV_PATH}"
        export PATH="${PYENV_ROOT}/bin:$PATH"
    fi

fi


# Export Map path
export CARLA_MAP_NAME="Town01"
export CARLA_MAP_PATH=${AUTOWARE_CARLA_ROOT}/carla_map/${CARLA_MAP_NAME}


# Set Autoware Settings (Can be overwritten by CLI)
export ROS_DOMAIN_ID=0
export VEHICLE_NAME="v1"
export BRIDGE_TYPE="dds"


# Rust path (Only needed while using docker)
if [ -f /.dockerenv ]; then
    RUST_PATH=${AUTOWARE_CARLA_ROOT}/rust

    export RUSTUP_HOME=${RUST_PATH}
    export CARGO_HOME=${RUST_PATH}
    export PATH="${RUST_PATH}/bin:$PATH"
fi
