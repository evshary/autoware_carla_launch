.. _run carla with multiple autowares:

Run Carla with multiple Autowares
=================================

1. Run Carla simulator (In native host)

..  code-block:: bash

    ./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen -prefernvidia

2. Run zenoh_carla_bridge and Python Agent (In Carla bridge container)

..  code-block:: bash

    # Go inside "Carla bridge container"
    ./container/run-bridge-docker.sh
    # Run zenoh_carla_bridge and Python Agent
    cd autoware_carla_launch
    source env.sh
    ./script/run-bridge-two-vehicles.sh

3. Run zenoh-bridge-ros2dds and Autoware for 1st vehicle (In Autoware container)

..  code-block:: bash

    # Go inside "Autoware container"
    ./container/run-autoware-docker.sh
    # Run zenoh-bridge-ros2dds and Autoware
    cd autoware_carla_launch
    source env.sh
    ./script/run-autoware.sh v1
    # Optional: If you want to assign Carla IP and FMS IP
    ./script/run-autoware.sh v1 127.0.0.1:7447 127.0.0.1:7887

4. Run zenoh-bridge-ros2dds and Autoware for 2nd vehicle (In Autoware container)

..  code-block:: bash

    # Go inside "Autoware container"
    ./run-autoware-docker.sh
    # Run zenoh-bridge-ros2dds and Autoware
    cd autoware_carla_launch
    source env.sh
    ./script/run-autoware.sh v2
    # Optional: If you want to assign Carla IP and FMS IP
    ./script/run-autoware.sh v2 127.0.0.1:7447 127.0.0.1:7887

5. Now there are two rviz with separated Autoware at the same time. You can control them separately!