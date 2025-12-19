$Desktop = [Environment]::GetFolderPath('Desktop')
$Source  = Join-Path $PSScriptRoot "..\..\Resources\CONFIGURATOR"
$Source  = Resolve-Path $Source

Copy-Item -Path $Source -Destination $Desktop -Recurse -Force
