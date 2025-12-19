# Desktop dell'utente attivo
$Desktop = [Environment]::GetFolderPath('Desktop')

# Root del playbook
$PlaybookRoot = Resolve-Path "$PSScriptRoot\..\.."

# Sorgente
$Source = Join-Path $PlaybookRoot "Resources\VoidOS-Tweaks"

if (-not (Test-Path $Source)) {
    Write-Error "Source not found: $Source"
    exit 1
}

Copy-Item -Path $Source -Destination $Desktop -Recurse -Force

