#!/usr/bin/env bash
set -e

function install_python()
{
    # Install uv
    if [ -f /.dockerenv ]; then
        # Create folder for uv installation
        mkdir -p ${UV_INSTALL_DIR}
    fi
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh

    # Install pyenv
    curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    pyenv install -v 3.12.3
    pyenv global 3.12.3
    eval "$(pyenv init -)"
    cd ${AUTOWARE_CARLA_ROOT}/external/zenoh_carla_bridge/carla_agent && uv sync --python $(pyenv which python)
    cd ${AUTOWARE_CARLA_ROOT}/external/zenoh_autoware_v2x && uv sync --python $(pyenv which python)
}

function install_rust()
{
    # Install RUST
    if [ -f /.dockerenv ]; then
        # Create folder for RUST installation
        mkdir -p ${RUSTUP_HOME}
    fi
    curl https://sh.rustup.rs -sSf | bash -s -- -y
}

if [ "$1" = "rust" ]; then
    install_rust
elif [ "$1" = "python" ]; then
    install_python
else
    install_rust
    install_python
fi
