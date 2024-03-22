#!/bin/bash

MAP_PATH="carla_map/Town01_v2x"

# Install gdown
python3 -m pip install --upgrade gdown

# If map doesn't exist
if [ ! -d $MAP_PATH ]; then
    echo "Download map from Internet..."
    mkdir $MAP_PATH
    gdown --fuzzy -O $MAP_PATH/lanelet2_map.osm https://drive.google.com/file/d/1TBfWKDxxGnfm1ZUfzotDgcadEERYr85s/view
    gdown --fuzzy -O $MAP_PATH/pointcloud_map.pcd https://drive.google.com/file/d/1MvJlfjkw3LWFUs5hdE_KQ2_CQTusU8UN/view
    echo "Download complete"
fi
