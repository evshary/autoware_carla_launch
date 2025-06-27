V2X in Carla
============

V2X module integrated the autonomous system between multiple vehicles and the traffic light manager.

.. image:: https://img.youtube.com/vi/8R8hPGfjEwk/0.jpg
    :alt: Zenoh-based V2X with Autoware and Carla
    :target: https://youtu.be/e_wtX7X7aTA

.. note:: 
   This service is for carla version 0.9.14.

Carla Map Download Link
-----------------------

* Map information : `map_information <https://docs.google.com/presentation/d/1OGcAZwJlukMIv6jWCTFcrgRx-otBlLC7AP5ryMIy-Do/edit?usp=sharing>`_
* Map : `map_download <https://drive.google.com/file/d/1TBfWKDxxGnfm1ZUfzotDgcadEERYr85s/view?usp=drive_link>`_


Build V2X module
----------------

* Enter Autoware container

.. code-block:: bash

   cd autoware_carla_launch/external/zenoh_autoware_v2x
   colcon build --symlink-install

Running single vehicle scenario
-------------------------------

**Step 1:** Running CARLA simulator

.. code-block:: bash

   ./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen -prefernvidia

**Step 2:** Entering bridge container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/bridge_ros2dds/run-bridge-v2x.sh

.. note::
   You can determine whether the bridge is running properly and verify that the V2X component is successfully retrieving the required information from the Carla simulator by checking if the terminal displays the following output...


.. code-block:: bash

   INFO  zenoh_carla_bridge > Running Carla Autoware Zenoh bridge...
   ...
   INFO: [Traffic Manager] Declaring Subscriber on 'vehicle/pose/**'...
   ...
   INFO: [Intersection Manager] Declaring Queryable on 'intersection/**/traffic_light/**'...
   ...

**Step 3:** Entering Autoware container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/autoware_ros2dds/run-autoware.sh

.. note:: 
   For convenience, use a *tmux* session to keep **Step 3** running in the background.

**Step 4:** Wait for Autoware to localize the vehicle, then set the 2D Goal Pose.

**Step 5:**  In Autoware container...

.. code-block:: bash

   cd autoware_carla_launch
   source external/zenoh_autoware_v2x/install/setup.bash
   ros2 run v2x_light v2x_light -- -v <vehicle_id>

.. note:: 
   <vehicle_id> must **match** CARLA agent's rolename. (default is **"v1"**)

**Step 6:** Press the **"Auto"** button in **Rviz** and let Autoware autopilot the vehicle.

Running multiple vehicles scenario
----------------------------------

**Step 1:** Running CARLA simulator

**Step 2:** Entering bridge container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-bridge-two-vehicle-v2x.sh

**Step 3:** Running Autoware container for 1st vehicle...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/autoware_ros2dds/run-autoware.sh v1

**Step 4:** Running another Autoware container for 2nd vehicle...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/autoware_ros2dds/run-autoware.sh v2

.. note::
   Just like in the single vehicle scenario, you can create a *tmux* session to execute the last command and more easily manage Steps 6 and 7.

**Step 5:** Wait for Autoware to localize two vehicles, and then both set the 2D Goal Pose.

**Step 6:**  In 1st Autoware container...

.. code-block:: bash

   source external/zenoh_autoware_v2x/install/setup.bash
   ros2 run v2x_light v2x_light -- -v v1

**Step 7:** In 2nd Autoware container...

.. code-block:: bash

   source external/zenoh_autoware_v2x/install/setup.bash
   ros2 run v2x_light v2x_light -- -v v2

**Step 8:** Press the "Auto" button in Rviz and let two Autoware autopilot the vehicles
   
