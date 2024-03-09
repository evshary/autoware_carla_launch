.PHONY: default \
	prepare \
	prepare_autoware \
	prepare_bridge \
	build \
	build_autoware \
	build_bridge \
	lint_bridge \
	clean \
	clean_docker \
	clean_autoware \
	clean_bridge

default:
	@echo 'Usage:'
	@echo
	@echo 'make prepare'
	@echo '	Install required dependencies.'
	@echo
	@echo 'make build'
	@echo '	Build the whole project.'
	@echo
	@echo 'make clean'
	@echo '	Clean up build output and artifacts.'

build: build_bridge build_autoware

build_bridge:
	cd external/zenoh_carla_bridge && \
	cargo build --release

	poetry config virtualenvs.in-project true # Make sure poetry install .venv under carla_agent

	cd external/zenoh_carla_bridge/carla_agent && \
	poetry install --no-root

build_autoware:
	colcon build \
		--symlink-install \
		--base-paths src \
		--cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

lint_bridge:
	cd external/zenoh_carla_bridge && \
	cargo clippy --all -- \
		-W clippy::all \
		-W clippy::pedantic \
		-W clippy::restriction \
		-W clippy::nursery \
		-D warnings

prepare: prepare_bridge prepare_autoware

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

clean_docker: clean
	rm -rf rust poetry pyenv
