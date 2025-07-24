How to Build
============

We need to build two containers.
One is for Carla bridge and the other one is for Autoware.

Build the container for Carla bridge
------------------------------------

* Enter into docker

..  code-block:: bash

    ./container/run-bridge-docker.sh

* Build Carla bridge

..  code-block:: bash

    cd autoware_carla_launch
    source env.sh
    make prepare_bridge
    make build_bridge

.. note::
    **Troubleshooting:**

    1. If you encounter an error message indicating that `cargo` is not installed during `make prepare_bridge`, try running the following command to update the package list and then rerun the build:
    
        .. code-block:: bash

            sudo apt update

    2. If an error occurs during the `ros install` process, run the following command to update the ROS dependencies before retrying:
    
        .. code-block:: bash

            rosdep update

    3. During compilation, some packages may fail to compile. You can rerun the build command until all packages compile successfully. If some packages still fail after several attempts, please report an issue.

    4. If `python3.8.10` cannot be installed by `pyenv`, you can install and configure it using `deadsnakes`. Run the following commands to install Python 3.8.10:
    
        .. code-block:: bash

            sudo add-apt-repository ppa:deadsnakes/ppa
            sudo apt update
            sudo apt install python3.8 python3.8-dev python3.8-venv
            sudo ln -sf /usr/bin/python3.8 /usr/bin/python
            sudo curl https://bootstrap.pypa.io/pip/3.8/get-pip.py -o get-pip.py && python get-pip.py


Build the container for Zenoh+Autoware
--------------------------------------

* Enter into docker

..  code-block:: bash

    ./container/run-autoware-docker.sh

* Build Zenoh+Autoware

..  code-block:: bash

    cd autoware_carla_launch
    source env.sh
    # Note it will take some time first time initialize models used in Autoware
    make prepare_autoware
    make build_autoware

* (Optional) If you want to build Autoware from source

..  code-block:: bash

    # Remove old autoware (Optional)
    rm -rf autoware
    # Download source code and run docker
    ./container/run-autoware-docker-src.sh
    # Inside container
    cd autoware_carla_launch
    # Build Autoware
    ./script/setup/build-autoware.sh
    source autoware/install/setup.bash
    # The remaining steps are the same
    source env.sh
    make prepare_autoware
    make build_autoware

Clean
-----

* Clean the Carla bridge container

..  code-block:: bash

    # Enter into docker
    ./container/run-bridge-docker.sh
    # Clean
    cd autoware_carla_launch
    source env.sh
    make clean_bridge

* Clean Zenoh+Autoware container

..  code-block:: bash

    # Enter into docker
    ./container/run-autoware-docker.sh
    # Clean
    cd autoware_carla_launch
    source env.sh
    make clean_autoware
