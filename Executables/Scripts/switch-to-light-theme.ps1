# Cambia al tema chiaro
$lightDesktop = "C:\VoidOS\Wallpapers\Light\Desktop\wllppr3.png"
$lightLockscreen = "C:\VoidOS\Wallpapers\Light\Lockscreen\wllppr4.png"

if (Test-Path $lightDesktop) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    [Wallpaper]::SystemParametersInfo(20, 0, $lightDesktop, 0x01 -bor 0x02)
    Write-Host "Tema chiaro impostato!" -ForegroundColor Green
}