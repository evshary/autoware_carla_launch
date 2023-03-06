# autoware_carla_launch

The package includes launch file to run Autoware, Carla agent, and bridge (zenoh-bridge-dds + carla_autoware_zenoh_bridge).

# Usage

* Clean the files

```bash
make clean
```

* Prerequisite

```bash
make prepare
```

* Build

```bash
# Source Autoware first before build
make build
```

* Run

```bash
# Run Carla simulator
source env.sh
ros2 launch autoware_carla_launch autoware_carla.launch.xml
```
