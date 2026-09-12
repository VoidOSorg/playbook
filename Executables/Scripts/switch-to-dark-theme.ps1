# Switch to dark theme: VoidOS default wallpaper + dark apps mode (current user)

$SourceWall = Join-Path $PSScriptRoot "..\..\Resources\Wallpapers\uDp0FFJ.png"
$TargetDir  = "C:\Windows\VoidOS\Wallpapers"
$TargetWall = Join-Path $TargetDir "uDp0FFJ.png"

if (-not (Test-Path $TargetDir)) {
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
}

if (Test-Path $SourceWall) {
    Copy-Item -Path $SourceWall -Destination $TargetWall -Force
} else {
    Write-Host "[!] Dark wallpaper not found: $SourceWall"
}

if (Test-Path $TargetWall) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $TargetWall, 0x01 -bor 0x02) | Out-Null
    Write-Host "Dark wallpaper applied"
} else {
    Write-Host "[!] Cannot apply wallpaper"
}

$Personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (-not (Test-Path $Personalize)) { New-Item -Path $Personalize -Force | Out-Null }
Set-ItemProperty -Path $Personalize -Name AppsUseLightTheme -Value 0 -Type DWord -Force
Set-ItemProperty -Path $Personalize -Name SystemUsesLightTheme -Value 0 -Type DWord -Force
Write-Host "Dark mode enabled (current user)"