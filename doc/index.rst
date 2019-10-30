Systemd based Robot Intialization
=================================

This package installs systemd units for managing startup and shutdown of
``roscore`` and ``roslaunch``.

The initial release provides 'user-mode' units that are installed into
``/usr/lib/systemd/user`` for system-wide access and are available for use by
any normal user of the system.

.. toctree::
    :hidden:
    :maxdepth: 2

    CHANGELOG

Installation
------------

.. code-block:: bash

    apt get install ros-kinetic-robot-systemd

Usage
-----

The systemd roslaunch template unit allows a user to enable automatically
start ``roscore`` and run ``roslaunch turtlebot_bringup minimal.launch``
upon graphical login.

.. code-block:: bash

    systemctl --user enable roslaunch@turtlebot_bringup:minimal.launch

Systemd requires that ``enable-linger`` be set to start this user service
during boot-up instead of upon graphical login.

.. code-block:: bash

    sudo loginctl enable-linger $USER

Startup

.. code-block:: bash

    systemctl --user start roslaunch@turtlebot_bringup:minimal.launch

Shutdown

.. code-block:: bash

    systemctl --user stop roslaunch@turtlebot_bringup:minimal.launch

Disable

.. code-block:: bash

    systemctl --user disable roslaunch@turtlebot_bringup:minimal.launch

Environment Variables
---------------------

While every effort has been taken to choose rational defaults, it is often
useful to set environment variables to configure startup. Given design choices
made by the Systemd developers, the service unit configuration file can only
load environment variables in a simplified format containing only ``KEY=value``
formatted lines without complex ``bash`` variable substitutions.

The ``roslaunch@.service`` unit loads these variables from
``/etc/ros/environment`` followed by ``$HOME/.ros/environment``.

For example, to enable roslaunch-ing from an overlay can be set with the full
path to the workspace ``setup.bash``.

.. code-block:: bash

    ROS_SETUP=/home/username/catkin_ws/install/setup.bash

This approach also allows selection the ROS distribution and port by editing
``$HOME/.ros/environment`` and restarting ``roscore``.

.. code-block:: bash

    ROS_DISTRO=melodic
    ROS_PORT=11311

If `ros-kinetic-network-autoconfig <https://wiki.ros.org/network_autoconfig>`_
is installed, it can be enabled by adding.

.. code-block:: bash

    ROS_INTERFACE=auto

For ease of use in most use cases, an `environment hook
<http://docs.ros.org/kinetic/api/catkin/html/user_guide/environment.html>`_
is installed to ``/opt/ros/kinetic/etc/catkin/profile.d/05.environment.sh`` to
enable loading these variables when ``~/.bashrc`` is sourced, as long as the
``ROS_DISTRO`` variable does not conflict with the version set by the line
``source /opt/ros/kinetic/setup.bash``. In cases where developers need to
switch ROS distributions on a regular basis, we suggest changing ``~/.bashrc``

.. code-block:: bash

    sources="/etc/ros/environment
             $HOME/.ros/environment
             /opt/ros/$ROS_DISTRO/setup.sh
    "

    for file in $sources; do
        [ -f $file ] || continue
        . $file
    done

All of this is unfortunately necessary as Systemd can not load ``~/.bashrc``

Notes
-----

Debugging
`````````

Systemd provides some debugging tools, some examples below are provided for your convenience.

.. code-block:: bash

    turtlebot@turtlebot:~$ systemctl --user list-units | grep ros
    roscore.service                                                                          loaded active running ROS Master
    roslaunch@turtlebot_bringup:3dsensor.launch.service                                      loaded active running ROS Launch
    roslaunch@turtlebot_bringup:minimal.launch.service                                       loaded active running ROS Launch
    roslaunch.slice                                                                          loaded active active  roslaunch.slice

.. code-block:: bash

    turtlebot@turtlebot:~$ journalctl -t ros_turtlebot_bringup:minimal.launch | tail
    Oct 30 02:03:58 turtlebot ros_turtlebot_bringup:minimal.launch[1253]: [ERROR] [1572415438.898946021]: Kobuki : malformed sub-payload detected. [220][170][DC AA 55 53 01 0F 10 B2 ]



``roscore``
```````````

