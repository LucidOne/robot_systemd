# Systemd Robot Initialization
[![Build Status](https://www.travis-ci.org/LucidOne/robot_systemd.svg?branch=master)](https://www.travis-ci.org/LucidOne/robot_systemd)
[![Build Status](http://build.ros.org/buildStatus/icon?subject=Kinetic&job=Kbin_uX64__robot_systemd__ubuntu_xenial_amd64__binary)](http://build.ros.org/view/Kbin_uX64/job/Kbin_uX64__robot_systemd__ubuntu_xenial_amd64__binary/)

[Systemd based Robot Initialization](https://github.com/LucidOne/robot_systemd)
for ROS.

## TL;DR
```bash
# Install ROS...
sudo apt install ros-kinetic-robot-systemd
systemctl --user start roslaunch@turtlebot_bringup:minimal.launch
```

This package should provide a way to start `roscore` and a set of launch files
that *works by default*. OEMs and system integrators should also be able to
depend on it to build their own ROS packages that can customize the system
startup to support inevitable hardware variations. Individual end-users should
be able to make personal customizations without being overwritten by vendor
upgrades.
