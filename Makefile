.PHONY: prepare \
		build \
		clean

build_bridge:
	cd external/zenoh_carla_bridge && cargo build --release
	poetry config virtualenvs.in-project true # Make sure poetry install .venv under carla_agent
	cd external/zenoh_carla_bridge/carla_agent && poetry install --no-root

build_autoware:
	colcon build --symlink-install --base-paths src --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

lint_bridge:
	cd external/zenoh_carla_bridge && cargo clippy --all -- -W clippy::all -W clippy::pedantic -W clippy::restriction -W clippy::nursery -D warnings

prepare_bridge:
	# Get code
	git submodule update --init --recursive
	# Install dependencies
	./script/dependency_install.sh rust
	./script/dependency_install.sh python

prepare_autoware:
	# Get code
	git submodule update --init --recursive
	# Install dependencies
	./script/dependency_install.sh rust
	./script/dependency_install.sh zenoh
	# Install necessary ROS package
	./script/download_map.sh
	sudo apt update
	rosdep update --rosdistro=${ROS_DISTRO}
	rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO}

clean_bridge:
	rm -rf external/zenoh_carla_bridge/carla_agent/.venv
	rm -rf bridge_log

clean_autoware:
	rm -rf install log build
	rm -rf autoware_log

clean: clean_bridge clean_autoware

docker_clean: clean
	rm -rf rust poetry pyenv

