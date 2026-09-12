$ThemeSource = Join-Path $PSScriptRoot "..\..\Resources\Themes\voidos.theme"
$ThemeDest   = "$env:SystemRoot\Resources\Themes\voidos.theme"

New-Item -ItemType Directory -Path "$env:SystemRoot\Resources\Themes" -Force | Out-Null
Copy-Item -Path $ThemeSource -Destination $ThemeDest -Force
Write-Host "Theme installed to $ThemeDest"