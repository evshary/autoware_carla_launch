#!/usr/bin/env bash
set -e

# lidar centerpoint (tiny)
ros2 launch autoware_lidar_centerpoint lidar_centerpoint.launch.xml \
	model_name:=centerpoint_tiny \
	model_path:=$AUTOWARE_CARLA_ROOT/autoware_data/lidar_centerpoint \
	model_param_path:=$(ros2 pkg prefix autoware_launch --share)/config/perception/object_recognition/detection/lidar_model/centerpoint_tiny.param.yaml \
	build_only:=true


# lidar centerpoint
ros2 launch autoware_lidar_centerpoint lidar_centerpoint.launch.xml \
        model_name:=centerpoint \
        model_path:=$AUTOWARE_CARLA_ROOT/autoware_data/lidar_centerpoint \
        model_param_path:=$(ros2 pkg prefix autoware_launch --share)/config/perception/object_recognition/detection/lidar_model/centerpoint.param.yaml \
        build_only:=true


# lidar transfusion
ros2 launch autoware_lidar_transfusion lidar_transfusion.launch.xml \
        model_name:=transfusion \
        model_path:=$AUTOWARE_CARLA_ROOT/autoware_data/lidar_transfusion \
        model_param_path:=$(ros2 pkg prefix autoware_launch --share)/config/perception/object_recognition/detection/lidar_model/transfusion.param.yaml \
        build_only:=true

# traffic light (car)
ros2 launch autoware_traffic_light_classifier car_traffic_light_classifier.launch.xml \
	param_path:=$(ros2 pkg prefix autoware_traffic_light_classifier --share)/config/car_traffic_light_classifier.param.yaml \
	model_path:=$AUTOWARE_CARLA_ROOT/autoware_data/traffic_light_classifier/traffic_light_classifier_mobilenetv2_batch_6.onnx \
	label_path:=$AUTOWARE_CARLA_ROOT/autoware_data/traffic_light_classifier/lamp_labels.txt \
	build_only:=true \

# traffic light (pedestrian)
ros2 launch autoware_traffic_light_classifier pedestrian_traffic_light_classifier.launch.xml \
	param_path:=$(ros2 pkg prefix autoware_traffic_light_classifier --share)/config/pedestrian_traffic_light_classifier.param.yaml \
	model_path:=$AUTOWARE_CARLA_ROOT/autoware_data/traffic_light_classifier/ped_traffic_light_classifier_mobilenetv2_batch_6.onnx \
	label_path:=$AUTOWARE_CARLA_ROOT/autoware_data/traffic_light_classifier/lamp_labels_ped.txt \
	build_only:=true \