There are a few cases where the operation of ``roscore`` can cause some
confusion. This can be avoided by starting ``roscore`` before ``roslaunch``.

.. code-block:: bash

    systemctl --user start roslaunch@turtlebot_bringup:minimal.launch

This command will start the ``roscore.service`` and it uses ``netcat-openbsd``
if installed to wait until the ``$ROS_PORT`` is reachable on ``localhost``.
It then forks and execs ``roslaunch turtlebot_bringup minimal.launch`` which
runs until it is stopped.

.. code-block:: bash

    systemctl --user stop roslaunch@turtlebot_bringup:minimal.launch

However the above does not stop ``roscore`` to prevent abandoning other
nodes that may have been launched by other ``roslaunch`` invocations.
``roscore`` and all of the associated ``roslaunch`` instances can be stopped
with

.. code-block:: bash

    systemctl --user stop roscore

For embedded cases where a single ``roslaunch`` invocation is expected,
``roscore`` can be started with the simplified ``roscorelaunch@.service``
unit that does not depend on ``netcat``.

.. code-block:: bash

    systemctl --user enable roscorelaunch@turtlebot_bringup:minimal.launch

Mixed ownership
```````````````
If ``roscore`` is launched by user ``ros`` it is possible for a user
``turtlebot`` to successfully run ``rostopic list``. However, nodelets will
have issues.

The `PR2 <https://suturo-docs.readthedocs.io/en/latest/components/pr2.html>`_
had a model for operation that allowed users to 'claim' the robot and 'release'
it when they are done. Something like this should probably be implemented as a
separate package.

Permissions
```````````
Independent of this package users must be added to group ``dialout`` for access
to devices that look like serial ports.

OEMs can use `preseed <https://wiki.debian.org/DebianInstaller/Preseed>`_ or
DevOps tooling to ensure the user is in the correct group.

Unreliable networks
```````````````````
ROS will not shutdown if network connectivity is lost. This can be an issue if
the IP address allocation changes.  It may be useful to interface a network
watchdog into the robot state machinery.

Non-Endorsement / Rant
``````````````````````
While Systemd is the default for platforms targeted by the Kinetic and Melodic
releases, and can be useful for some applications, we do not endorse the use of
Systemd.

We believe it has fundamental design assumptions that all systems are causal and
`linear time-invariant <https://en.wikipedia.org/wiki/Linear_time-invariant_system>`_.
While this holds true for many modern stateless REST-ful computing applications
it does not hold true for many robotic sub-systems which may need to be fully
operational before any connections are made. These assumptions most likely led
to the internalization of NTP services into systemd. This is also the same
problem encountered hot-starting GPS devices and initializing hardware setup and
calibration processes.

Further we believe the design choices in Systemd are intentionally being made
to ensure vendor lock, while at the same time failing to plan ahead for
real-time and concurrent service management issues that the robotics industry
is already running into. While systemd now supports basic network status
detection, it still lacks a robust means of shutting down services in the event
of a VPN connection failure that more granular network state machinery might
support.

Finally the domain specific language for constructing units is often opaque
and inflexible without the benefit of a significant reduction in complexity.

While many of these problems may be intractable, `security
<https://unix.stackexchange.com/questions/396361/how-does-the-sd-pam-process-get-away-with-unprivileged-pam-session-close>`_
, lol.

THANKS!
-------

A special shout-out to everyone else who work on this problem space and came up
with different solutions!

| https://github.com/laas/ros_comm_upstart
| https://github.com/TurtleBot-Mfg/ros-system-daemon-hydro
| https://github.com/ros/meta-ros/issues/224
| https://github.com/ros/meta-ros/blob/master/recipes-ros/ros-comm/roslaunch/roscore.service
| https://blog.roverrobotics.com/how-to-run-ros-on-startup-bootup/
| https://github.com/clearpathrobotics/robot_upstart

Also, a pre-emptive thank you to everyone who submits issues and pull requests.
