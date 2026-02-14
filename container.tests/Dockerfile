# Test Dockerfile to verify PyAV can bind to the LGPL FFmpeg build
FROM python:3.14-slim-bookworm

# Copy FFmpeg installation from ffmpeg stage
COPY --from=python-ffmpeg-lgpl:latest /usr/local/ffmpeg /usr/local/ffmpeg

# Add FFmpeg to PATH and library path
ENV PATH="/usr/local/ffmpeg/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/ffmpeg/lib/pkgconfig:/usr/local/lib/pkgconfig"

# Install runtime dependencies for FFmpeg
RUN apt-get update && apt-get install -y \
    libvpx7 \
    libmp3lame0 \
    libopus0 \
    libvorbis0a \
    libvorbisenc2 \
    libass9 \
    libtheora0 \
    && rm -rf /var/lib/apt/lists/*

# Install PyAV and its build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install PyAV
RUN pip install --no-binary av av

# Set working directory
WORKDIR /app

# Copy test script
COPY test_pyav.py /app/test_pyav.py

# Make test script executable
RUN chmod +x /app/test_pyav.py

# Run the test by default
CMD ["python3", "/app/test_pyav.py"]
