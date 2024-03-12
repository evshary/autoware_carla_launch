Build
=====

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

Build the container for Zenoh+Autoware
--------------------------------------

* Enter into docker

..  code-block:: bash

    ./container/run-autoware-docker.sh

* Build Zenoh+Autoware

..  code-block:: bash

    cd autoware_carla_launch
    source env.sh
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
    ./script/build-autoware.sh
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
