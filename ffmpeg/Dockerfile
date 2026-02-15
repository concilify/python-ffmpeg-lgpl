# Stage 1: Build FFmpeg from source with LGPL configuration
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    build-essential \
    pkg-config \
    yasm \
    nasm \
    libvpx-dev \
    libmp3lame-dev \
    libopus-dev \
    libvorbis-dev \
    libass-dev \
    libtheora-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

ARG FFMPEG_VERSION=7.1.3

# Download and extract FFmpeg source
RUN curl -fsSL https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz \
    -o ffmpeg.tar.xz \
    && tar -xJf ffmpeg.tar.xz \
    && rm ffmpeg.tar.xz

WORKDIR /build/ffmpeg-${FFMPEG_VERSION}

# Configure FFmpeg as LGPL only
RUN ./configure \
    --enable-version3 \
    --disable-gpl \
    --disable-nonfree \
    --enable-shared \
    --enable-pic \
    --prefix=/usr/local/ffmpeg \
    --enable-libvpx \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libass \
    --enable-libtheora \
    --extra-version="lgpl"

# Build FFmpeg with LGPL configuration
RUN make -j$(nproc)
RUN make install

# Stage 2: Create minimal image with only FFmpeg binaries
FROM scratch

# Copy FFmpeg installation from builder stage
COPY --from=builder /usr/local/ffmpeg /usr/local/ffmpeg
