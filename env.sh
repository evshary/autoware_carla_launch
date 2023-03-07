shell=`echo $SHELL | awk -F '/' '{print $NF}'`
ENV_PATH=`realpath $0`
export AUTOWARE_CARLA_ROOT=`dirname ${ENV_PATH}`

# Source Autoware workspace
source ${AUTOWARE_CARLA_ROOT}/install/setup.${shell}

# Export the config of zenoh-bridge-dds
export ZENOH_BRIDGE_DDS_CONFIG=${AUTOWARE_CARLA_ROOT}/zenoh-bridge-dds-conf.json5

# Export Carla simulator IP
export CARLA_SIMULATOR_IP=127.0.0.1
