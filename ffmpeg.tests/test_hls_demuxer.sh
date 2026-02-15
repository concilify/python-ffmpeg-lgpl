#!/bin/sh
# Test script to verify HLS demuxer is present in FFmpeg

set -e

echo "Testing HLS demuxer presence..."

# Run ffmpeg -demuxers and search for HLS demuxer
# The pattern matches lines starting with D (demuxer indicator), followed by whitespace,
# then 'hls' as a complete word (not part of hlsv2, etc.)
if ffmpeg -demuxers 2>&1 | grep -E '^[[:space:]]*D[[:space:]]+hls\b' > /dev/null; then
    echo "✓ HLS demuxer is present"
    exit 0
else
    echo "✗ HLS demuxer is not present"
    exit 1
fi
