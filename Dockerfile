FROM ubuntu:22.04 AS cpu_builder

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive

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
    cmake --build /opt/build/lisflood

FROM ubuntu:22.04 AS cpu_build

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libnuma1 libnetcdf19 libgomp1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=cpu_builder /opt/build/lisflood/lisflood /usr/local/bin/

# Set workdir
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]

FROM nvidia/cuda:11.8.0-base-ubuntu22.04 AS gpu_builder

# Install build deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget build-essential cmake libnuma-dev libnetcdf-dev gnupg ca-certificates

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
    cmake --build /opt/build/lisflood

FROM nvidia/cuda:11.8.0-base-ubuntu22.04 AS gpu_build

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libnuma1 libnetcdf19 libgomp1 ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=gpu_builder /opt/build/lisflood/lisflood /usr/local/bin/

# Set workdir
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
