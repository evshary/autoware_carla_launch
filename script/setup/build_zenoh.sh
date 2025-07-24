#!/bin/bash

if [ ! -d "rmw_zenoh_ws" ]; then
    mkdir rmw_zenoh_ws/src -p
    cd rmw_zenoh_ws/src || exit
    git clone https://github.com/ros2/rmw_zenoh.git -b humble
    cd rmw_zenoh || exit
    git checkout 65ded05
    cd ../.. || exit
    rosdep update
    rosdep install --from-paths src --ignore-src --rosdistro humble -y
    cd .. || exit
fi

cd rmw_zenoh_ws || exit
source /opt/ros/humble/setup.bash
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release
