$wallpaper = "C:\Windows\Web\Wallpaper\VoidOS\default.jpg"

# crea cartella
New-Item -ItemType Directory -Path "C:\Windows\Web\Wallpaper\VoidOS" -Force

# copia immagine
Copy-Item "$PSScriptRoot\wllppr0.png" $wallpaper -Force

# forza wallpaper sistema (tutti gli utenti)
Set-ItemProperty `
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  Wallpaper $wallpaper -Type String

Set-ItemProperty `
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  WallpaperStyle "10" -Type String

# refresh
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
