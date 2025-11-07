FROM ubuntu:22.04 AS base

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive

FROM base AS cpu_build

# Install build deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libnuma-dev libnetcdf-dev cmake build-essential ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build LISFLOOD
COPY . /opt/src/lisflood
RUN cmake -S /opt/src/lisflood \
           -B /opt/build/lisflood \
           -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /opt/build/lisflood --parallel && \
    cp /opt/build/lisflood/lisflood /usr/local/bin/ && \
    rm -rf /opt/src/lisflood /opt/build/lisflood

# Set workdir
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]

FROM base AS gpu_build

# Install build deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget build-essential cmake libnuma-dev libnetcdf-dev gnupg ca-certificates

# Add CUDA 11.8 repository
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin \
    && mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
    && wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb \
    && dpkg -i cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb \
    && cp /var/cuda-repo-ubuntu2204-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
    && apt-get update \
    && apt-get install -y cuda-toolkit-11-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add nvcc to PATH
ENV PATH=/usr/local/cuda-11.8/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH

# Update nvcc gcc linkage
ENV CC=/usr/bin/gcc-11
ENV CXX=/usr/bin/g++-11

# Build LISFLOOD
COPY . /opt/src/lisflood

RUN cmake -S /opt/src/lisflood \
           -B /opt/build/lisflood \
           -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /opt/build/lisflood --parallel && \
    cp /opt/build/lisflood/lisflood /usr/local/bin/ && \
    rm -rf /opt/src/lisflood /opt/build/lisflood


# Set workdir
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
