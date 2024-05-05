# autoware_carla_launch

## Prerequisites

Make sure you meet the following system requirements

* Ubuntu 22.04
* Carla 0.9.14

Install rocker for containers

```shell
sudo apt install docker.io python3-rocker
```

## Build

### Build the container for Carla bridge

* Enter into docker

```shell
./container/run-bridge-docker.sh
```

* Build Carla bridge

```shell
cd autoware_carla_launch
source env.sh
make prepare_bridge
make build_bridge
```

### Build the container for Zenoh+Autoware

* Enter into docker

```shell
./container/run-autoware-docker.sh
```

* Build Zenoh+Autoware

```shell
cd autoware_carla_launch
source env.sh
make prepare_autoware
make build_autoware
```

## Usage

### Carla with Autoware

The section shows how to run Autoware in Carla simulator.

1. Run Carla simulator (In native host)

```shell
./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen
```

2. Run zenoh_carla_bridge and Python Agent (In Carla bridge container)

```shell
# Go inside "Carla bridge container"
./container/run-bridge-docker.sh
# Run zenoh_carla_bridge and Python Agent
cd autoware_carla_launch
source env.sh
./script/run-bridge.sh
```

3. Run zenoh-bridge-ros2dds and Autoware (In Autoware container)

```shell
# Go inside "Autoware container"
./container/run-autoware-docker.sh
# Run zenoh-bridge-ros2dds and Autoware
cd autoware_carla_launch
# Split the terminal
tmux

# 1st terminal
source env.sh
./script/run-autoware.sh
# 2nd terminal: Check the frequency of Zenoh
./external/zenoh-tools/target/release/zenoh-tools -k v1/sensing/camera/traffic_light/image_raw
# 3rd terminal: Check the frequency of Autoware
source env.sh
ros2 topic hz sensing/camera/traffic_light/image_raw
```
