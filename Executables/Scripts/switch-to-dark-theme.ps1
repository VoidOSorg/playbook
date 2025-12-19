# Cambia al tema scuro (default)
$darkDesktop = "C:\VoidOS\Wallpapers\Dark\Desktop\wllppr0.png"
$darkLockscreen = "C:\VoidOS\Wallpapers\Dark\Lockscreen\wllppr1.png"

if (Test-Path $darkDesktop) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $darkDesktop, 0x01 -bor 0x02)
    Write-Host "Tema scuro impostato!" -ForegroundColor Green
}