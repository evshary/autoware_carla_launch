#!/usr/bin/env bash
set -e

MAP_PATH="carla_map/Town01"

# Install gdown
python3 -m pip install --upgrade gdown

# If map doesn't exist
if [ ! -d $MAP_PATH ]; then
    mkdir $MAP_PATH
fi

if [ ! -f "$MAP_PATH/lanelet2_map.osm" ] || [ ! -f "$MAP_PATH/pointcloud_map.pcd" ]; then
    echo "Download map from Internet..."
    gdown --fuzzy -O $MAP_PATH/lanelet2_map.osm https://drive.google.com/file/d/1vm9SvalJe7Bc9sh_8jK-0cPulVAov5uD/view
    gdown --fuzzy -O $MAP_PATH/pointcloud_map.pcd https://drive.google.com/file/d/1MvJlfjkw3LWFUs5hdE_KQ2_CQTusU8UN/view
    echo "Download complete"
fi
