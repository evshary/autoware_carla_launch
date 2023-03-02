.PHONY: prepare \
		build \
		clean

build:
	cd external/zenoh-plugin-dds && cargo build --release -p zenoh-bridge-dds
	cd external/carla_autoware_zenoh_bridge && cargo build --release
	cd external/carla_autoware_zenoh_bridge/carla_agent && poetry install --no-root
	colcon build --symlink-install

prepare:	
	git submodule update --init --recursive
	cd ./src/autoware_carla_launch && ./download_map.sh
	rosdep install -y --from-paths src --ignore-src --rosdistro galactic

clean:
	cd external/zenoh-plugin-dds && cargo clean
	cd external/carla_autoware_zenoh_bridge && cargo clean
	rm -rf install log build

