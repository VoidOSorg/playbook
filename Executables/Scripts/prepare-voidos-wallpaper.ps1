# ==============================
# VoidOS Wallpaper Preparation
# ==============================

$SourceImage = Join-Path $PSScriptRoot "Resources\Wallpapers\Dark\Desktop\wllppr0.png"
$TargetDir   = "C:\Windows\VoidOS\Wallpapers"
$TargetImage = Join-Path $TargetDir "wllppr0.png"

Write-Host "Preparing VoidOS wallpaper..."

# Create directories
if (-not (Test-Path "C:\Windows\VoidOS")) {
    New-Item -Path "C:\Windows\VoidOS" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $TargetDir)) {
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
}

# Copy wallpaper
if (-not (Test-Path $SourceImage)) {
    Write-Error "Wallpaper not found: $SourceImage"
    exit 1
}

Copy-Item -Path $SourceImage -Destination $TargetImage -Force

Write-Host "Wallpaper copied to $TargetImage"
