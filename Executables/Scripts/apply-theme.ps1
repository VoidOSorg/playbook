# Apply voidos.theme to the current user profile
$Theme = "C:\Windows\Resources\Themes\voidos.theme"

if (Test-Path $Theme) {
    & "$env:WINDIR\System32\rundll32.exe" "$env:WINDIR\System32\themecpl.dll,OpenThemeAction" $Theme
    Start-Sleep -Seconds 1
    Write-Host "VoidOS theme applied (current user)"
} else {
    Write-Host "[!] Theme not found: $Theme"
}