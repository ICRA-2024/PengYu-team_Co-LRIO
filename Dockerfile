# Use an official ROS2 Foxy base image
FROM osrf/ros:foxy-desktop

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    git \
    libpcl-dev \
    libeigen3-dev \
    wget \
    build-essential \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

# Install GTSAM
RUN apt-get update && apt-get install -y \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/borglab/gtsam.git /tmp/gtsam \
    && cd /tmp/gtsam \
    && git checkout 4.2a8 \
    && mkdir build && cd build \
    && cmake .. -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/gtsam

# Create workspace and clone Co-LRIO
RUN mkdir -p /root/cslam_ws/src \
    && cd /root/cslam_ws/src \
    && git clone https://github.com/ICRA-2024/PengYu-team_Co-LRIO

# Build Co-LRIO
WORKDIR /root/cslam_ws
RUN /bin/bash -c "source /opt/ros/foxy/setup.bash && colcon build --symlink-install"

# Set up the ROS 2 environment
RUN echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc
RUN echo "source /root/cslam_ws/install/setup.bash" >> ~/.bashrc

# Set entrypoint for interactive use
ENTRYPOINT ["/bin/bash"]

