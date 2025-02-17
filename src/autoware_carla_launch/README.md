# autoware_carla_launch

Calibration maps and configuration file are sourced from [`autoware_carla_interface`](https://github.com/autowarefoundation/autoware.universe/tree/0.41.1/simulator/autoware_carla_interface) due to the same vehicle model.

## Calibration Maps
Calibration maps for acceleration, braking, and steering commands from Autoware to CARLA vehicle inputs.
- `calibration_maps/accel_map.csv`
- `calibration_maps/brake_map.csv`
- `calibration_maps/steer_map.csv`

## Configuration File
- **`config/raw_vehicle_cmd_converter.param.yaml`**: Configures `autoware_raw_vehicle_cmd_converter_node`, specifying calibration maps and parameters for vehicle command translation.
