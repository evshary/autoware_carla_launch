
#include "carla_pointcloud/carla_pointcloud_interface_node.hpp"

#include <pcl_conversions/pcl_conversions.h>
#include <velodyne_pointcloud/pointcloudXYZIRADT.h>
#include <yaml-cpp/yaml.h>
#include <velodyne_pointcloud/func.h>
#include <velodyne_pointcloud/rawdata.h>
#include <pcl_ros/transforms.hpp>

//#include <pcl/io/io.h>
#include <memory>

void PointCloudInterface::processScan(const sensor_msgs::msg::PointCloud2::SharedPtr scanMsg)
{
	if(b_create_ex_)
	{
		pcl::PointCloud<pcl::PointXYZI>::Ptr msg_cloud(new pcl::PointCloud<pcl::PointXYZI>);

		pcl::fromROSMsg(*scanMsg, *msg_cloud);

		velodyne_pointcloud::PointcloudXYZIRADT scan_points_xyziradt;
		velodyne_pointcloud::PointXYZIRADT ex_p;

		for(auto& p: msg_cloud->points)
		{
			float d = 0;
			int ring_id = 0;
			int azimuth = 0;
			CalculatedExtendedCloudInformation(p, d, azimuth, ring_id);
			scan_points_xyziradt.addPoint(p.x, p.y, p.z,
			velodyne_rawdata::RETURN_TYPE::DUAL_ONLY, ring_id, azimuth,
			d, p.intensity,
			rclcpp::Time(scanMsg->header.stamp).seconds());

		  scan_points_xyziradt.pc->points.push_back(ex_p);
		}

//		std::cout << "CARLA CARLA EX >>>> Received Cloud : " << msg_cloud->points.size() << ", Converted: " << scan_points_xyziradt.pc->points.size() << std::endl;

		scan_points_xyziradt.pc->header = pcl_conversions::toPCL(scanMsg->header);

		// Find timestamp from first/last point (and maybe average)?
		double first_point_timestamp = scan_points_xyziradt.pc->points.front().time_stamp;
		// double last_point_timestamp = scan_points_xyziradt.pc->points.back().time_stamp;
		// double average_timestamp = (first_point_timestamp + last_point_timestamp)/2;
		scan_points_xyziradt.pc->header.stamp =
		  pcl_conversions::toPCL(rclcpp::Time(std::chrono::duration_cast<std::chrono::nanoseconds>(
				  std::chrono::duration<double>((first_point_timestamp))).count()));
		  //pcl_conversions::toPCL(scanMsg->packets[0].stamp - ros::Duration(0.0));
		scan_points_xyziradt.pc->height = 1;
		scan_points_xyziradt.pc->width = scan_points_xyziradt.pc->points.size();

		  pcl::PointCloud<velodyne_pointcloud::PointXYZIRADT>::Ptr valid_points_xyziradt(new pcl::PointCloud<velodyne_pointcloud::PointXYZIRADT>);
		  valid_points_xyziradt = velodyne_pointcloud::extractValidPoints(scan_points_xyziradt.pc, 0.5, 120.0);
		  const auto valid_points_xyzir = convert(valid_points_xyziradt);
		  if (
		  	    velodyne_points_pub_->get_subscription_count() > 0 ||
		  	    velodyne_points_ex_pub_->get_subscription_count() > 0 ||
		  	    velodyne_points_combined_ex_pub_->get_subscription_count() > 0)
		  	  {

		  	    if (velodyne_points_pub_->get_subscription_count() > 0)
		  	    {
		  	      auto ros_pc_msg_ptr = std::make_unique<sensor_msgs::msg::PointCloud2>();
		  	      pcl::toROSMsg(*valid_points_xyzir, *ros_pc_msg_ptr);
		  	      velodyne_points_pub_->publish(std::move(ros_pc_msg_ptr));
		  	    }
		  	    if (velodyne_points_ex_pub_->get_subscription_count() > 0)
		  	    {
		  	      auto ros_pc_msg_ptr = std::make_unique<sensor_msgs::msg::PointCloud2>();
		  	      pcl::toROSMsg(*valid_points_xyziradt, *ros_pc_msg_ptr);
		  	      velodyne_points_ex_pub_->publish(std::move(ros_pc_msg_ptr));
		  	    }
		  	  }
	}
	else
	{
//		std::cout << "CARLA CARLA >>>> Received Cloud : " << scanMsg << ", Converted: " << std::endl;
		sensor_msgs::msg::PointCloud2 transformed_cloud;
		if (pcl_ros::transformPointCloud(tf_output_frame_, *scanMsg, transformed_cloud, *tf_buffer_))
		{
			transformed_cloud.header.stamp = scanMsg->header.stamp;
			velodyne_points_localization->publish(transformed_cloud);
			velodyne_points_perception->publish(transformed_cloud);
		}
	}



}

