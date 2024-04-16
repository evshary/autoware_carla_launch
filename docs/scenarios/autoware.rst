.. _run carla with one autoware:

Run Carla with one Autoware
===========================

The section shows how to run Autoware in Carla simulator.

1. Run Carla simulator (In native host)

..  code-block:: bash

    ./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen

2. Run zenoh_carla_bridge and Python Agent (In Carla bridge container)

..  code-block:: bash

    # Go inside "Carla bridge container"
    ./container/run-bridge-docker.sh
    # Run zenoh_carla_bridge and Python Agent
    cd autoware_carla_launch
    source env.sh
    ./script/run-bridge.sh

3. Run zenoh-bridge-ros2dds and Autoware (In Autoware container)

..  code-block:: bash

    # Go inside "Autoware container"
    ./container/run-autoware-docker.sh
    # Run zenoh-bridge-ros2dds and Autoware
    cd autoware_carla_launch
    source env.sh
    ./script/run-autoware.sh

    # (Optional) If you want to drive manually, split the terminal and run the following command
    source env.sh
    ros2 run autoware_manual_control keyboard_control
