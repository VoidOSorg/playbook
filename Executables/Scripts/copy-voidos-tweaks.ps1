$Desktop = [Environment]::GetFolderPath('Desktop')

$Source = Join-Path $PSScriptRoot "..\..\Resources\VoidOS-Tweaks"
$Source = Resolve-Path $Source

$Dest = Join-Path $Desktop "VoidOS-Tweaks"

# Copia cartella
Copy-Item -Path $Source -Destination $Desktop -Recurse -Force

# Percorsi
$Ini  = Join-Path $Dest "desktop.ini"
$Icon = Join-Path $Dest "icon.ico"

# Attributi (QUESTO È IL SEGRETO)
attrib +s +h "$Ini"
attrib +r "$Dest"

# Refresh Explorer
Stop-Process -Name explorer -Force
Start-Process explorer.exe