void PointCloudInterface::CalculatedExtendedCloudInformation(const pcl::PointXYZI& point, float& distance, int& azimuth, int& ring_id)
{
	static float tmp[32]={-30.67,-29.33,-28.00, -26.66,-25.33,-24.00,-22.67,-21.33,-20.00,
			-18.67,-17.33,-16.00,-14.67,-13.33,-12.00,-10.67,-9.33,-8.00,
			-6.66,-5.33,-4.00,-2.67,-1.33,0.00,1.33,2.67,4.00,5.33,6.67,8.00,
			9.33,10.67};
	std::vector<float> angle_v_beam = std::vector<float>(tmp, tmp + 32);	// vertical angle of beams

	/* Calculate beam id of each point */
	float xy = std::sqrt(point.x * point.x + point.y * point.y);
	float r = std::sqrt(point.x * point.x + point.y * point.y + point.z * point.z);
	float angle_v = std::abs(std::acos(xy / r) / M_PI * 180.0);	// vertical angle of the point

	if(point.z < 0)
	{
		angle_v =- angle_v;
	}

	int beam_id = 0;
	float angle_v_min = std::abs(angle_v - angle_v_beam.front());
	for(unsigned int id = 1; id < angle_v_beam.size(); id++)
	{
		float d = std::abs(angle_v - angle_v_beam[id]);
		if(d < angle_v_min)
		{
			angle_v_min = d;
			beam_id = id;
		}
	}


	azimuth = std::atan2(point.y,point.x)/M_PI*180.0;
	ring_id = beam_id;
//	float xz = std::sqrt((point.y * point.y) + (point.z * point.z));
	distance = xy;
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
: Node("carla_pointcloud_interface_node", node_options), tf_output_frame_("base_link"), b_create_ex_(false)
{

	carla_cloud_ =
		    this->create_subscription<sensor_msgs::msg::PointCloud2>(
		    "carla_pointcloud", rclcpp::SensorDataQoS(),
		    std::bind(&PointCloudInterface::processScan, this, std::placeholders::_1));

//	auto_control_cmd =
//		    this->create_subscription<autoware_auto_control_msgs::msg::AckermannControlCommand>(
//		    "/control/command/control_cmd", rclcpp::SensorDataQoS(),
//		    std::bind(&PointCloudInterface::onAutoCtrlCmd, this, std::placeholders::_1));
//  rclcpp::QoS durable_qos{1};
//  durable_qos.transient_local();
//	control_pub = this->create_publisher<autoware_auto_control_msgs::msg::AckermannControlCommand>("carla_interface_control_cmd", 1);


	if(b_create_ex_)
	{
	  velodyne_points_pub_ = this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/top/pointcloud_raw", rclcpp::SensorDataQoS());
	  velodyne_points_ex_pub_ = this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/top/pointcloud_raw_ex", rclcpp::SensorDataQoS());
	  velodyne_points_combined_ex_pub_ =
	    this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/top/pointcloud_combined_ex", rclcpp::SensorDataQoS());
	}
	else
	{
		velodyne_points_localization =
			    this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/top/outlier_filtered/pointcloud", rclcpp::SensorDataQoS());
		velodyne_points_perception =
			    this->create_publisher<sensor_msgs::msg::PointCloud2>("/sensing/lidar/concatenated/pointcloud", rclcpp::SensorDataQoS());
	}

	setupTF();
}
// }

#include "rclcpp_components/register_node_macro.hpp"
RCLCPP_COMPONENTS_REGISTER_NODE(PointCloudInterface)
