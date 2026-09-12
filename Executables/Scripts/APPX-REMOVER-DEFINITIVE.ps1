if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Run as Administrator"
    exit 1
}

$Global:Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
function Write-Elapsed { "[{0:N1}s] " -f $Global:Stopwatch.Elapsed.TotalSeconds }

Write-Host "$(Write-Elapsed) Removing built-in Windows apps..." -ForegroundColor Cyan

$Apps = @(
    "Microsoft.549981C3F5F10",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.People",
    "Microsoft.WindowsMaps",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MSPaint",
    "Microsoft.ScreenSketch",
    "Microsoft.SkypeApp",
    "Microsoft.Office.OneNote",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Windows.Photos",
    "Microsoft.BingWeather",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "MicrosoftWindows.Client.WebExperience",
    "Microsoft.WidgetsPlatformRuntime",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.GamingApp",
    "microsoft.windowscommunicationsapps",
    "Microsoft.Microsoft3DViewer",
    "MixedReality.Portal",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.YourPhone",
    "Microsoft.OneConnect",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Todos",
    "MicrosoftCorporationII.QuickAssist",
    "Clipchamp.Clipchamp",
    "SpotifyAB.SpotifyMusic"
)

# --- 1) Remove provisioned packages (ONE DISM query for all, batched) ---
Write-Host "$(Write-Elapsed) Enumerating provisioned packages (single query)..." -ForegroundColor Yellow
$Provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -in $Apps }

$total = $Provisioned.Count
$i = 0
foreach ($pkg in $Provisioned) {
    $i++
    Write-Host "$(Write-Elapsed) [Provisioned $i/$total] $($pkg.DisplayName)"
    Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction SilentlyContinue
}

# --- 2) Remove per-user package registrations (single query) ---
Write-Host "$(Write-Elapsed) Enumerating installed packages (single query)..." -ForegroundColor Yellow
$Installed = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue | Where-Object { $_.Name -in $Apps }

$total = $Installed.Count
$i = 0
foreach ($pkg in $Installed) {
    $i++
    Write-Host "$(Write-Elapsed) [Package $i/$total] $($pkg.Name)"
    Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
}

Write-Host "$(Write-Elapsed) APPX removal complete. ($($Provisioned.Count) provisioned, $($Installed.Count) packages)" -ForegroundColor Green