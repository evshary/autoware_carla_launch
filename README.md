# autoware_carla_launch

The package includes launch file to run Autoware, Carla agent, and bridge ([zenoh-bridge-dds](https://github.com/eclipse-zenoh/zenoh-plugin-dds) + [zenoh_carla_bridge](https://github.com/evshary/zenoh_carla_bridge)).

## Demo

[![IMAGE ALT TEXT](http://img.youtube.com/vi/UFBRMqJ2r0w/0.jpg)](https://youtu.be/UFBRMqJ2r0w "Run multiple vehicles with Autoware in Carla")

# Architecture

![image](https://user-images.githubusercontent.com/456210/232400804-e0e0a755-0f6d-4873-a8ad-f1188011c993.png)

# Prerequisites

Make sure you meet the following system requirements

* Ubuntu 20.04
* Carla 0.9.13

Install rocker for containers

```shell
sudo apt install docker.io python3-rocker
```

# Build

## Build the container for Carla bridge

* Enter into docker

```shell
./run-bridge-docker.sh
```

* Build Carla bridge

```shell
cd autoware_carla_launch
source env.sh
make prepare_bridge
make build_bridge
```

## Build the container for Zenoh+Autoware

* Enter into docker

```shell
./run-autoware-docker.sh
```

* Build Carla bridge

```shell
cd autoware_carla_launch
source env.sh
make prepare_autoware
make build_autoware
```

# Usage

## Carla with Autoware

The section shows how to run Autoware in Carla simulator.

1. Run Carla simulator (In native host)

```shell
./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen
```

2. Run zenoh_carla_bridge and Python Agent (In Carla bridge container)

```shell
source env.sh
./zenoh-carla-bridge.sh
```

3. Run zenoh-bridge-dds and Autoware (In Autoware container)

```shell
source env.sh
ros2 launch autoware_carla_launch autoware_zenoh.launch.xml
```

## Run multiple vehicles with Autoware in Carla at the same time

* Able to spawn second vehicle into Carla.
  - Modify `zenoh-carla-bridge.sh` (About line 6)

```diff
-                       "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
-                               --host ${CARLA_SIMULATOR_IP} --rolename ${VEHICLE_NAME}"
+                       "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
+                               --host ${CARLA_SIMULATOR_IP} --rolename 'v1' \
+                               --position 87.687683,145.671295,0.300000,0.000000,90.000053,0.000000" \
+                       "poetry -C ${PYTHON_AGENT_PATH} run python3 ${PYTHON_AGENT_PATH}/main.py \
+                               --host ${CARLA_SIMULATOR_IP} --rolename 'v2' \
+                               --position 92.109985,227.220001,0.300000,0.000000,-90.000298,0.000000"
```

* Spawn vehicles into Carla
  - Run Carla
  - Run `ros2 launch autoware_carla_launch carla_bridge.launch.xml`

* Run Autoware twice:
  - 1st: `ROS_DOMAIN_ID=1 VEHICLE_NAME="v1" ros2 launch autoware_carla_launch autoware_zenoh.launch.xml`
  - 2nd: `ROS_DOMAIN_ID=2 VEHICLE_NAME="v2" ros2 launch autoware_carla_launch autoware_zenoh.launch.xml`

* Now there are two rviz with separated Autoware at the same time. You can control them separately!

# FAQ

* [How to change the map](carla_map/README.md)

# Known Issues

* Generate the map: Now we're using the maps generated by Hatem.

