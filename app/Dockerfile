# Stage 1: Build FFmpeg from source with LGPL configuration
FROM python:3.11-slim-bookworm AS builder

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

# Set working directory
WORKDIR /build

# Download and extract FFmpeg source
ARG FFMPEG_VERSION=7.1

RUN curl -fsSL https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz \
    -o ffmpeg.tar.xz \
    && tar -xJf ffmpeg.tar.xz \
    && rm ffmpeg.tar.xz

# Build FFmpeg with LGPL configuration
WORKDIR /build/ffmpeg-${FFMPEG_VERSION}
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
    --enable-libtheora

RUN make -j$(nproc)
RUN make install

# # Stage 2: Copy FFmpeg artifacts to Python base image
# FROM python:3.11-slim-bookworm

# # Install runtime dependencies
# RUN apt-get update && apt-get install -y \
#     libvpx7 \
#     libmp3lame0 \
#     libopus0 \
#     libvorbis0a \
#     libvorbisenc2 \
#     libass9 \
#     libtheora0 \
#     && rm -rf /var/lib/apt/lists/*

# # Copy FFmpeg installation from builder stage
# COPY --from=builder /usr/local/ffmpeg /usr/local/ffmpeg

# # Add FFmpeg to PATH and library path
# ENV PATH="/usr/local/ffmpeg/bin:${PATH}"
# ENV LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:/usr/local/lib"
# ENV PKG_CONFIG_PATH="/usr/local/ffmpeg/lib/pkgconfig:/usr/local/lib/pkgconfig"

# # Verify FFmpeg installation
# RUN ffmpeg -version --buildconf && ffprobe -version

# # Set working directory
# WORKDIR /app
