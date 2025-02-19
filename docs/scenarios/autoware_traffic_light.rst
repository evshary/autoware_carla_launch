.. _run carla with one autoware, with traffic light module enabled:

Run Carla with one Autoware, with traffic light module enabled
===========================

The section shows how to run Autoware with traffic light module in Carla simulator.

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
    ./script/run-bridge.sh

3. Run zenoh-bridge-ros2dds and Autoware (In Autoware container)

..  code-block:: bash

    # Go inside "Autoware container"
    ./container/run-autoware-docker.sh
    # Run zenoh-bridge-ros2dds and Autoware
    cd autoware_carla_launch
    source env.sh
    ./script/run-autoware-traffic-light.sh

    # (Optional) If you want to drive manually, split the terminal and run the following command
    source env.sh
    ros2 run autoware_manual_control keyboard_control

⚠️ **Notes**

This feature is still under optimization. Below are some potential issues you might encounter. If you face any problems, feel free to ask:

1. The traffic light module consumes more system resources, which may cause localization to be unstable at startup. If this happens, try restarting the system.
2. If the image display in Rviz freezes or does not appear, try reselecting the image in the right panel of the rviz interface. If the issue persists, change the Reliability Policy of the image topic and try again.
3. If the traffic light recognition is incorrect, it could be due to incorrect traffic light positions in the map. Please notify us as soon as possible if you encounter this issue.
4. In some cases, Auto mode may not function properly, or path planning may be unsuccessful. We suspect that excessive system resource usage is causing lag, but the exact cause is still under investigation. We are working on optimizations.
