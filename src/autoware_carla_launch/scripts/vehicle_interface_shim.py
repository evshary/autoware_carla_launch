#!/usr/bin/env python3
# Carla vehicle-interface stand-in: answers /control/control_mode_request and
# publishes /vehicle/status/control_mode (simple_planning_simulator's job in
# the built-in sim). Runs in the Autoware DDS domain so engage needs no Zenoh
# hop; zenoh_carla_bridge stays pure data-transport.

import rclpy
from rclpy.clock import Clock, ClockType
from rclpy.node import Node

from autoware_vehicle_msgs.msg import ControlModeReport
from autoware_vehicle_msgs.srv import ControlModeCommand


class VehicleInterfaceShim(Node):
    def __init__(self):
        super().__init__("vehicle_interface_shim")
        self._mode = ControlModeReport.MANUAL
        self._srv = self.create_service(
            ControlModeCommand, "/control/control_mode_request", self._on_request
        )
        self._pub = self.create_publisher(
            ControlModeReport, "/vehicle/status/control_mode", 1
        )
        # Wall clock: use_sim_time is injected globally but this node has no
        # /clock source, so a node-clock timer would stall when /clock does.
        self.create_timer(
            0.1, self._publish, clock=Clock(clock_type=ClockType.STEADY_TIME)
        )

    def _on_request(self, req, res):
        res.success = True  # reply, then latch the accepted mode
        self._mode = req.mode
        return res

    def _publish(self):
        msg = ControlModeReport()
        msg.stamp = self.get_clock().now().to_msg()
        msg.mode = self._mode
        self._pub.publish(msg)


def main():
    rclpy.init()
    node = VehicleInterfaceShim()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()
