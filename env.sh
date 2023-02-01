shell=`echo $SHELL | awk -F '/' '{print $NF}'`
ENV_PATH=`realpath $0`
export AUTOWARE_CARLA_ROOT=`dirname ${ENV_PATH}`

source ${AUTOWARE_CARLA_ROOT}/install/local_setup.${shell}

