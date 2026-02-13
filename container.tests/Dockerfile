# Test Dockerfile to verify PyAV can bind to the LGPL FFmpeg build
FROM python-ffmpeg-lgpl:latest

# Install PyAV and its build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PyAV
RUN pip install --no-cache-dir av

# Copy test script
COPY test_pyav.py /app/test_pyav.py

# Make test script executable
RUN chmod +x /app/test_pyav.py

# Run the test by default
CMD ["python3", "/app/test_pyav.py"]
