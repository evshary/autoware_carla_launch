#!/usr/bin/env python3
import math
import os
import random
import threading
import time

import carla
import numpy as np
import rclpy
from autoware_vehicle_msgs.msg import (
    ControlModeReport, GearCommand, GearReport, HazardLightsCommand, HazardLightsReport,
    SteeringReport, TurnIndicatorsCommand, TurnIndicatorsReport, VelocityReport,
)
from builtin_interfaces.msg import Time
from rclpy.executors import MultiThreadedExecutor
from sensor_msgs.msg import PointCloud2, PointField
from tier4_control_msgs.msg import GateMode
from tier4_vehicle_msgs.msg import ActuationCommandStamped, ActuationStatusStamped

# Lidar: PointXYZI -> PointXYZIRC, cancel CARLA --ros2's Y flip with [-y, x, z]
LIDAR_IN_DTYPE = np.dtype([('x', 'f4'), ('y', 'f4'), ('z', 'f4'), ('intensity', 'f4')])
LIDAR_OUT_DTYPE = np.dtype([('x', 'f4'), ('y', 'f4'), ('z', 'f4'), ('intensity', 'u1'), ('return_type', 'u1'), ('channel', 'u2')])
LIDAR_OUT_FIELDS = [
    PointField(name='x', offset=0, datatype=PointField.FLOAT32, count=1),
    PointField(name='y', offset=4, datatype=PointField.FLOAT32, count=1),
    PointField(name='z', offset=8, datatype=PointField.FLOAT32, count=1),
    PointField(name='intensity', offset=12, datatype=PointField.UINT8, count=1),
    PointField(name='return_type', offset=13, datatype=PointField.UINT8, count=1),
    PointField(name='channel', offset=14, datatype=PointField.UINT16, count=1),
]


