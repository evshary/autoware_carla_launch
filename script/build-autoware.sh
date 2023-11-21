#!/bin/bash

pushd autoware

mkdir -p src
vcs import src < autoware.repos
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

popd # autoware
