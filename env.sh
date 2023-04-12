# Project Root
ENV_PATH=`realpath $0`
export AUTOWARE_CARLA_ROOT=`dirname ${ENV_PATH}`


# Source workspace
shell=`echo $SHELL | awk -F '/' '{print $NF}'`
if [ -f ${AUTOWARE_CARLA_ROOT}/install/setup.${shell} ]; then
    source ${AUTOWARE_CARLA_ROOT}/install/setup.${shell}
fi

# Export the config of zenoh-bridge-dds
export ZENOH_BRIDGE_DDS_CONFIG=${AUTOWARE_CARLA_ROOT}/zenoh-bridge-dds-conf.json5


# Export Carla simulator IP
export CARLA_SIMULATOR_IP=127.0.0.1


# Export Map path
export CARLA_MAP_NAME="Town01"
export CARLA_MAP_PATH=${AUTOWARE_CARLA_ROOT}/carla_map/${CARLA_MAP_NAME}


# Set Autoware Settings (Can be overwritten by CLI)
export ROS_DOMAIN_ID=0
export VEHICLE_NAME="v1"


# Rust & Poetry path (Only needed while using docker)
if [ -f /.dockerenv ]; then
    RUST_PATH=${AUTOWARE_CARLA_ROOT}/rust
    POETRY_PATH=${AUTOWARE_CARLA_ROOT}/poetry

    export RUSTUP_HOME=${RUST_PATH}
    export CARGO_HOME=${RUST_PATH}
    export PATH="${RUST_PATH}/bin:$PATH"
    export POETRY_HOME=${POETRY_PATH}	
    export PATH="${POETRY_PATH}/bin:$PATH"

    mkdir -p ${RUST_PATH}
    touch ${RUST_PATH}/COLCON_IGNORE
    mkdir -p ${POETRY_PATH}
    touch ${POETRY_PATH}/COLCON_IGNORE
fi
