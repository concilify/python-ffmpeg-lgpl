# LGPL FFmpeg Docker Build

This repository contains Docker configurations for building an LGPL-compliant FFmpeg image suitable for Python bindings.

## Structure

```
.
├── app/
│   └── Dockerfile          # Main two-stage Dockerfile for LGPL FFmpeg build
└── container.tests/
    ├── Dockerfile          # Test Dockerfile with PyAV
    ├── test_pyav.py        # Python script to test PyAV binding
    └── test.ps1            # PowerShell script to build and test
```

## Building the Image

### Using the PowerShell Script (Recommended)

The easiest way to build and test the image is using the provided PowerShell script:

```powershell
cd container.tests
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
docker build -t python-ffmpeg-lgpl:latest ./app

# Test FFmpeg
docker run --rm python-ffmpeg-lgpl:latest ffmpeg -version

# Build the test image
docker build -t python-ffmpeg-lgpl-test:latest ./container.tests

# Run PyAV tests
docker run --rm python-ffmpeg-lgpl-test:latest
```

## LGPL Configuration

The FFmpeg build uses the following configuration to ensure LGPL compliance:

- `--enable-version3`: Enable LGPLv3 and GPLv3
- `--disable-gpl`: Disable GPL components
- `--disable-nonfree`: Disable non-free components

This ensures that only LGPL-compatible codecs and features are included in the build.

## Two-Stage Build

The Dockerfile uses a two-stage build process:

1. **Stage 1 (builder)**: 
   - Installs build dependencies
   - Clones FFmpeg source from GitHub
   - Configures and builds FFmpeg with LGPL settings
   - Preserves artifacts in `/usr/local/ffmpeg`

2. **Stage 2 (final)**:
   - Uses the same Python base image
   - Installs only runtime dependencies
   - Copies FFmpeg artifacts from the builder stage
   - Results in a smaller final image

## Testing with PyAV

The test Dockerfile extends the main image and installs PyAV to verify that Python can successfully bind to the FFmpeg libraries. The test script (`test_pyav.py`) verifies:

- PyAV can be imported
- PyAV can detect FFmpeg version
- PyAV can access FFmpeg codecs
- PyAV can access FFmpeg formats

## Usage

Once built, you can use the image as a base for your own Python applications that need FFmpeg:

```dockerfile
FROM python-ffmpeg-lgpl:latest

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
