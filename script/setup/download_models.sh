#!/usr/bin/env bash
set -e

MODELS_PATH="autoware_data"

# Declare all models' directories and corresponding download urls
declare -A models=(
  ["yabloc_pose_initializer"]="https://s3.ap-northeast-2.wasabisys.com/pinto-model-zoo/136_road-segmentation-adas-0001/resources.tar.gz"

  ["bevfusion"]="\
  https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/bevfusion_lidar.onnx \
  https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/bevfusion_camera_lidar.onnx \
  https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/ml_package_bevfusion_lidar.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/ml_package_bevfusion_camera_lidar.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/bevfusion/t4base_120m/v1/detection_class_remapper.param.yaml"

  ["tensorrt_bevdet"]="https://autoware-files.s3.us-west-2.amazonaws.com/models/tensorrt_bevdet.tar.gz"

  ["image_projection_based_fusion"]="\
  https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/pts_voxel_encoder_pointpainting.onnx \
  https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/pts_backbone_neck_head_pointpainting.onnx \
  https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/detection_class_remapper.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/pointpainting/v4/pointpainting_ml_package.param.yaml"

  ["lidar_apollo_instance_segmentation"]="\
  https://awf.ml.dev.web.auto/perception/models/lidar_apollo_instance_segmentation/vlp-16.onnx \
  https://awf.ml.dev.web.auto/perception/models/lidar_apollo_instance_segmentation/hdl-64.onnx \
  https://awf.ml.dev.web.auto/perception/models/lidar_apollo_instance_segmentation/vls-128.onnx"

  ["lidar_centerpoint"]="\
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_voxel_encoder_centerpoint.onnx \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_backbone_neck_head_centerpoint.onnx \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_voxel_encoder_centerpoint_tiny.onnx \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/pts_backbone_neck_head_centerpoint_tiny.onnx \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/centerpoint_ml_package.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/centerpoint_tiny_ml_package.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/centerpoint_sigma_ml_package.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/detection_class_remapper.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/centerpoint/v2/deploy_metadata.yaml"

  ["lidar_transfusion"]="\
  https://awf.ml.dev.web.auto/perception/models/transfusion/t4xx1_90m/v2.1/transfusion.onnx \
  https://awf.ml.dev.web.auto/perception/models/transfusion/t4xx1_90m/v2.1/transfusion_ml_package.param.yaml \
  https://awf.ml.dev.web.auto/perception/models/transfusion/t4xx1_90m/v2.1/detection_class_remapper.param.yaml"

  ["tensorrt_yolox"]="\
  https://awf.ml.dev.web.auto/perception/models/yolox-tiny.onnx \
  https://awf.ml.dev.web.auto/perception/models/yolox-sPlus-opt.onnx \
  https://awf.ml.dev.web.auto/perception/models/yolox-sPlus-opt.EntropyV2-calibration.table \
  https://awf.ml.dev.web.auto/perception/models/object_detection_yolox_s/v1/yolox-sPlus-T4-960x960-pseudo-finetune.onnx \
  https://awf.ml.dev.web.auto/perception/models/object_detection_yolox_s/v1/yolox-sPlus-T4-960x960-pseudo-finetune.EntropyV2-calibration.table \
  https://awf.ml.dev.web.auto/perception/models/label.txt \
  https://awf.ml.dev.web.auto/perception/models/object_detection_semseg_yolox_s/v1/yolox-sPlus-opt-pseudoV2-T4-960x960-T4-seg16cls.onnx \
  https://awf.ml.dev.web.auto/perception/models/object_detection_semseg_yolox_s/v1/yolox-sPlus-opt-pseudoV2-T4-960x960-T4-seg16cls.EntropyV2-calibration.table \
  https://awf.ml.dev.web.auto/perception/models/object_detection_semseg_yolox_s/v1/semseg_color_map.csv \
  https://awf.ml.dev.web.auto/perception/models/tl_detector_yolox_s/v1/yolox_s_car_ped_tl_detector_960_960_batch_1.onnx \
  https://awf.ml.dev.web.auto/perception/models/tl_detector_yolox_s/v1/yolox_s_car_ped_tl_detector_960_960_batch_1.EntropyV2-calibration.table \
  https://awf.ml.dev.web.auto/perception/models/tl_detector_yolox_s/v1/car_ped_tl_detector_labels.txt"

  ["tensorrt_rtmdet"]="https://autoware-files.s3.us-west-2.amazonaws.com/models/tensorrt_rtmdet_onnx_models.tar.gz"

  ["traffic_light_classifier"]="\
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_mobilenetv2_batch_1.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_mobilenetv2_batch_4.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_mobilenetv2_batch_6.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_efficientNet_b1_batch_1.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_efficientNet_b1_batch_4.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/traffic_light_classifier_efficientNet_b1_batch_6.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/ped_traffic_light_classifier_mobilenetv2_batch_1.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/ped_traffic_light_classifier_mobilenetv2_batch_4.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/ped_traffic_light_classifier_mobilenetv2_batch_6.onnx \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v2/lamp_labels.txt \
  https://awf.ml.dev.web.auto/perception/models/traffic_light_classifier/v3/lamp_labels_ped.txt"

  ["diffusion_planner/v0.1"]="\
  https://awf.ml.dev.web.auto/planning/models/diffusion_planner/v0.1/diffusion_planner.onnx \
  https://awf.ml.dev.web.auto/planning/models/diffusion_planner/v0.1/diffusion_planner.param.json"

  ["diffusion_planner/v1.0"]="\
  https://awf.ml.dev.web.auto/planning/models/diffusion_planner/v1.0/diffusion_planner.onnx \
  https://awf.ml.dev.web.auto/planning/models/diffusion_planner/v1.0/diffusion_planner.param.json"

  ["traffic_light_fine_detector"]="\
  https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_car_ped_yolox_s_batch_1.onnx \
  https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_car_ped_yolox_s_batch_4.onnx \
  https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_car_ped_yolox_s_batch_6.onnx \
  https://awf.ml.dev.web.auto/perception/models/tlr_yolox_s/v3/tlr_labels.txt"

  ["simpl_prediction"]="https://awf.ml.dev.web.auto/perception/models/simpl/v0.1.0/simpl.onnx"

  ["ptv3"]="\
  https://awf.ml.dev.web.auto/perception/models/ptv3/v1/ptv3.onnx \
  https://awf.ml.dev.web.auto/perception/models/ptv3/v1/ml_package_ptv3.param.yaml"

  ["lidar_frnet"]="\
  https://awf.ml.dev.web.auto/perception/models/frnet/v1/frnet.onnx \
  https://awf.ml.dev.web.auto/perception/models/frnet/v1/ml_package_frnet.param.yaml"

  ["calibration_status_classifier"]="\
  https://awf.ml.dev.web.auto/sensing/models/calibration_status_classifier/v1/calibration_status_classifier.onnx \
  https://awf.ml.dev.web.auto/sensing/models/calibration_status_classifier/v1/ml_package_calibration_status_classifier.param.yaml"
)

# Function for download models
download_files() {
  local dir=$1
  local urls=$2

  if [ ! -d "$dir" ]; then
    echo "Creating directory $dir"
    mkdir -p "$dir"
  fi

  for url in $urls; do
    local file_name=$(basename "$url")
    if [ ! -f "$dir/$file_name" ]; then
      echo "Downloading $file_name into $dir"
      wget -P "$dir" "$url"
    else
      echo "$file_name already exists in $dir, skipping download."
    fi
  done
}

# Start to download all models into $MODELS_PATH
for model in "${!models[@]}"; do
  model_dir=$MODELS_PATH/$model
  download_files "$model_dir" "${models[$model]}"
done

echo "All models downloaded or already exist."
