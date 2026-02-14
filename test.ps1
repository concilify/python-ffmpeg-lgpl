#!/usr/bin/env pwsh
# PowerShell script to build and test the LGPL FFmpeg Docker image

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Building LGPL FFmpeg Docker Image" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Build the main FFmpeg image
Write-Host "`nBuilding python-ffmpeg-lgpl image..." -ForegroundColor Yellow
docker build -t python-ffmpeg-lgpl:latest ./ffmpeg

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to build python-ffmpeg-lgpl image" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully built python-ffmpeg-lgpl image" -ForegroundColor Green

Write-Host "`nNote: The python-ffmpeg-lgpl image uses a scratch base and contains only FFmpeg binaries." -ForegroundColor Cyan
Write-Host "FFmpeg will be tested in the python.tests image with a proper runtime environment." -ForegroundColor Cyan

# Build the test image
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Building Test Image with PyAV" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nBuilding test image..." -ForegroundColor Yellow
docker build -t python-ffmpeg-lgpl-test:latest ./python.tests

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
