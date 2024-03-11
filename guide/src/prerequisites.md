# Prerequisites

## Operating System

**Ubuntu 20.04** is recommended for the development environment.

If you prefer using newer Ubuntu, extra steps are required to install
Clang 12.

```bash
sudo apt install clang-12 libclang-12-dev
export LLVM_CONFIG_PATH=/usr/bin/llvm-config-12
export LIBCLANG_PATH=/usr/lib/llvm-12/lib
export LIBCLANG_STATIC_PATH=/usr/lib/llvm-12/lib
export CLANG_PATH=/usr/bin/clang-12
```


## CARLA Simulator

The suite assumes **CARLA 0.9.13**. Please read the official
[installation
guide](https://carla.readthedocs.io/en/0.9.13/start_quickstart/#carla-installation)
to configure the simulator.


## Docker

Docker is required for container image compilation. Please follow the
official [installation
guide](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
to install the docker suite.


## Autoware


