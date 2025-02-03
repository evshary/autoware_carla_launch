Fleet Management System in Carla
================================

Remote fleet management service with manual and automatic drving.

.. image:: http://img.youtube.com/vi/e_wtX7X7aTA/0.jpg
    :alt: Zenoh FMS with Autoware in Carla
    :target: https://youtu.be/e_wtX7X7aTA

.. note:: 
   This service is for carla version 0.9.14.


Download and build fleet management module
------------------------------------------

* Download fleet management

.. code-block:: bash

   git clone https://github.com/evshary/zenoh_autoware_fms.git

* Install prerequisite

.. code-block:: bash

   cd zenoh_autoware_fms
   ./prerequisite.sh


Run Autoware with Carla
-----------------------

Follow the either tutorial to run Carla, bridge and Autoware.

* :ref:`run carla with one autoware`
* :ref:`run carla with multiple autowares`

Run Fleet Management System
---------------------------

* Run Web & API fleet management server.

.. code-block:: bash

   cd zenoh_autoware_fms
   source env.sh
   ./run_server.sh

.. note:: 
   Please make sure to source ROS 2 environment before this step.


* Visit the fleet management server at http://localhost:3000
