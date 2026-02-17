#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BuildDir = Join-Path $ProjectRoot "build_x64"

# Compute version from git
$OBSVersion = (git -C $ProjectRoot describe --tags --always) -replace '-moqbs.*', ''
$CommitHash = git -C $ProjectRoot rev-parse --short=7 HEAD
$Version = "$OBSVersion-$CommitHash"
Write-Host "Version: $Version"

# Configure CMake
Write-Host ""
Write-Host "Configuring CMake..."
Push-Location $ProjectRoot
try {
    cmake -S . --preset windows-x64
} finally {
    Pop-Location
}

# Build
Write-Host ""
Write-Host "Building..."
cmake --build $BuildDir --config Release -j

# Package
Write-Host ""
Write-Host "Packaging..."
Push-Location $BuildDir
try {
    cpack -C Release
} finally {
    Pop-Location
}

# Find the generated ZIP
$ZipFile = Get-ChildItem -Path $BuildDir -Filter "obs-studio-*-windows-x64.zip" | Select-Object -First 1
if (-not $ZipFile) {
    Write-Error "Could not find obs-studio-*-windows-x64.zip in $BuildDir"
    exit 1
}

# Copy to consistent name
$OutputName = "moqbs-windows-x64.zip"
$OutputPath = Join-Path $BuildDir $OutputName
Copy-Item $ZipFile.FullName $OutputPath -Force
Write-Host "Created: $OutputPath"

# Upload to R2
$R2Bucket = $env:R2_BUCKET
if ($R2Bucket) {
    Write-Host ""
    Write-Host "Uploading to R2..."
    bunx wrangler r2 object put "$R2Bucket/windows/x64/$Version/$OutputName" `
        --remote --file $OutputPath
    Write-Host "Uploaded: https://obs.moq.dev/windows/x64/$Version/$OutputName"
}

# Success
Write-Host ""
Write-Host "Build complete!"
Write-Host ""
Write-Host "ZIP created: $OutputPath"
