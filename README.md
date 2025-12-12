# LEGION's custom codes

<img width="1664" height="498" alt="Image" src="https://github.com/user-attachments/assets/c0bc7c2a-ee7b-4957-928d-50f9bb26a647" />

## contents
- README.md (this)
- dockerfile
    - This Dockerfile supports all processes required for installing all custom code and setting up the environment. Building and running the Docker image has been verified to work on an Ubuntu 20.04 LTS environment.
## usage
- Build
    - Place the included Dockerfile in an appropriate directory, then execute the following command in that directory:
        - `$ docker build -t legion_image:noetic .`
    - This Dockerfile is large, so depending on your environment, the build may fail due to temporary network errors or insufficient memory. If this happens, please try building it again several times.
- Run
    -  `$ docker run -it legion_image:noetic`
    -  If you need a GUI, please run Docker with the appropriate command for your OS and graphics card specifications.
-  Launch simulation demo
    1. Launch main node
        -  `$ roslaunch ninja two_module_test.launch headless:=false`
        -  Two LEGION modules will spawn in gazebo environment
    2. Launch keyboard teleopelation
        -  `$ rosrun ninja keyboard_command.py`
        -  arming & takeoff robots(for the usage of keyboard teleopelation, please refer [here](https://github.com/jsk-ros-pkg/jsk_aerial_robot/wiki/keyboard_operation).
    3.  Launch assembly motion planner
        -  `$ roslaunch ninja assembly_motion.launch module_ids:="2,1" real_machine:=false`
        -  After above command, press `x` key in keyboard teleopelation to start assembly motion.
    4.  Start morphing demo
        - `$ rosrun ninja two_mod_morhping_demo.py`
        - it changes yaw and pitch joint's positions from [0,0] to [1.0, 0.8] rad.
    5. Launch disassembly motion planner
        - `$ roslaunch ninja disassembly_motion.launch module_ids:="1,2" real_machine:=false`
