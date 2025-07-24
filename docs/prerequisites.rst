Prerequisites
=============

Make sure you meet the following system requirements

* Ubuntu 22.04
* Carla 0.9.14 - `download <https://github.com/carla-simulator/carla/releases/tag/0.9.14>`_

Packages Installation
---------------------

Install rocker for containers

..  code-block:: bash

    sudo apt install docker.io python3-rocker

.. note::
    `python3-rocker` is provided by the ROS 2. 
    To install it, you should first configure Ubuntu for ROS 2 repositories. 
    You can refer to the official documentation for installation steps:
    https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html.

    The following steps will guide you in configuring ROS 2 repositories and install `python3-rocker`:

    .. code-block:: bash

        sudo apt install software-properties-common
        sudo add-apt-repository universe
        sudo apt update && sudo apt install curl -y
        export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
        curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb"
        sudo dpkg -i /tmp/ros2-apt-source.deb
        sudo apt update
        sudo apt install python3-rocker