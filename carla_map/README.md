# Carla Map

The map we used here is from https://github.com/hatem-darweesh/op_agent/tree/ros2/autoware-contents/maps/vector_maps/lanelet2

You can download it via Google Drive link: 

# Change the map

You can change map by yourselves easily.

1. Select which map you want to use, e.g. Town02, Town03....
2. Download it from https://drive.google.com/drive/folders/1GBcV9uXAq3QVrLfQdqI0LTIRKms_r8kl
    - Remember there are pcd and osm files which should be downloaded
3. Create folder under carla_map (e.g. Town02), and put osm and pcd files into it.
4. Then rename your osm file to `lanelet2_map.osm`, pcd file to `pointcloud_map.pcd`.
5. Update `CARLA_MAP_NAME` environment variables in env.sh.
