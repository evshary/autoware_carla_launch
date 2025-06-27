#!/usr/bin/env bash
set -e

MAP_PATH="carla_map/Town01"

# Install gdown
python3 -m pip install --upgrade gdown

# If map doesn't exist
if [ ! -d $MAP_PATH ]; then
    mkdir $MAP_PATH
fi

if [ ! -f "$MAP_PATH/lanelet2_map.osm" ] || [ ! -f "$MAP_PATH/pointcloud_map.pcd" ] || [ ! -f "$MAP_PATH/map_projector_info.yaml" ]; then
    echo "Download map from Internet..."
    gdown --fuzzy -O $MAP_PATH/lanelet2_map.osm https://drive.google.com/file/d/1eTuRuXWCLHzunwD11zgDahIjVrKLpv__/view
    gdown --fuzzy -O $MAP_PATH/pointcloud_map.pcd https://drive.google.com/file/d/1MvJlfjkw3LWFUs5hdE_KQ2_CQTusU8UN/view
    gdown --fuzzy -O $MAP_PATH/map_projector_info.yaml https://drive.google.com/file/d/1Nl3NsDADGQliMgjk7_En5Fc14ja7sIZF/view
    echo "Download complete"
fi
