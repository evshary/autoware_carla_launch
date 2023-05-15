.PHONY: prepare \
		build \
		clean

build_bridge:
	cd external/zenoh_carla_bridge && cargo build --release
	cd external/zenoh_carla_bridge/carla_agent && poetry install --no-root

build_autoware:
	colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cd external/zenoh-plugin-dds && cargo build --release -p zenoh-bridge-dds

prepare_bridge:
	# Install dependencies
	./script/dependency_install.sh rust
	./script/dependency_install.sh python
	git submodule update --init --recursive

prepare_autoware:
	# Install dependencies
	./script/dependency_install.sh rust
	# Install necessary ROS package
	vcs import src < autoware_carla.repos
	git submodule update --init --recursive
	./script/download_map.sh
	sudo apt update
	rosdep update --rosdistro=${ROS_DISTRO}
	rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO}

clean:
	cd external/zenoh-plugin-dds && cargo clean
	cd external/zenoh_carla_bridge && cargo clean
	rm -rf install log build
	rm -rf external/zenoh_carla_bridge/carla_agent/.venv

docker_clean: clean
	rm -rf rust poetry pyenv

