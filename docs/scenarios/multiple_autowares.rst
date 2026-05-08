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
    # Option A: rmw_zenoh
    ./script/bridge_rmw_zenoh/run-bridge-two-vehicles-with-rmw-zenoh.sh
    # Option B: ros2dds
    ./script/bridge_ros2dds/run-bridge-two-vehicles.sh

3. Run Autoware for 1st vehicle (In Autoware container)

..  code-block:: bash

    # Go inside "Autoware container"
    ./container/run-autoware-docker.sh
    # Run Autoware
    cd autoware_carla_launch
    source env.sh
    # Option A: rmw_zenoh
    ./script/autoware_rmw_zenoh/run-autoware-with-rmw_zenoh.sh v1
    # Option B: ros2dds
    ./script/autoware_ros2dds/run-autoware.sh v1
    # Optional (ros2dds only): assign Carla IP and FMS IP
    ./script/autoware_ros2dds/run-autoware.sh v1 127.0.0.1:7447 127.0.0.1:7887

.. note::
   To change the Carla bridge / FMS IPs in ``rmw_zenoh`` mode, edit ``connect.endpoints`` in ``config/RMW_ZENOH_ROUTER_V1_CONFIG.json5`` (and ``RMW_ZENOH_ROUTER_V2_CONFIG.json5`` for the 2nd vehicle).

4. Run Autoware for 2nd vehicle (In Autoware container)

..  code-block:: bash

    # Go inside "Autoware container"
    ./container/run-autoware-docker.sh
    # Run Autoware
    cd autoware_carla_launch
    source env.sh
    # Option A: rmw_zenoh
    ./script/autoware_rmw_zenoh/run-autoware-with-rmw_zenoh.sh v2
    # Option B: ros2dds
    ./script/autoware_ros2dds/run-autoware.sh v2
    # Optional (ros2dds only): assign Carla IP and FMS IP
    ./script/autoware_ros2dds/run-autoware.sh v2 127.0.0.1:7447 127.0.0.1:7887

5. Now there are two rviz with separated Autoware at the same time. You can control them separately!
