# autoware_carla_launch

The package includes launch file to run Autoware, Carla agent, and bridge ([zenoh-bridge-ros2dds](https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds) + [zenoh_carla_bridge](https://github.com/evshary/zenoh_carla_bridge)).

## Useful link

* [Documentation](https://autoware-carla-launch.readthedocs.io/en/latest/)
* [FAQ](https://autoware-carla-launch.readthedocs.io/en/latest/faq.html)
* [Introduction on Autoware website](https://autoware.org/running-multiple-autoware-powered-vehicles-in-carla-using-zenoh/)

## Demo

* Run multiple vehicles with Autoware Humble in Carla

[![IMAGE ALT TEXT](http://img.youtube.com/vi/lrFucLUWbDo/0.jpg)](https://youtu.be/lrFucLUWbDo "Run multiple vehicles with Autoware Humble in Carla")

* Zenoh FMS with Autoware in Carla

[![IMAGE ALT TEXT](http://img.youtube.com/vi/QCt7YoSF6LQ/0.jpg)](https://youtu.be/QCt7YoSF6LQ "Zenoh FMS with Autoware in Carla")

## Optional: Enable Zenoh Shared Memory in `rmw_zenoh`

`rmw_zenoh` supports Zenoh's Shared Memory (SHM) transport, but it is disabled by default in this repository.
`zenoh_carla_bridge` uses SHM by default, while Autoware with `rmw_zenoh` keeps it disabled because it may cause components to fail to be loaded randomly, which can lead to planning failures. This is a known issue and not fixed yet.

In the following scripts:

* `script/autoware_rmw_zenoh/run-autoware-with-rmw_zenoh.sh`
* `script/autoware_rmw_zenoh/run-autoware-traffic-light-with-rmw_zenoh.sh`

there are SHM-related environment variables already prepared but commented out.

To enable SHM, simply uncomment these three lines. The default SHM size in this repository is currently set to **256 MiB**. `ZENOH_SHM_ALLOC_SIZE` and `ZENOH_SHM_MESSAGE_SIZE_THRESHOLD` can be adjusted based on the workload and the available `/dev/shm`.

   ```bash
   # Enable Zenoh shared memory
   # export ZENOH_CONFIG_OVERRIDE="namespace=\"${VEHICLE_NAME}\";transport/shared_memory/enabled=true"
   # export ZENOH_SHM_ALLOC_SIZE=$((256 * 1024 * 1024))       # 256 MiB SHM arena per context
   # export ZENOH_SHM_MESSAGE_SIZE_THRESHOLD=1024             # use SHM for msgs > 1 KiB
   ```
