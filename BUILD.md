# LGPL FFmpeg Docker Build

This repository contains Docker configurations for building an LGPL-compliant FFmpeg image suitable for Python bindings.

## Structure

```
.
├── ffmpeg/
│   └── Dockerfile          # Main two-stage Dockerfile for LGPL FFmpeg build
└── python.tests/
    ├── Dockerfile          # Test Dockerfile with PyAV
    ├── test_pyav.py        # Python script to test PyAV binding
    └── test.ps1            # PowerShell script to build and test
```

## Building the Image

### Using the PowerShell Script (Recommended)

The easiest way to build and test the image is using the provided PowerShell script:

```powershell
./test.ps1
```

This script will:
1. Build the main LGPL FFmpeg image
2. Test the FFmpeg installation
3. Verify LGPL configuration
4. Build a test image with PyAV
5. Run PyAV binding tests

### Manual Build

If you prefer to build manually:

```bash
# Build the main FFmpeg image
docker build -t python-ffmpeg-lgpl:latest ./ffmpeg

# Build the test image
docker build -t python-ffmpeg-lgpl-test:latest ./python.tests

# Run PyAV tests (this also verifies FFmpeg works correctly)
docker run --rm python-ffmpeg-lgpl-test:latest
```

## LGPL Configuration

The FFmpeg build uses the following configuration to ensure LGPL compliance:

- `--enable-version3`: Enable LGPLv3 licenses (GPLv3 is disabled by --disable-gpl)
- `--disable-gpl`: Disable GPL components
- `--disable-nonfree`: Disable non-free components

### Included Codecs (LGPL-compatible)

The build includes the following LGPL-compatible codecs:

- **libvpx**: VP8/VP9 video codec (BSD license)
- **libmp3lame**: MP3 audio encoder (LGPL license)
- **libopus**: Opus audio codec (BSD license)
- **libvorbis**: Vorbis audio codec (BSD license)
- **libass**: Subtitle renderer (ISC license)
- **libtheora**: Theora video codec (BSD license)

### Excluded Codecs (GPL or non-free)

The following popular codecs are **NOT** included due to licensing constraints:

- **libx264**: H.264 video encoder (GPL license)
- **libx265**: H.265/HEVC video encoder (GPL license)
- **libfdk-aac**: AAC audio codec (requires --enable-nonfree)

If you need these codecs, you must comply with GPL licensing terms and rebuild with `--enable-gpl` and/or `--enable-nonfree`.

## Two-Stage Build

The Dockerfile uses a two-stage build process:

1. **Stage 1 (builder)**: 
   - Uses debian:bookworm-slim as base image
   - Installs build dependencies
   - Downloads FFmpeg source from ffmpeg.org
   - Configures and builds FFmpeg with LGPL settings
   - Preserves artifacts in `/usr/local/ffmpeg`

2. **Stage 2 (final)**:
   - Uses scratch base image for minimal size
   - Copies only FFmpeg artifacts from the builder stage
   - Results in a very small final image containing only FFmpeg binaries and libraries

## Testing with PyAV

The test Dockerfile uses python:3.14-slim-bookworm as a base image and copies FFmpeg from the main image. It installs PyAV to verify that Python can successfully bind to the FFmpeg libraries. The test script (`test_pyav.py`) verifies:

- PyAV can be imported
- PyAV can detect FFmpeg version
- PyAV can access FFmpeg codecs
- PyAV can access FFmpeg formats

## Usage

The main image (python-ffmpeg-lgpl:latest) contains only FFmpeg binaries and libraries in a minimal scratch-based container. To use FFmpeg in your Python applications, you need to copy the FFmpeg files into a proper runtime environment:

```dockerfile
FROM python:3.14-slim-bookworm

# Copy FFmpeg installation
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

# Install your Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy your application
COPY . /app

# Run your application
CMD ["python", "your_app.py"]
```

## Requirements

- Docker
- PowerShell (for the test script)

## License

This Docker configuration builds FFmpeg with LGPL compliance. Please ensure you understand and comply with the LGPL license terms when using this image.
