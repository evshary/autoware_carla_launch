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

    # Require the traffic_light node to use the correct topic for traffic light recognition.
    if ! grep -q '<arg name="namespace1" value="traffic_light"/>' /opt/autoware/share/tier4_perception_launch/launch/perception.launch.xml; then
        sudo sed -i '/<include file="$(find-pkg-share tier4_perception_launch)\/launch\/traffic_light_recognition\/traffic_light.launch.xml">/a\        <arg name="namespace1" value="traffic_light"/>' /opt/autoware/share/tier4_perception_launch/launch/perception.launch.xml
    fi
fi

# Able to access binary after pip install
export PATH="$HOME/.local/bin:$PATH"

# Export Map path
export CARLA_MAP_NAME="Town01"
export CARLA_MAP_PATH=${AUTOWARE_CARLA_ROOT}/carla_map/${CARLA_MAP_NAME}


# Set Autoware Settings (Can be overwritten by CLI)
export ROS_DOMAIN_ID=0
export VEHICLE_NAME="v1"

# Set the ccache directory to /tmp to avoid permission issue
export CCACHE_DIR=/tmp/ccache

# Enable/Disable lidar detection model functionality ("centerpoint", "apollo", "transfusion", or "disable")
export LIDAR_DETECTION_MODEL="centerpoint"

# Set centerpoint model ("centerpoint", "centerpoint_tiny")
# It is used when LIDAR_DETECTION_MODEL is set as "centerpoint"
export CENTERPOINT_MODEL_NAME="centerpoint_tiny"

# Rust path (Only needed while using docker)
if [ -f /.dockerenv ]; then
    RUST_PATH=${AUTOWARE_CARLA_ROOT}/rust

    export RUSTUP_HOME=${RUST_PATH}
    export CARGO_HOME=${RUST_PATH}
    export PATH="${RUST_PATH}/bin:$PATH"
fi
