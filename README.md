# autoware_carla_launch

The package includes launch file to run Autoware, Carla agent, and bridge (zenoh-bridge-dds + carla_autoware_zenoh_bridge).

# Build

* Prerequisite: Install Autoware & Carla & Rust

* Clean the files

```shell
make clean
```

* Download necessary code & data

```shell
make prepare
```

* Build

```shell
# Source Autoware first before build
make build
```

# Usage

## Carla with Autoware

1. Run Carla simulator first

2. Run Autoware with Carla
 
```shell
source env.sh
ros2 launch autoware_carla_launch autoware_carla.launch.xml
```

## Manual control vehicle in Carla

1. Run Carla simulator first

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
