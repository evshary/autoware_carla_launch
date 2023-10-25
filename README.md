# autoware_carla_launch

The package includes launch file to run Autoware, Carla agent, and bridge ([zenoh-bridge-dds](https://github.com/eclipse-zenoh/zenoh-plugin-dds) + [zenoh_carla_bridge](https://github.com/evshary/zenoh_carla_bridge)).

Switch branch if you want to use [humble version](https://github.com/evshary/autoware_carla_launch/tree/humble)

## Demo

[![IMAGE ALT TEXT](http://img.youtube.com/vi/UFBRMqJ2r0w/0.jpg)](https://youtu.be/UFBRMqJ2r0w "Run multiple vehicles with Autoware in Carla")

# Architecture

![image](https://user-images.githubusercontent.com/456210/232400804-e0e0a755-0f6d-4873-a8ad-f1188011c993.png)

# Prerequisites

Make sure you meet the following system requirements

* Ubuntu 20.04
* Autoware.universe galactic version
  - Only needed if you running in native host
* Carla 0.9.13

## Running in native host

* Install Autoware

## Running in docker

**There are some issues on Autoware galactic prebuilt image. Not to use it.**

```shell
sudo apt install docker.io python3-rocker
./run-docker.sh
```

# Build

* Clean the files

```shell
make clean
```

* Download necessary code & data

```shell
# Source Autoware first before build
source env.sh
make prepare
```

* Build

```shell
make build
```

# Usage

## Carla with Autoware

The section shows how to run Autoware in Carla simulator.

1. Run Carla simulator first

```shell
./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen
```

2. Run Autoware with Carla
 
```shell
source env.sh
ros2 launch autoware_carla_launch autoware_carla.launch.xml
```

3. (Option) The launch file above equals to the following two commands

```shell
## Running Carla Bridge and Python Agent
ros2 launch autoware_carla_launch carla_bridge.launch.xml
## Running zenoh-bridge-dds and Autoware
ros2 launch autoware_carla_launch autoware_zenoh.launch.xml
```

## Run multiple vehicles with Autoware in Carla at the same time

* Since running two Autoware will cause port conflict, we need to do some modification.
  - Modify `src/universe/autoware.universe/launch/tier4_planning_launch/launch/scenario_planning/lane_driving/behavior_planning/behavior_planning.launch.py` (About line 177) 

```diff
+ import random
....
            {
                "bt_tree_config_path": [
                    FindPackageShare("behavior_path_planner"),
                    "/config/behavior_path_planner_tree.xml",
                ],
+               "groot_zmq_publisher_port": random.randint(2000, 4000),
+               "groot_zmq_server_port": random.randint(2000, 4000),
                "planning_hz": 10.0,
            },
```

* Spawn two vehicles into Carla
  - Run Carla
  - Run `ros2 launch autoware_carla_launch carla_bridge_two_vehicles.launch.xml`

* Run Autoware twice:
  - 1st: `ROS_DOMAIN_ID=1 VEHICLE_NAME="v1" ros2 launch autoware_carla_launch autoware_zenoh.launch.xml`
  - 2nd: `ROS_DOMAIN_ID=2 VEHICLE_NAME="v2" ros2 launch autoware_carla_launch autoware_zenoh.launch.xml`

* Now there are two rviz with separated Autoware at the same time. You can control them separately!

## Manual control vehicle in Carla

The section shows how to control vehicles manually in Carla.

1. Run Carla simulator first

```shell
./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen
```

2. Run Autoware with Carla

```shell
source env.sh
ros2 launch autoware_carla_launch manual_control.launch.xml
```

3. Run manual control package

```shell
source env.sh
ros2 run autoware_manual_control keyboard_control
```

# FAQ

* [How to change the map](carla_map/README.md)
