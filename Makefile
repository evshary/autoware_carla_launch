.PHONY: build \
	    clean

build:
	cd external/zenoh-plugin-dds && cargo build --release -p zenoh-bridge-dds
	cd external/carla_autoware_zenoh_bridge && cargo build --release
	colcon build --symlink-install

clean:
	cd external/zenoh-plugin-dds && cargo clean
	cd external/carla_autoware_zenoh_bridge && cargo clean
	rm -rf install log build

