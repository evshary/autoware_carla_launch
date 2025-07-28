FAQ
===

1. How to change map?

    - Refer to `How to change the map <https://github.com/evshary/autoware_carla_launch/blob/humble/carla_map/README.md>`_

2. Will the project keep updated to the latest Autoware?

    - No, since Autoware is still updating, we only fix the version to the stable one.

3. How to contribute to the project?

    - We are happy to see users to contribute to the project. You can start from the issues in `the GitHub project <https://github.com/users/evshary/projects/3/>`_

4. How to list ROS 2 topics generated from the bridge?

    You must be in the **SAME** Autoware Docker container and ensure Autoware is running. Then you can use either way to have another shell to list the ROS 2 topics.

    - Option 1: Run another bash in the existing Autoware Docker container
    
      .. code-block:: bash

          # Execute Autoware container
          docker exec -it <CONTAINER_ID> bash

          # Inside container
          cd autoware_carla_launch
          source env.sh
          ros2 topic list

    - Option 2: Use tmux to run both Autoware and ROS2 commands
    
        1. Enter the container and run tmux. Then run Autoware.

        2. Use `ctrl-b + c` to open a new tmux window.

        3. In the new window, run the following commands:
        
          .. code-block:: bash

              source env.sh
              ros2 topic list

5. How to modify and verify the document locally?

    We are using ReadTheDocs, and you can use sphinx to check your modification.

    .. code-block:: bash

        pip install -r docs/requirements.txt
        sphinx-build -a docs /tmp/mydocs
        xdg-open /tmp/mydocs/index.html

6. How to change the lidar detection model for object detection?

    - In the ``env.sh`` file located in your project directory, you can adjust the lidar detection model by modifying the ``LIDAR_DETECTION_MODEL`` environment variable. The available options are "centerpoint", "apollo", "transfusion", or "disable" to disable lidar detection. 
    
    - If you choose "centerpoint", you can also select a specific model version by modifying the ``CENTERPOINT_MODEL_NAME`` variable. The available options are "centerpoint" and "centerpoint_tiny".
    
    - After making changes, save the file and reload the environment by running:

        .. code-block:: bash

            source env.sh
