# Systemd based Robot Initialization for ROS.
[![Build Status](https://www.travis-ci.org/LucidOne/robot_systemd.svg?branch=master)](https://www.travis-ci.org/LucidOne/robot_systemd)
[![Build Status](http://build.ros.org/buildStatus/icon?subject=Kinetic&job=Kbin_uX64__robot_systemd__ubuntu_xenial_amd64__binary)](http://build.ros.org/view/Kbin_uX64/job/Kbin_uX64__robot_systemd__ubuntu_xenial_amd64__binary/)

## TL;DR
```bash
# Install ROS...
sudo apt install ros-kinetic-robot-systemd
systemctl --user enable roslaunch@turtlebot_bringup:minimal.launch
systemctl --user start roslaunch@turtlebot_bringup:minimal.launch
# Start at bootup instead of graphical login
sudo loginctl enable-linger $USER
```

## Overview
The goal of [this package](https://github.com/LucidOne/robot_systemd) is to
provide infrastructure to start `roscore` and `roslaunch` that *works by
default*. OEMs and system integrators should also be able to depend on it to
build their own ROS packages that can customize the system startup to support
inevitable hardware variations. It also enables individual end-users to be able
to make personal customizations without being overwritten by vendor upgrades.

## Example Configuration
~/.ros/environment
```
ROS_DISTRO=kinetic
[ROS_INTERFACE=auto](https://github.com/LucidOne/network_autoconfig)
ROS_SETUP=/home/turtlebot/catkin_ws/devel/setup.bash
```
