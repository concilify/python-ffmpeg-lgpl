# Test Dockerfile to verify PyAV can bind to the LGPL FFmpeg build
FROM python:3.14-slim-bookworm

# Add FFmpeg to PATH and library path
ENV PATH="/usr/local/ffmpeg/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/ffmpeg/lib/pkgconfig:/usr/local/lib/pkgconfig"

# Install runtime dependencies for FFmpeg and build dependencies for PyAV
RUN apt-get update && apt-get install -y \
    gcc \
    pkg-config \
    libvpx7 \
    libmp3lame0 \
    libopus0 \
    libvorbis0a \
    libvorbisenc2 \
    libass9 \
    libtheora0 \
    && rm -rf /var/lib/apt/lists/*

# Copy FFmpeg installation from ffmpeg binaries image
COPY --from=python-ffmpeg-lgpl:latest /usr/local/ffmpeg /usr/local/ffmpeg

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
