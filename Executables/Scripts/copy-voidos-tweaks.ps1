$Desktop = [Environment]::GetFolderPath('Desktop')

$Source = Join-Path $PSScriptRoot "..\..\Resources\VoidOS-Tweaks"
$Source = Resolve-Path $Source

# Copia cartella
Copy-Item -Path $Source -Destination $Desktop -Recurse -Force

# Percorsi
$Dest = Join-Path $Desktop "VoidOS-Tweaks"
$shortcutPng = Join-Path $PSScriptRoot "..\..\Images\shortcut.png"
$icoPath = Join-Path $Dest "VoidOS.ico"

# Icona scorciatoia: converti shortcut.png in shortcut.ico (le .lnk richiedono .ico)
Add-Type -AssemblyName System.Drawing
$srcImg   = [System.Drawing.Image]::FromFile($shortcutPng)
$bmp      = New-Object System.Drawing.Bitmap 256, 256
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawImage($srcImg, 0, 0, 256, 256)
$graphics.Dispose()
$hIcon = $bmp.GetHicon()
$icon  = [System.Drawing.Icon]::FromHandle($hIcon)
$fs = [System.IO.File]::Create($icoPath)
$icon.Save($fs)
$fs.Close()
$icon.Dispose()
$bmp.Dispose()
$srcImg.Dispose()

# Scorciatoia sul desktop
$wsh = New-Object -ComObject WScript.Shell
$lnk = $wsh.CreateShortcut((Join-Path $Desktop "VoidOS.lnk"))
$lnk.TargetPath       = $Dest
$lnk.WorkingDirectory = $Dest
$lnk.IconLocation     = "$icoPath,0"
$lnk.Description      = "VoidOS Tweaks"
$lnk.Save()

# Pin sulla barra delle applicazioni (stesso meccanismo di pin-taskbar.ps1)
& (Join-Path $PSScriptRoot "pin-taskbar.ps1") -Target (Join-Path $Desktop "VoidOS.lnk")

# Refresh Explorer
Stop-Process -Name explorer -Force
Start-Process explorer.exe

Write-Host "VoidOS-Tweaks copied with desktop shortcut + taskbar pin." -ForegroundColor Green