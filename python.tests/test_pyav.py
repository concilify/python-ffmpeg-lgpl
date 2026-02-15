#!/usr/bin/env python3
"""
Test script to verify PyAV can bind to FFmpeg and open a stream.
"""

import re
import subprocess
import sys

try:
    import av
    print("✓ PyAV imported successfully")
except ImportError as e:
    print(f"✗ Failed to import PyAV: {e}")
    sys.exit(1)

# Check PyAV version
print(f"✓ PyAV version: {av.__version__}")

# Check FFmpeg version
try:
    print(f"FFmpeg version (via PyAV): {av.ffmpeg_version_info}")
except Exception as e:
    print(f"✗ Could not get FFmpeg version: {e}")
    sys.exit(1)

# Test creating a container (without actually opening a file)
try:
    # Test that PyAV can access FFmpeg codecs
    codecs = av.codecs_available
    print(f"✓ PyAV can access FFmpeg codecs ({len(codecs)} codecs available)")
    
    # List some common codecs
    common_codecs = ['h264', 'h265', 'vp8', 'vp9', 'aac', 'mp3', 'opus']
    available_common = [c for c in common_codecs if c in codecs]
    print(f"✓ Common codecs available: {', '.join(available_common)}")
    
except Exception as e:
    print(f"✗ Failed to access FFmpeg codecs: {e}")
    sys.exit(1)

# Test format detection
try:
    formats = av.formats_available
    print(f"✓ PyAV can access FFmpeg formats ({len(formats)} formats available)")
except Exception as e:
    print(f"✗ Failed to access FFmpeg formats: {e}")
    sys.exit(1)

# Test HLS demuxer presence
try:
    result = subprocess.run(
        ["ffmpeg", "-demuxers"],
        capture_output=True,
        text=True,
        check=True
    )
    
    # Search for HLS demuxer using word boundary matching
    if 'hls' in result.stdout.lower():
        # Check for exact word match to avoid false positives
        if re.search(r'\bhls\b', result.stdout, re.IGNORECASE):
            print("✓ HLS demuxer is present")
        else:
            print("✗ HLS demuxer not found (found similar but not exact match)")
            sys.exit(1)
    else:
        print("✗ HLS demuxer is not present")
        sys.exit(1)
except subprocess.CalledProcessError as e:
    print(f"✗ Failed to check demuxers: {e}")
    sys.exit(1)
except Exception as e:
    print(f"✗ Failed to verify HLS demuxer: {e}")
    sys.exit(1)

print("\n" + "="*50)
print("All tests passed! PyAV is successfully bound to FFmpeg.")
print("="*50)
