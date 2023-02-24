
#ifndef MODEL_LOG_NODE_HPP_
#define MODEL_LOG_NODE_HPP_

#include <string>
#include <vector>
#include <ostream>
#include <algorithm>
#include <fstream>
#include "rclcpp/rclcpp.hpp"
#include <tf2/convert.h>
#include <tf2/transform_datatypes.h>
#include <sensor_msgs/msg/point_cloud2.hpp>
#include <velodyne_pointcloud/pointcloudXYZIRADT.h>
#include <tf2_ros/buffer.h>
#include <tf2_ros/create_timer_ros.h>
#include <tf2_ros/transform_listener.h>
#include <autoware_auto_control_msgs/msg/ackermann_control_command.hpp>

class PointCloudInterface : public rclcpp::Node
{
public:
   explicit PointCloudInterface(const rclcpp::NodeOptions & node_options);
   virtual ~PointCloudInterface();
  
private:

  rclcpp::Subscription<sensor_msgs::msg::PointCloud2>::SharedPtr carla_cloud_;
  rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_pub_;
  rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_ex_pub_;
//  rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_invalid_near_pub_;
  rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_combined_ex_pub_;
  rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_localization;
  rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_perception;


  std::shared_ptr<tf2_ros::Buffer> tf_buffer_;
  std::shared_ptr<tf2_ros::TransformListener> tf_listener_;
  std::string tf_output_frame_;
  bool b_create_ex_;


  void processScan(const sensor_msgs::msg::PointCloud2::SharedPtr scanMsg);

  void CalculatedExtendedCloudInformation(const pcl::PointXYZI& point, float& distance, int& azimuth, int& ring_id);

  void setupTF();
//
//  rclcpp::Publisher<autoware_auto_control_msgs::msg::AckermannControlCommand>::SharedPtr control_pub;
//  rclcpp::Subscription<autoware_auto_control_msgs::msg::AckermannControlCommand>::SharedPtr auto_control_cmd;
//  void onAutoCtrlCmd(autoware_auto_control_msgs::msg::AckermannControlCommand::ConstSharedPtr msg)
//  {
//	  std::cout << "Current Required Speed: >>> " << msg->longitudinal.speed << std::endl;
//	  control_pub->publish(*msg);
//  }

};

#endif  // MODEL_LOG_NODE_HPP_
