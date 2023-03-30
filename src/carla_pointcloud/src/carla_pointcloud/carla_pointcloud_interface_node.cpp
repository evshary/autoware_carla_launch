
#include "carla_pointcloud/carla_pointcloud_interface_node.hpp"

#include <pcl_ros/transforms.hpp>

void PointCloudInterface::processScan(const sensor_msgs::msg::PointCloud2::SharedPtr scanMsg)
{
    sensor_msgs::msg::PointCloud2 transformed_cloud;
    if (pcl_ros::transformPointCloud(tf_output_frame_, *scanMsg, transformed_cloud, *tf_buffer_)) {
        transformed_cloud.header.stamp = scanMsg->header.stamp;
        velodyne_points_localization->publish(transformed_cloud);
        velodyne_points_perception->publish(transformed_cloud);
    }
}

void PointCloudInterface::setupTF()
{
    tf_buffer_ = std::make_shared<tf2_ros::Buffer>(this->get_clock());
    tf_listener_ = std::make_shared<tf2_ros::TransformListener>(*tf_buffer_);
}

PointCloudInterface::~PointCloudInterface()
{
}

PointCloudInterface::PointCloudInterface(const rclcpp::NodeOptions & node_options)
: Node("carla_pointcloud_interface_node", node_options), tf_output_frame_("base_link")
{
    carla_cloud_ =
            this->create_subscription<sensor_msgs::msg::PointCloud2>(
            "carla_pointcloud", rclcpp::SensorDataQoS(),
            std::bind(&PointCloudInterface::processScan, this, std::placeholders::_1));

    velodyne_points_localization =
            this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/top/outlier_filtered/pointcloud", rclcpp::SensorDataQoS());
    velodyne_points_perception =
            this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/concatenated/pointcloud", rclcpp::SensorDataQoS());

    setupTF();
}

#include "rclcpp_components/register_node_macro.hpp"
RCLCPP_COMPONENTS_REGISTER_NODE(PointCloudInterface)
