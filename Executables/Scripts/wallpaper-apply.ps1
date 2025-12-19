$Path = "C:\Windows\VoidOS\wllppr0.png"

Set-ItemProperty "HKCU:\Control Panel\Desktop" Wallpaper $Path

rundll32.exe user32.dll,UpdatePerUserSystemParameters
