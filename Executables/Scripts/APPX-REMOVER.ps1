# ==========================
# REQUIRE ADMIN
# ==========================
if (-not ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Run as Administrator"
    exit 1
}

# ==========================
# APP LIST (KEY PART)
# ==========================
$Apps = @(
    # CORE BLOAT
    "Microsoft.549981C3F5F10",              # Cortana
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.People",
    "Microsoft.WindowsMaps",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MSPaint",                    # Paint 3D
    "Microsoft.ScreenSketch",               # Snip & Sketch
    "Microsoft.SkypeApp",
    "Microsoft.Office.OneNote",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Windows.Photos",
    "Microsoft.BingWeather",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",

    # WIDGETS / COPILOT
    "MicrosoftWindows.Client.WebExperience",
    "Microsoft.WidgetsPlatformRuntime",

    # XBOX
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.GamingApp",

    # COMMUNICATION
    "microsoft.windowscommunicationsapps",

    # 3D / MR
    "Microsoft.Microsoft3DViewer",
    "MixedReality.Portal"
)

# ==========================
# REMOVE FOR ALL USERS
# ==========================
foreach ($App in $Apps) {

    Write-Host "Removing: $App"

    # Remove installed packages
    Get-AppxPackage -AllUsers -Name $App -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }

    # Remove provisioned (IMPORTANT)
    Get-AppxProvisionedPackage -Online | Where-Object {
        $_.DisplayName -eq $App
    } | ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    }
}

# ==========================
# ONE DRIVE (REAL REMOVAL)
# ==========================
Write-Host "Removing OneDrive"

Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue

$OneDriveSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $OneDriveSetup) {
    Start-Process $OneDriveSetup "/uninstall" -NoNewWindow -Wait
}

Remove-Item "$env:UserProfile\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue

# ==========================
# DISABLE COPILOT (HARD)
# ==========================
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" `
    -Name "TurnOffWindowsCopilot" -Type DWord -Value 1

# ==========================
# DONE
# ==========================
Write-Host "APPX DEBLOAT COMPLETE"
