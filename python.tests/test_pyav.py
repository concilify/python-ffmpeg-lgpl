#!/usr/bin/env python3
"""
Test script to verify PyAV can bind to FFmpeg and open a stream.
"""

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

# Test HTTPS stream opening
print("\nTesting HTTPS stream support...")
try:
    test_url = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    print(f"Attempting to open: {test_url}")
    
    container = av.open(test_url, timeout=10.0)
    try:
        print(f"✓ Successfully opened HTTPS stream")
        print(f"✓ Stream duration: {container.duration / 1000000:.2f} seconds" if container.duration else "✓ Stream opened (duration unknown)")
        print(f"✓ Number of streams: {len(container.streams)}")
        
        # List stream information
        for stream in container.streams:
            stream_type = stream.type
            if hasattr(stream, 'codec_context'):
                codec = stream.codec_context.name if stream.codec_context else 'unknown'
                print(f"  - {stream_type} stream: {codec}")
        
        print("✓ HTTPS/SSL support is working correctly")
    finally:
        container.close()
    
except Exception as e:
    print(f"✗ Failed to open HTTPS stream: {e}")
    print("  This indicates that OpenSSL support is not properly enabled in FFmpeg")
    sys.exit(1)

print("\n" + "="*50)
print("All tests passed! PyAV is successfully bound to FFmpeg.")
print("="*50)
