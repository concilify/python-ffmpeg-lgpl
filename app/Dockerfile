# Stage 1: Build FFmpeg from source with LGPL configuration
FROM python:3.11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    yasm \
    nasm \
    libx264-dev \
    libx265-dev \
    libvpx-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev \
    libvorbis-dev \
    libass-dev \
    libfreetype6-dev \
    libtheora-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Clone FFmpeg source from GitHub
RUN git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg

# Build FFmpeg with LGPL configuration
WORKDIR /build/ffmpeg
RUN ./configure \
    --enable-version3 \
    --disable-gpl \
    --disable-nonfree \
    --enable-shared \
    --enable-pic \
    --prefix=/usr/local/ffmpeg \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libfdk-aac \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libass \
    --enable-libfreetype \
    --enable-libtheora \
    && make -j$(nproc) \
    && make install

# Stage 2: Copy FFmpeg artifacts to Python base image
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libx264-164 \
    libx265-199 \
    libvpx7 \
    libfdk-aac2 \
    libmp3lame0 \
    libopus0 \
    libvorbis0a \
    libvorbisenc2 \
    libass9 \
    libfreetype6 \
    libtheora0 \
    && rm -rf /var/lib/apt/lists/*

# Copy FFmpeg installation from builder stage
COPY --from=builder /usr/local/ffmpeg /usr/local/ffmpeg

# Add FFmpeg to PATH and library path
ENV PATH="/usr/local/ffmpeg/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="/usr/local/ffmpeg/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Verify FFmpeg installation
RUN ffmpeg -version && ffprobe -version

# Set working directory
WORKDIR /app

CMD ["/bin/bash"]
