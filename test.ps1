#!/usr/bin/env pwsh
# PowerShell script to build and test the LGPL FFmpeg Docker image
# NOTE: This script is for LOCAL USE ONLY. CI/CD workflows use separate jobs for building and testing.

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Building LGPL FFmpeg Docker Image" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Build the main FFmpeg image
Write-Host "`nBuilding ffmpeg-lgpl image..." -ForegroundColor Yellow
docker build -t ffmpeg-lgpl:latest ./ffmpeg

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build ffmpeg-lgpl image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully built ffmpeg-lgpl image" -ForegroundColor Green

# Test the FFmpeg binaries
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Testing FFmpeg Binaries" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nBuilding ffmpeg.tests image..." -ForegroundColor Yellow
docker build -t ffmpeg-tests:latest ./ffmpeg.tests

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build ffmpeg.tests image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully built test image" -ForegroundColor Green

Write-Host "`nTesting FFmpeg version..." -ForegroundColor Yellow
$version = docker run --rm ffmpeg-tests:latest ffmpeg -version

if ($version -match "ffmpeg version 7.1.3-lgpl") {
    Write-Host "✓ Version is correct" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR: Version is not correct in the build!" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ FFmpeg is working correctly" -ForegroundColor Green

# Verify LGPL configuration
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Verifying LGPL Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nTesting FFmpeg banner..." -ForegroundColor Yellow
$license = docker run --rm ffmpeg-tests:latest ffmpeg -hide_banner -L

if ($license -match "GNU Lesser General Public License") {
    Write-Host "✓ GNU Lesser General Public License is present" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR: GNU Lesser General Public License is not present!" -ForegroundColor Red
    exit 1
}

if ($license -match "GNU General Public License") {
    Write-Host "✗ ERROR: GNU General Public License is present!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ GNU General Public License is not present" -ForegroundColor Green
}

if ($license -match "nonfree") {
    Write-Host "✗ ERROR: nonfree is present!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ nonfree is not present" -ForegroundColor Green
}

Write-Host "`nChecking build configuration..." -ForegroundColor Yellow
$buildConfig = docker run --rm ffmpeg-tests:latest ffmpeg -version

if ($buildConfig -match "--enable-gpl") {
    Write-Host "✗ ERROR: GPL is enabled in the build!" -ForegroundColor Red
    Write-Host "This build is NOT LGPL compliant." -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ GPL is disabled - LGPL compliant" -ForegroundColor Green
}

if ($buildConfig -match "--enable-version3") {
    Write-Host "✓ Version 3 licenses enabled" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR:  Version 3 licenses not enabled" -ForegroundColor Yellow
    exit 1
}

# Verify HLS demuxer presence
Write-Host "`nChecking HLS demuxer..." -ForegroundColor Yellow
$demuxers = docker run --rm ffmpeg-tests:latest ffmpeg -demuxers

if ($demuxers -match '^\s*D\s+hls\b') {
    Write-Host "✓ HLS demuxer is present" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR: HLS demuxer is not present" -ForegroundColor Red
    exit 1
}

# Build the test image
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Building Python Test Image" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nBuilding python.tests image..." -ForegroundColor Yellow
docker build -t python-tests:latest ./python.tests

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build python.tests image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully built test image" -ForegroundColor Green

# Run the PyAV test
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Testing PyAV Binding" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nRunning PyAV test..." -ForegroundColor Yellow
docker run --rm python-tests:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✗ PyAV test failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "All Tests Passed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nThe LGPL-compliant FFmpeg image is ready to use." -ForegroundColor Green
Write-Host "Image name: ffmpeg-lgpl:latest" -ForegroundColor Cyan
