Fleet Management System in Carla
================================

Remote fleet management service with manual and automatic drving.

.. note:: 
   This service is for carla version 0.9.13.


Download and build fleet management module
------------------------------------------

* Download fleet management

.. code-block:: bash

   git clone https://github.com/evshary/zenoh_autoware_fms.git

* Install prerequisite

.. code-block:: bash

   cd zenoh_autoware_fms
   ./prerequisite.sh


Running single vehicle scenario
-------------------------------

**Step1.** Running CARLA simulator

**Step2.** Entering bridge container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-bridge.sh


**Step3.** Entering Autoware container then executing...

.. code-block:: bash

   cd autoware_carla_launch
   source env.sh
   ./script/run-autoware.sh


**Step4.** Run Web & API fleet management server.

.. code-block:: bash

   cd zenoh_autoware_fms
   source env.sh
   ./run_server.sh

.. note:: 
   Please make sure to source ROS 2 environment before this step.


**Step4.** Visit the fleet management server at http://localhost:3000

   
