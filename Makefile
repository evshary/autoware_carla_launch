.PHONY: prepare_bridge \
		prepare_autoware \
		build_bridge \
		build_autoware \
		clean_bridge \
		clean_autoware \
		clean \
		docker_clean

prepare_bridge:
	# Get code
	git submodule update --init --recursive
	sudo apt update
	# Install rmw_zenoh
	./script/setup/build_zenoh.sh
	# Install dependencies
	./script/setup/dependency_install.sh rust
	./script/setup/dependency_install.sh python

prepare_autoware:
	# Get code
	git submodule update --init --recursive
	# Install dependencies
	./script/setup/dependency_install.sh rust
	# Install necessary ROS package
	./script/setup/download_map.sh
	./script/setup/download_models.sh
	sudo apt update
	rosdep update --rosdistro=${ROS_DISTRO}
	rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO}
	# Prebuild models
	./script/setup/build_models.sh

build_bridge:
	cd external/zenoh_carla_bridge && cargo build --release
	poetry config virtualenvs.in-project true # Make sure poetry install .venv under carla_agent
	cd external/zenoh_carla_bridge/carla_agent && poetry install --no-root

lint_bridge:
	# Run lint (TODO: to be fixed later)
	cd external/zenoh_carla_bridge && cargo clippy --all -- -W clippy::all -W clippy::pedantic -W clippy::restriction -W clippy::nursery -D warnings

build_autoware:
	colcon build --symlink-install --base-paths src --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cd external/zenoh-plugin-ros2dds && cargo build --release -p zenoh-bridge-ros2dds

clean_bridge:
	cd external/zenoh_carla_bridge && cargo clean
	rm -rf bridge_log

clean_autoware:
	cd external/zenoh-plugin-ros2dds && cargo clean
	rm -rf install log build
	rm -rf autoware_log

clean_zenoh:
	cd rmw_zenoh_ws && rm -rf install log build

clean: clean_bridge clean_autoware clean_zenoh

docker_clean: clean
	# Remove venv in Python
	rm -rf external/zenoh_carla_bridge/carla_agent/.venv
	# Remove other toolchains
	rm -rf rust poetry pyenv
