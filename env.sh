# Project Root
ENV_PATH=`realpath ${0//-}` # In tmux, $0 will become -bash, so we need to remove -
export AUTOWARE_CARLA_ROOT=`dirname ${ENV_PATH}`

# Setup environmental variables for different environments
shell=`cat /proc/$$/cmdline | tr -d '\0' | tr -d '-'`
if [ -f /opt/zenoh-carla-bridge ]; then   # Python agent & zenoh_carla_bridge

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

    # Environmental variables to build carla-sys
    export LLVM_CONFIG_PATH=/usr/bin/llvm-config-12
    export LIBCLANG_PATH=/usr/lib/llvm-12/lib
    export LIBCLANG_STATIC_PATH=/usr/lib/llvm-12/lib
    export CLANG_PATH=/usr/bin/clang-12

    # Export the config of zenoh-carla-bridge
    export ZENOH_CARLA_BRIDGE_CONFIG=${AUTOWARE_CARLA_ROOT}/config/zenoh-carla-bridge-conf.json5

else  # zenoh-bridge-ros2dds & Autoware

    # Set up Autoware environment 
    source /autoware/install/setup.${shell}
    
    # Source workspace after build
    if [ -f ${AUTOWARE_CARLA_ROOT}/install/setup.${shell} ]; then
        source ${AUTOWARE_CARLA_ROOT}/install/setup.${shell}
    fi

    # Export the config of zenoh-bridge-ros2dds
    export ZENOH_BRIDGE_ROS2DDS_CONFIG=${AUTOWARE_CARLA_ROOT}/config/zenoh-bridge-ros2dds-conf.json5

    # ROS configuration
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    export ROS_LOCALHOST_ONLY=1
    sudo ip link set lo multicast on  # Enable multicast for DDS

fi

# Able to access binary after pip install
export PATH="$HOME/.local/bin:$PATH"

# Export Map path
export CARLA_MAP_NAME="Town01"
export CARLA_MAP_PATH=${AUTOWARE_CARLA_ROOT}/carla_map/${CARLA_MAP_NAME}


# Set Autoware Settings (Can be overwritten by CLI)
export ROS_DOMAIN_ID=0
export VEHICLE_NAME="v1"

# Set the ccache directory to /tmp
export CCACHE_DIR=/tmp/ccache

# Rust path (Only needed while using docker)
if [ -f /.dockerenv ]; then
    RUST_PATH=${AUTOWARE_CARLA_ROOT}/rust

    export RUSTUP_HOME=${RUST_PATH}
    export CARGO_HOME=${RUST_PATH}
    export PATH="${RUST_PATH}/bin:$PATH"
fi
