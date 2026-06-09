.PHONY: prepare_autoware \
		build_autoware \
		clean_autoware \
		clean

prepare_autoware:
	# Install necessary ROS package
	./script/setup/download_map.sh
	./script/setup/download_models.sh
	sudo apt update
	rosdep update --rosdistro=${ROS_DISTRO}
	rosdep install -y --from-paths src --ignore-src --rosdistro ${ROS_DISTRO}
	# Prebuild models
	./script/setup/build_models.sh

build_autoware:
	colcon build --symlink-install --base-paths src --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

clean_autoware:
	rm -rf install log build
	rm -rf autoware_log

clean: clean_autoware
