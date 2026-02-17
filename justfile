#!/usr/bin/env just --justfile

# List available commands
default:
  @just --list

# Build for ARM (native on Apple Silicon)
build:
  op run --env-file=".env" -- bash ./bin/release-mac arm64 RelWithDebInfo false

# Build release version for ARM
release:
  op run --env-file=".env" -- bash ./bin/release-mac arm64 Release false

# Build for ARM with notarization (slow)
release-notarized:
  op run --env-file=".env" -- bash ./bin/release-mac arm64 Release true

# Cross-compile for Intel Macs (x86_64)
build-intel:
  op run --env-file=".env" -- bash ./bin/release-mac x86_64 RelWithDebInfo false

# Release for Intel Macs
release-intel:
  op run --env-file=".env" -- bash ./bin/release-mac x86_64 Release false

# Build for Windows x64 (run on Windows machine)
build-windows:
  pwsh -File ./bin/release-windows.ps1

# Release for Windows x64 with R2 upload (run on Windows machine)
release-windows:
  op run --env-file=".env" -- pwsh -File ./bin/release-windows.ps1

# Clean macOS build artifacts
clean:
  rm -rf build_macos

# Build for Linux x86_64 (via Docker)
build-linux:
  bash ./bin/release-linux

# Release for Linux x86_64 with R2 upload (via Docker)
release-linux:
  op run --env-file=".env" -- bash ./bin/release-linux

# Clean Windows build artifacts
clean-windows:
  pwsh -Command "if (Test-Path build_x64) { Remove-Item -Recurse -Force build_x64 }"

# Clean Linux build artifacts
clean-linux:
  rm -rf build_linux
