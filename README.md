# autoware_carla_launch

The package includes launch files to run Autoware with CARLA's native ROS 2 interface over [rmw_zenoh](https://github.com/ros2/rmw_zenoh), spawning the ego vehicle and sensors directly in CARLA via `autoware_carla_spawn` (no external bridge required).

> **Note:** This branch (`carla-native-zenoh`) is a native-only setup. For the bridge-based approach ([zenoh-bridge-ros2dds](https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds) + [zenoh_carla_bridge](https://github.com/evshary/zenoh_carla_bridge)), see the `jazzy` branch.

## Prerequisites

- NVIDIA GPU, Docker, and [rocker](https://github.com/osrf/rocker).
- The custom CARLA build with the Zenoh ROS 2 middleware (see [Get CARLA](#1-get-carla-host)). Stock CARLA will not work — its native ROS 2 uses FastDDS, this setup uses Zenoh (`--rmw=zenoh`).

## Setup

### 1. Get CARLA (host)

CARLA runs on the **host**. Download the prebuilt server + matching Python client wheel:

```bash
./script/setup/download_carla.sh          # extracts to ~/carla-zenoh by default
```

This downloads the CARLA package from Google Drive and:

- extracts the server to `~/carla-zenoh/LinuxNoEditor`, and
- copies the Python client wheel into `container/` so it gets installed into the Docker image.

> Run this **before** building the container image (the image build installs the wheel).
>
> The CARLA server is a custom build ([habby1012/carla, branch `feat/zenoh-ros2-middleware`](https://github.com/habby1012/carla/tree/feat/zenoh-ros2-middleware)) that routes CARLA's native ROS 2 over Zenoh. Instructions for building it from source will be added later.

### 2. Build Autoware (container)

```bash
# Build the Docker image (first run only) and enter the container
./container/run-autoware-docker.sh

# --- inside the container ---
source env.sh
make prepare_autoware
make build_autoware
source env.sh
```

## Run

### 1. Start the CARLA server (host)

```bash
cd ~/carla-zenoh/LinuxNoEditor
ZENOH_CONFIG_OVERRIDE='mode="router";listen/endpoints=["tcp/0.0.0.0:7447"];connect/endpoints=[]' \
  ./CarlaUE4.sh -quality-level=Low -RenderOffScreen --ros2 --rmw=zenoh -prefernvidia
```

CARLA itself acts as the Zenoh router on port `7447`; each Autoware container connects to it.

### 2. Launch Autoware (container)

After `source env.sh`:

```bash
./script/autoware_rmw_zenoh/run-autoware-with-rmw_zenoh.sh v1
```

This spawns vehicle `v1` (ego + sensors) at a random spawn point in CARLA and brings up the full Autoware stack with RViz.

### Multiple vehicles

Run each vehicle in **its own container**. `v1` is the simulation tick master, so start it first. The two-vehicle script spawns `v1` and `v2` at fixed facing positions so they can see each other:

```bash
# container 1
./script/autoware_rmw_zenoh/run-autoware-two-vehicles-with-rmw_zenoh.sh v1

# container 2
./script/autoware_rmw_zenoh/run-autoware-two-vehicles-with-rmw_zenoh.sh v2
```

### Traffic light recognition

The traffic-light variants additionally enable Autoware's traffic-light recognition. Single vehicle:

```bash
./script/autoware_rmw_zenoh/run-autoware-traffic-light-with-rmw_zenoh.sh v1
```

For multiple vehicles, run each in **its own container**, `v1` first:

```bash
# container 1
./script/autoware_rmw_zenoh/run-autoware-two-vehicles-traffic-light-with-rmw_zenoh.sh v1

# container 2
./script/autoware_rmw_zenoh/run-autoware-two-vehicles-traffic-light-with-rmw_zenoh.sh v2
```

## Maintainers

| Avatar | GitHub ID | Name |
| --- | --- | --- |
| <a href="https://github.com/evshary"><img src="https://github.com/evshary.png" width="48" alt="evshary" /></a> | [@evshary](https://github.com/evshary) | ChenYing Kuo |
| <a href="https://github.com/hsule"><img src="https://github.com/hsule.png" width="48" alt="hsule" /></a> | [@hsule](https://github.com/hsule) | Leann Hsu |
| <a href="https://github.com/habby1012"><img src="https://github.com/habby1012.png" width="48" alt="habby1012" /></a> | [@habby1012](https://github.com/habby1012) | JinWei Hsu |
