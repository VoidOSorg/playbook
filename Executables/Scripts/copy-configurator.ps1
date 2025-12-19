$Desktop = [Environment]::GetFolderPath('Desktop')

$Source = Join-Path $PSScriptRoot "..\..\Executables\Scripts\CONFIGURATOR.ps1"
$Source = Resolve-Path $Source

Copy-Item -Path $Source -Destination $Desktop -Force
