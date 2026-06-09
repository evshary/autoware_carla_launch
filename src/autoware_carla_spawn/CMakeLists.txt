cmake_minimum_required(VERSION 3.8)
project(autoware_carla_spawn)

find_package(ament_cmake REQUIRED)

# Install the spawn node as an executable so it can be run with
# `ros2 run autoware_carla_spawn spawn_node.py`. It imports the CARLA Python
# API (`carla`), which is installed into the system python (see container/Dockerfile).
install(PROGRAMS
  autoware_carla_spawn/spawn_node.py
  DESTINATION lib/${PROJECT_NAME}
)

install(DIRECTORY launch
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
