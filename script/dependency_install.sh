#!/usr/bin/env bash
set -e

function install_python()
{
    # Install poetry
    if [ -f /.dockerenv ]; then
        # Create folder for poetry installation
        mkdir -p ${POETRY_HOME}
    fi
    curl -sSL https://install.python-poetry.org | python3 -
    poetry config virtualenvs.in-project true

    # Install pyenv
    if [ -f /.dockerenv ]; then
        curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
        pyenv install -v 3.8.10
        cd external/zenoh_carla_bridge/carla_agent && pyenv local 3.8.10 && poetry env use $(pyenv which python)
    fi
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

function install_zenoh()
{
    echo "deb [trusted=yes] https://download.eclipse.org/zenoh/debian-repo/ /" | sudo tee -a /etc/apt/sources.list > /dev/null
    sudo apt update
    sudo apt install zenoh-bridge-dds=0.10.1-rc-1 zenoh-bridge-dds=0.10.1-rc.2-1
}

if [ "$1" = "rust" ]; then
    install_rust
elif [ "$1" = "python" ]; then
    install_python
elif [ "$1" = "zenoh" ]; then
    install_python
else
    install_rust
    install_python
    install_zenoh
fi