def main(args=None):
    VEHICLE = os.environ.get('CARLA_VEHICLE', 'v1')
    IS_MASTER = VEHICLE == 'v1'

    client = carla.Client(os.environ.get('CARLA_SIMULATOR_IP', 'localhost'), 2000)
    client.set_timeout(60.0)
    if IS_MASTER:
        world = client.load_world('Town01')
        settings = world.get_settings()
        settings.synchronous_mode = True
        settings.fixed_delta_seconds = 0.05
        world.apply_settings(settings)
        world.tick()   # apply settings before spawn
    else:
        world = client.get_world()

    # Vehicle
    bp = world.get_blueprint_library().find('vehicle.tesla.model3')
    bp.set_attribute('role_name', 'hero')
    bp.set_attribute('ros_name', VEHICLE)
    pos = os.environ.get('CARLA_SPAWN_POSITION')
    if pos:
        x, y, z, pitch, yaw, roll = (float(v) for v in pos.split(','))
        sp = carla.Transform(carla.Location(x, y, z), carla.Rotation(pitch, yaw, roll))
    else:
        sp = random.choice(world.get_map().get_spawn_points())
    vehicle = world.spawn_actor(bp, sp)

    # Lidar
    lidar_bp = world.get_blueprint_library().find('sensor.lidar.ray_cast')
    lidar_bp.set_attribute('range', '100')
    lidar_bp.set_attribute('rotation_frequency', '20')
    lidar_bp.set_attribute('channels', '64')
    lidar_bp.set_attribute('upper_fov', '10')
    lidar_bp.set_attribute('lower_fov', '-30')
    lidar_bp.set_attribute('points_per_second', '600000')
    lidar_bp.set_attribute('atmosphere_attenuation_rate', '0.004')
    lidar_bp.set_attribute('dropoff_general_rate', '0.45')
    lidar_bp.set_attribute('dropoff_intensity_limit', '0.8')
    lidar_bp.set_attribute('dropoff_zero_intensity', '0.4')
    lidar_bp.set_attribute('ros_name', 'top')
    lidar_bp.set_attribute('ros_frame_id', 'velodyne_top_base_link')
    lidar_bp.set_attribute('ros_publish_tf', 'false')
    lidar = world.spawn_actor(lidar_bp, carla.Transform(carla.Location(z=2.4), carla.Rotation(yaw=270.0)), attach_to=vehicle)
    lidar.listen(lambda data: None)

    # Camera
    cam_bp = world.get_blueprint_library().find('sensor.camera.rgb')
    cam_bp.set_attribute('ros_name', 'traffic_light')
    cam_bp.set_attribute('ros_frame_id', 'camera4/camera_link')
    cam_bp.set_attribute('ros_publish_tf', 'false')
    camera = world.spawn_actor(cam_bp, carla.Transform(carla.Location(x=2.3, z=1.6)), attach_to=vehicle, attachment_type=carla.AttachmentType.Rigid)
    camera.listen(lambda data: None)

    # IMU
    imu_bp = world.get_blueprint_library().find('sensor.other.imu')
    imu_bp.set_attribute('noise_accel_stddev_x', '0.0')
    imu_bp.set_attribute('noise_accel_stddev_y', '0.0')
    imu_bp.set_attribute('noise_accel_stddev_z', '0.0')
    imu_bp.set_attribute('noise_gyro_stddev_x', '0.0')
    imu_bp.set_attribute('noise_gyro_stddev_y', '0.0')
    imu_bp.set_attribute('noise_gyro_stddev_z', '0.0')
    imu_bp.set_attribute('ros_name', 'tamagawa')
    imu_bp.set_attribute('ros_frame_id', 'tamagawa/imu_link')
    imu_bp.set_attribute('ros_publish_tf', 'false')
    imu = world.spawn_actor(imu_bp, carla.Transform(carla.Location(z=2.4), carla.Rotation(yaw=270.0)), attach_to=vehicle)
    imu.listen(lambda data: None)

    # GNSS
    gnss_bp = world.get_blueprint_library().find('sensor.other.gnss')
    gnss_bp.set_attribute('noise_alt_stddev', '0.0')
    gnss_bp.set_attribute('noise_lat_stddev', '0.0')
    gnss_bp.set_attribute('noise_lon_stddev', '0.0')
    gnss_bp.set_attribute('noise_alt_bias', '0.0')
    gnss_bp.set_attribute('noise_lat_bias', '0.0')
    gnss_bp.set_attribute('noise_lon_bias', '0.0')
    gnss_bp.set_attribute('ros_name', 'ublox')
    gnss_bp.set_attribute('ros_frame_id', 'gnss_link')
    gnss_bp.set_attribute('ros_publish_tf', 'false')
    gnss = world.spawn_actor(gnss_bp, carla.Transform(carla.Location(z=2.4)), attach_to=vehicle)
    gnss.listen(lambda data: None)

    print('All sensors spawned!')

    # /clock is published by CARLA --ros2 itself, no need to duplicate.
    rclpy.init(args=args)
    node = rclpy.create_node('carla_vehicle_status')

    latest_actuation = {'accel': 0.0, 'brake': 0.0, 'steer': 0.0}
    latest_gear = GearCommand.DRIVE
    latest_gate_mode = GateMode.AUTO

    def lidar_cb(msg):
        in_arr = np.frombuffer(msg.data, dtype=LIDAR_IN_DTYPE)
        out_arr = np.empty(len(in_arr), dtype=LIDAR_OUT_DTYPE)
        out_arr['x'] = -in_arr['y']
        out_arr['y'] = in_arr['x']
        out_arr['z'] = in_arr['z']
        out_arr['intensity'] = np.clip(in_arr['intensity'] * 255, 0, 255).astype('u1')
        out_arr['return_type'] = 0
        out_arr['channel'] = 0
        out = PointCloud2()
        out.header = msg.header
        out.height = 1
        out.width = len(in_arr)
        out.fields = LIDAR_OUT_FIELDS
        out.is_bigendian = msg.is_bigendian
        out.point_step = 16
        out.row_step = 16 * len(in_arr)
        out.data = out_arr.tobytes()
        out.is_dense = True
        pub_lidar.publish(out)

    def actuation_cb(msg):
        latest_actuation['accel'] = msg.actuation.accel_cmd
        latest_actuation['brake'] = msg.actuation.brake_cmd
        latest_actuation['steer'] = msg.actuation.steer_cmd

    def gear_cb(msg):
        nonlocal latest_gear
        latest_gear = msg.command

    def gate_mode_cb(msg):
        nonlocal latest_gate_mode
        latest_gate_mode = msg.data

    # Publishers + Subscribers
    pub_lidar = node.create_publisher(PointCloud2, f'/carla/{VEHICLE}/top/pointcloud_ex', 10)
    pub_vel = node.create_publisher(VelocityReport, '/vehicle/status/velocity_status', 10)
    pub_steer = node.create_publisher(SteeringReport, '/vehicle/status/steering_status', 10)
    pub_gear = node.create_publisher(GearReport, '/vehicle/status/gear_status', 10)
    pub_mode = node.create_publisher(ControlModeReport, '/vehicle/status/control_mode', 10)
    pub_turn = node.create_publisher(TurnIndicatorsReport, '/vehicle/status/turn_indicators_status', 10)
    pub_haz = node.create_publisher(HazardLightsReport, '/vehicle/status/hazard_lights_status', 10)
    pub_actuation_status = node.create_publisher(ActuationStatusStamped, '/vehicle/status/actuation_status', 10)
    node.create_subscription(PointCloud2, f'/carla/{VEHICLE}/top/point_cloud', lidar_cb, 10)
    node.create_subscription(ActuationCommandStamped, '/control/command/actuation_cmd', actuation_cb, 10)
    node.create_subscription(GearCommand, '/control/command/gear_cmd', gear_cb, 10)
    node.create_subscription(GateMode, '/control/current_gate_mode', gate_mode_cb, 10)
    node.create_subscription(TurnIndicatorsCommand, '/control/command/turn_indicators_cmd', lambda msg: None, 10)
    node.create_subscription(HazardLightsCommand, '/control/command/hazard_lights_cmd', lambda msg: None, 10)

    executor = MultiThreadedExecutor()
    executor.add_node(node)
    threading.Thread(target=executor.spin, daemon=True).start()

    try:
        while rclpy.ok():
            if IS_MASTER:
                world.tick()
            else:
                world.wait_for_tick()
            sim_sec = world.get_snapshot().timestamp.elapsed_seconds
            stamp = Time(sec=int(sim_sec), nanosec=int((sim_sec - int(sim_sec)) * 1_000_000_000))

            velocity = vehicle.get_velocity()
            control = vehicle.get_control()
            try:
                steer_rad = math.radians(vehicle.get_wheel_steer_angle(carla.VehicleWheelLocation.FL_Wheel))
            except Exception:
                steer_rad = 0.0
            speed = math.sqrt(velocity.x ** 2 + velocity.y ** 2 + velocity.z ** 2)
            if control.reverse:
                speed = -speed

            v = VelocityReport()
            v.header.stamp = stamp
            v.header.frame_id = 'base_link'
            v.longitudinal_velocity = speed
            v.lateral_velocity = 0.0
            v.heading_rate = -steer_rad
            pub_vel.publish(v)

            s = SteeringReport()
            s.stamp = stamp
            s.steering_tire_angle = -steer_rad
            pub_steer.publish(s)

            g = GearReport()
            g.stamp = stamp
            g.report = latest_gear
            pub_gear.publish(g)

            m = ControlModeReport()
            m.stamp = stamp
            m.mode = 1 if latest_gate_mode == GateMode.AUTO else 4   # 1=AUTONOMOUS, 4=MANUAL
            pub_mode.publish(m)

            t = TurnIndicatorsReport()
            t.stamp = stamp
            t.report = 1
            pub_turn.publish(t)

            h = HazardLightsReport()
            h.stamp = stamp
            h.report = 1
            pub_haz.publish(h)

            a = ActuationStatusStamped()
            a.header.stamp = stamp
            a.header.frame_id = 'base_link'
            a.status.accel_status = float(control.throttle)
            a.status.brake_status = float(control.brake)
            a.status.steer_status = float(-control.steer)
            pub_actuation_status.publish(a)

            reverse = latest_gear == GearCommand.REVERSE
            hand_brake = latest_gear == GearCommand.PARK
            accel = 0.0 if hand_brake else latest_actuation['accel']
            brake = 0.0 if hand_brake else latest_actuation['brake']
            steer = 0.0 if hand_brake else -latest_actuation['steer']
            vehicle.apply_control(carla.VehicleControl(
                throttle=float(accel), brake=float(brake), steer=float(steer),
                hand_brake=hand_brake, reverse=reverse, manual_gear_shift=False, gear=0,
            ))

            time.sleep(0.05)   # match fixed_delta_seconds for ~1x real-time
    except KeyboardInterrupt:
        pass
    finally:
        # Clean shutdown: destroy spawned actors and undo the world's synchronous
        # mode, otherwise stale actors pile up and the server stays frozen waiting
        # for ticks, which breaks the next run.
        print('Shutting down: destroying actors and restoring world settings...')
        for actor in (gnss, imu, camera, lidar, vehicle):
            try:
                actor.destroy()
            except Exception:
                pass
        if IS_MASTER:
            try:
                settings = world.get_settings()
                settings.synchronous_mode = False
                world.apply_settings(settings)
            except Exception:
                pass
        executor.shutdown()
        node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()


if __name__ == '__main__':
    main()
