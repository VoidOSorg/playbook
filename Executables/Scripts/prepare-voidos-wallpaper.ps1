$PlaybookRoot = Resolve-Path "$PSScriptRoot\..\.."
$SourceImage = Join-Path $PlaybookRoot "Resources\Wallpapers\uDp0FFJ.png"
$TargetDir   = "C:\Windows\VoidOS\Wallpapers"
$TargetImage = Join-Path $TargetDir "uDp0FFJ.png"
$ImageUrl    = "https://i.imgur.com/uDp0FFJ.png"

Write-Host "Preparing VoidOS wallpaper..."

if (-not (Test-Path "C:\Windows\VoidOS")) {
    New-Item -Path "C:\Windows\VoidOS" -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $TargetDir)) {
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
}

# Try to download the wallpaper from the default image host
$downloaded = $false
try {
    Write-Host "Downloading wallpaper from $ImageUrl ..."
    $tmpWall = Join-Path $env:TEMP "uDp0FFJ_download.png"
    Invoke-WebRequest -Uri $ImageUrl -OutFile $tmpWall -TimeoutSec 30 -UseBasicParsing
    if (Test-Path $tmpWall) {
        Copy-Item -Path $tmpWall -Destination $TargetImage -Force
        Remove-Item $tmpWall -Force -ErrorAction SilentlyContinue
        $downloaded = $true
        Write-Host "Wallpaper downloaded from host." -ForegroundColor Green
    }
}
catch {
    Write-Host "Download failed, using bundled wallpaper." -ForegroundColor Yellow
}

# Fallback to the bundled wallpaper
if (-not $downloaded) {
    if (-not (Test-Path $SourceImage)) {
        Write-Error "Wallpaper not found: $SourceImage"
        exit 1
    }
    Copy-Item -Path $SourceImage -Destination $TargetImage -Force
    Write-Host "Wallpaper copied from bundle."
}

Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

$result = [Wallpaper]::SystemParametersInfo(0x0014, 0, $TargetImage, 0x01 -bor 0x02)

if ($result) {
    Write-Host "Desktop wallpaper set successfully" -ForegroundColor Green
} else {
    Write-Host "Could not set wallpaper (will be applied at user logon)" -ForegroundColor Yellow
}

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" Wallpaper $TargetImage -Type String -Force
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" WallpaperStyle "10" -Type String -Force