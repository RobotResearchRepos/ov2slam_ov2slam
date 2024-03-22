FROM osrf/ros:melodic-desktop-full

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y git \
 && rm -rf /var/lib/apt/lists/*

# apt packages

RUN apt-get update \
 && apt-get install -y libgoogle-glog-dev libgflags-dev \
 && rm -rf /var/lib/apt/lists/*

# Code repository

RUN mkdir -p /catkin_ws/src/

RUN git clone --recurse-submodules \
      https://github.com/RobotResearchRepos/ov2slam_ov2slam \
      /catkin_ws/src/ov2slam

# Install 3rd party

RUN cd /catkin_ws/src/ov2slam/Thirdparty/obindex2 \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && make -j4
 
RUN cd /catkin_ws/src/ov2slam/Thirdparty/ibow_lcd \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && make -j4

RUN cd /catkin_ws/src/ov2slam/Thirdparty/Sophus \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && make -j4 install

RUN cd /catkin_ws/src/ov2slam/Thirdparty/ceres-solver \
 && mkdir build && cd build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=14 -DCMAKE_CXX_FLAGS="-march=native" \
      -DBUILD_EXAMPLES=OFF \
 && make -j4 install

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
 && apt-get update \
 && rosdep install -r -y \
     --from-paths /catkin_ws/src \
     --ignore-src \
 && rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
 && cd /catkin_ws \
 && catkin_make
 
 
