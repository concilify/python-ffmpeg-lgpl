FROM debian:bookworm-slim AS builder

# Add FFmpeg to PATH
ENV PATH="/usr/local/ffmpeg/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:/usr/local/lib"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libvpx7 \
    libmp3lame0 \
    libopus0 \
    libvorbis0a \
    libvorbisenc2 \
    libass9 \
    libtheora0 \
    && rm -rf /var/lib/apt/lists/*

# Copy FFmpeg installation from ffmpeg binaries image
COPY --from=ffmpeg-lgpl:latest /usr/local/ffmpeg /usr/local/ffmpeg

# Copy test scripts
COPY test_hls_demuxer.sh /usr/local/bin/test_hls_demuxer.sh
RUN chmod +x /usr/local/bin/test_hls_demuxer.sh

# Verify FFmpeg installation
RUN ffmpeg -version --buildconf && ffprobe -version
