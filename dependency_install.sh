#!/bin/bash

if [ -f /.dockerenv ]; then
    # Create folder for RUST installation
    mkdir -p ${RUSTUP_HOME}
    touch ${RUSTUP_HOME}/COLCON_IGNORE
    # Create folder for poetry installation
    mkdir -p ${POETRY_HOME}
    touch ${POETRY_HOME}/COLCON_IGNORE
fi

# Install RUST
curl https://sh.rustup.rs -sSf | bash -s -- -y
# Install poetry
curl -sSL https://install.python-poetry.org | python3 -
poetry config virtualenvs.in-project true

# Install pyenv
if [ -f /.dockerenv ]; then
    curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    touch ${PYENV_ROOT}/COLCON_IGNORE
    pyenv install -v 3.8.10
    cd external/zenoh_carla_bridge/carla_agent && pyenv local 3.8.10 && poetry env use $(pyenv which python)
fi

