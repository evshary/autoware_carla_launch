# Project Root
ENV_PATH=`realpath ${0//-}` # In tmux, $0 will become -bash, so we need to remove -
export AUTOWARE_CARLA_ROOT=`dirname ${ENV_PATH}`

# Setup environmental variables
shell=`cat /proc/$$/cmdline | tr -d '\0' | tr -d '-'`

# Source workspace after build
if [ -f ${AUTOWARE_CARLA_ROOT}/install/setup.${shell} ]; then
    source ${AUTOWARE_CARLA_ROOT}/install/setup.${shell}
fi

# ROS configuration
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
# Enable multicast for DDS (done by base image's /docker-entrypoint.sh since 1.8.0)
# sudo ip link set lo multicast on

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
