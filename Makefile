.PHONY: prepare \
		build \
		clean

build:
	cd external/zenoh-plugin-dds && cargo build --release -p zenoh-bridge-dds
	cd external/carla_autoware_zenoh_bridge && cargo build --release
	cd external/carla_autoware_zenoh_bridge/carla_agent && poetry install --no-root
	colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

prepare:
	curl https://sh.rustup.rs -sSf | bash -s -- -y
	curl -sSL https://install.python-poetry.org | python3 -
	vcs import src < autoware_carla.repos
	git submodule update --init --recursive
	./download_map.sh
	rosdep update --rosdistro=${ROS_DISTRO}
	rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO}

clean:
	cd external/zenoh-plugin-dds && cargo clean
	cd external/carla_autoware_zenoh_bridge && cargo clean
	rm -rf install log build

