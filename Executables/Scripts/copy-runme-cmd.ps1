$Desktop = [Environment]::GetFolderPath('Desktop')

$Source = Join-Path $PSScriptRoot "..\..\Executables\batch_files\RUNME.cmd"
$Source = Resolve-Path $Source

Copy-Item -Path $Source -Destination $Desktop -Force
