FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    ROS_DISTRO=noetic

# Set bash as the default shell
SHELL ["/bin/bash", "-lc"]

# Basic tools + CA certificates, etc.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        tzdata \
        ca-certificates \
        gnupg2 \
        lsb-release \
        curl \
        wget \
        dirmngr \
        build-essential \
        git \
        sudo && \
    locale-gen ja_JP.UTF-8 && \
    update-locale LANG=ja_JP.UTF-8 && \
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Add ROS1 repository (without arch filter)
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
      | gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
      > /etc/apt/sources.list.d/ros1-latest.list

# Install ROS Noetic and related build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-desktop-full \
        python3-rosdep \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-wstool \
        python3-catkin-tools \
        python3-vcstool && \
    rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && \
    rosdep update --include-eol-distros

# Create jsk_aerial_robot workspace & fetch sources
RUN mkdir -p /root/ros/jsk_aerial_robot_ws/src && \
    source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd /root/ros/jsk_aerial_robot_ws && \
    wstool init src && \
    # Automatically answer "yes" to the interactive prompt of wstool set
    yes | wstool set -u -t src jsk_aerial_robot https://github.com/sugihara-16/aerial_robot --git && \
    wstool update -t src && \
    cd src/jsk_aerial_robot && \
    git checkout -b develop/Ninja_mnp origin/develop/Ninja_mnp && \
    cd /root/ros/jsk_aerial_robot_ws && \
    ./src/jsk_aerial_robot/configure.sh && \
    wstool merge -t src src/jsk_aerial_robot/aerial_robot_${ROS_DISTRO}.rosinstall && \
    wstool update -t src

# Install dependencies & build (continue even if build fails)
RUN apt-get update && \
    source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd /root/ros/jsk_aerial_robot_ws && \
    # Some apt packages may not exist depending on the environment, so do not stop Docker build on failure
    rosdep install -y -r --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} || true && \
    catkin config --extend /opt/ros/${ROS_DISTRO} && \
    # This may also fail if dependencies are missing, so append || true
    catkin build -j1 || true

# Configure the shell to start with ROS environment by default
ENV ROS_WORKSPACE=/root/ros/jsk_aerial_robot_ws

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
    echo "source ${ROS_WORKSPACE}/devel/setup.bash" >> /root/.bashrc

WORKDIR /root/ros/jsk_aerial_robot_ws

CMD ["bash"]