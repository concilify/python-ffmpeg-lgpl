#!/usr/bin/env pwsh
# PowerShell script to build and test the LGPL FFmpeg Docker image

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Building LGPL FFmpeg Docker Image" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Build the main FFmpeg image
Write-Host "`nBuilding python-ffmpeg-lgpl image..." -ForegroundColor Yellow
docker build -t python-ffmpeg-lgpl:latest ./app

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build python-ffmpeg-lgpl image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully built python-ffmpeg-lgpl image" -ForegroundColor Green

# Test the FFmpeg installation
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Testing FFmpeg Installation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nTesting FFmpeg version..." -ForegroundColor Yellow
docker run --rm python-ffmpeg-lgpl:latest ffmpeg -version

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to run ffmpeg" -ForegroundColor Red
    exit 1
}

Write-Host "`n✓ FFmpeg is working correctly" -ForegroundColor Green

# Verify LGPL configuration
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Verifying LGPL Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nChecking build configuration..." -ForegroundColor Yellow
$buildConfig = docker run --rm python-ffmpeg-lgpl:latest ffmpeg -version

if ($buildConfig -match "--enable-gpl") {
    Write-Host "✗ WARNING: GPL is enabled in the build!" -ForegroundColor Red
    Write-Host "This build may not be LGPL compliant." -ForegroundColor Red
} else {
    Write-Host "✓ GPL is disabled - LGPL compliant" -ForegroundColor Green
}

if ($buildConfig -match "--enable-version3") {
    Write-Host "✓ Version 3 licenses enabled" -ForegroundColor Green
} else {
    Write-Host "! Version 3 licenses not enabled" -ForegroundColor Yellow
}

# Build the test image
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Building Test Image with PyAV" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nBuilding test image..." -ForegroundColor Yellow
docker build -t python-ffmpeg-lgpl-test:latest ./container.tests

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build test image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully built test image" -ForegroundColor Green

# Run the PyAV test
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Testing PyAV Binding" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nRunning PyAV test..." -ForegroundColor Yellow
docker run --rm python-ffmpeg-lgpl-test:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✗ PyAV test failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "All Tests Passed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nThe LGPL-compliant FFmpeg image is ready to use." -ForegroundColor Green
Write-Host "Image name: python-ffmpeg-lgpl:latest" -ForegroundColor Cyan
