V2X in Carla
============

V2X module integrated the autonomous system between multiple vehicles and the traffic light manager.


Carla Map Download Link
-----------------------

* Map information : `download <https://docs.google.com/presentation/d/1OGcAZwJlukMIv6jWCTFcrgRx-otBlLC7AP5ryMIy-Do/edit?usp=sharing>`_
* Map : `download <https://drive.google.com/file/d/1TBfWKDxxGnfm1ZUfzotDgcadEERYr85s/view?usp=drive_link>`_


Build V2X module
----------------

* Enter bridge container

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   cd external/zenoh_autoware_v2x
   poetry env use $(pyenv which python) && poetry install --no-root

* Enter Autoware container

.. code-block:: bash

   cd autoware_carla_launch/external/zenoh_autoware_v2x
   pip install -r requirements.txt
   colcon build --symlink-install

.. warning:: 
   Each time the Autoware container is executed, the eclipse-zenoh package needs to be reinstalled. Simply run the command `pip install -r requirements.txt`.

Running single vehicle scenario
-------------------------------

**Step1.** Running CARLA simulator

.. code-block:: bash

   ./CarlaUE4.sh -quality-level=Epic -world-port=2000 -RenderOffScreen

**Step2.** Entering bridge container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-bridge-v2x.sh

.. note::
   You can determine whether the bridge is running properly by checking if the terminal displays the following information...


.. code-block:: bash

   INFO: [intersection manager] Get Carla traffic lights
   ...
   INFO: [traffic manager] Get Carla traffic lights
   ...

**Step3.** Entering Autoware container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-autoware.sh

.. note:: 
   You can create a *tmux* session and execute the last command to easily run **Step 5**.

**Step4.** Wait for Autoware to localize the vehicle, then set the 2D Goal Pose.

**Step5.**  In Autoware container...

.. code-block:: bash

   source external/zenoh_autoware_v2x/install/setup.bash
   ros2 run v2x_light v2x_light -- -v <vehicle_id>

.. note:: 
   <vehicle_id> must same as CARLA agent's rolename. (default is "v1")

**Step6.** Press the "Auto" button in Rviz and let Autoware autopilot the vehicle

Running multiple vehicles scenario
----------------------------------

**Step1.** Running CARLA simulator

**Step2.** Entering bridge container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-bridge-two-vehicle-v2x.sh

**Step3.** Running Autoware container for 1st vehicle...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-autoware.sh v1

**Step4.** Running another Autoware container for 2nd vehicle...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-autoware.sh v2

.. note:: 
   Same as the above scenario, You can create a tmux session and execute the last command to easily run Step 6, 7.

**Step5.** Wait for Autoware to localize two vehicles, and then both set the 2D Goal Pose.

**Step6.**  In 1st Autoware container...

.. code-block:: bash

   source external/zenoh_autoware_v2x/install/setup.bash
   ros2 run v2x_light v2x_light -- -v v1

**Step7.** In 2nd Autoware container...

.. code-block:: bash

   source external/zenoh_autoware_v2x/install/setup.bash
   ros2 run v2x_light v2x_light -- -v v2

**Step8.** Press the "Auto" button in Rviz and let two Autoware autopilot the vehicles
   
