
#ifndef MODEL_LOG_NODE_HPP_
#define MODEL_LOG_NODE_HPP_

#include "rclcpp/rclcpp.hpp"
#include <sensor_msgs/msg/point_cloud2.hpp>
#include <tf2_ros/buffer.h>
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
    rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_combined_ex_pub_;
    rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_localization;
    rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr velodyne_points_perception;

    std::shared_ptr<tf2_ros::Buffer> tf_buffer_;
    std::shared_ptr<tf2_ros::TransformListener> tf_listener_;
    std::string tf_output_frame_;

    void processScan(const sensor_msgs::msg::PointCloud2::SharedPtr scanMsg);
    void setupTF();
};

#endif  // MODEL_LOG_NODE_HPP_
