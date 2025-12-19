# Script VoidOS - Disinstallazione App Windows
# Deve essere eseguito come amministratore

Write-Output "=== VoidOS - Disinstallazione App Windows ==="
Write-Output "  Questo processo potrebbe richiedere alcuni minuti..."
Write-Output ""

# Lista completa delle app da disinstallare
$appsToRemove = @(
    # Microsoft 3D Viewer
    "Microsoft.Microsoft3DViewer",
    
    # AI Copilot (Windows 11)
    "Microsoft.Windows.AICopilot.Prototype",
    "Microsoft.Windows.AICopilot",
    
    # Cortana
    "Microsoft.549981C3F5F10",
    
    # Feedback Hub
    "Microsoft.WindowsFeedbackHub",
    
    # Maps
    "Microsoft.WindowsMaps",
    
    # Mail and Calendar
    "microsoft.windowscommunicationsapps",
    
    # OneDrive
    "Microsoft.OneDriveSync",
    
    # Microsoft Edge
    "Microsoft.MicrosoftEdge.Stable",
    "Microsoft.MicrosoftEdge",
    "Microsoft.MicrosoftEdge.Stable",
    
    # Film e TV
    "Microsoft.ZuneVideo",
    
    # Office Apps
    "Microsoft.Office.OneNote",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.Office.Outlook",
    
    # Paint (se presente come app)
    "Microsoft.Paint",
    
    # People
    "Microsoft.People",
    
    # Skype
    "Microsoft.SkypeApp",
    
    # Solitaire Collection
    "Microsoft.MicrosoftSolitaireCollection",
    
    # Sticky Notes
    "Microsoft.MicrosoftStickyNotes",
    
    # Weather
    "Microsoft.BingWeather",
    
    # Alarms & Clock
    "Microsoft.WindowsAlarms",
    
    # Xbox apps
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxGameCallableUI",
    
    # Altre app Microsoft
    "Microsoft.BingNews",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Office.Sway",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.ScreenSketch",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Wallet",
    "Microsoft.WebMediaExtensions",
    "Microsoft.WebpImageExtension",
    "Microsoft.Whiteboard",
    "Microsoft.Windows.Photos",
    "Microsoft.Windows.ParentalControls",
    "Microsoft.WindowsCamera",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic"
)

# App da NON rimuovere (essenziali)
$essentialApps = @(
    "Microsoft.WindowsStore",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsNotepad",
    "Microsoft.VCLibs",
    "Microsoft.NET.Native",
    "Microsoft.Services.Store.Engagement",
    "Microsoft.UI.Xaml"
)

$removedCount = 0
$errorCount = 0
$totalApps = $appsToRemove.Count

Write-Output "  Trovate $totalApps app da rimuovere"
Write-Output ""

# Fase 1: Rimozione pacchetti Appx per tutti gli utenti
Write-Output "  FASE 1: Rimozione pacchetti Appx..."
foreach ($app in $appsToRemove) {
    try {
        Write-Host "  Processing: " -NoNewline
        Write-Host $app -ForegroundColor Cyan -NoNewline
        
        $packages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        
        if ($packages) {
            foreach ($package in $packages) {
                try {
                    Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                    Write-Host " - " -NoNewline
                    Write-Host "RIMOSSO" -ForegroundColor Green
                    $removedCount++
                }
                catch {
                    Write-Host " - " -NoNewline
                    Write-Host "FALLITO" -ForegroundColor Red
                    $errorCount++
                }
            }
        }
        else {
            Write-Host " - " -NoNewline
            Write-Host "NON TROVATO" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host " - " -NoNewline
        Write-Host "ERRORE" -ForegroundColor Red
        $errorCount++
    }
}

# Fase 2: Rimozione pacchetti provisioned
Write-Output ""
Write-Output "  FASE 2: Rimozione pacchetti provisioned..."
try {
    $provisionedPackages = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    
    foreach ($app in $appsToRemove) {
        $matchingPackages = $provisionedPackages | Where-Object { 
            $_.DisplayName -like "*$app*" -or $_.PackageName -like "*$app*"
        }
        
        foreach ($pkg in $matchingPackages) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction SilentlyContinue
                Write-Output "    ✓ Rimosso provisioned: $($pkg.DisplayName)"
            }
            catch {
                # Ignora errori silenziosi
            }
        }
    }
}
catch {
    Write-Output "  ⚠ Errore nella rimozione provisioned: $($_.Exception.Message)"
}

# Fase 3: Disinstallazione OneDrive speciale
Write-Output ""
Write-Output "  FASE 3: Disinstallazione OneDrive..."
try {
    # Metodo 1: Tramite setup
    $onedrivePaths = @(
        "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe",
        "$env:SYSTEMROOT\System32\OneDriveSetup.exe",
        "${env:ProgramFiles}\Microsoft OneDrive\OneDriveSetup.exe",
        "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDriveSetup.exe"
    )
    
    foreach ($path in $onedrivePaths) {
        if (Test-Path $path) {
            try {
                Start-Process $path "/uninstall" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
                Write-Output "    ✓ OneDrive disinstallato da: $path"
            }
            catch { }
        }
    }
    
    # Metodo 2: Kill processo e rimozione cartella
    taskkill /f /im OneDrive.exe /t 2>$null
    Start-Sleep -Seconds 2
    
    # Disabilita avvio automatico
    if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive") {
        Remove-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force
}
catch {
    Write-Output "    ⚠ Errore OneDrive: $($_.Exception.Message)"
}

# Fase 4: Pulizia Windows Update delle app
Write-Output ""
Write-Output "  FASE 4: Pulizia finale..."
try {
    # Blocca reinstallazione app da Windows Update
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    Set-ItemProperty -Path $registryPath -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
    
    # Disabilita suggerimenti app
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord -Force
    
    Write-Output "    ✓ Bloccata reinstallazione automatica app"
}
catch {
    Write-Output "    ⚠ Errore nella pulizia finale: $($_.Exception.Message)"
}

# Riepilogo
Write-Output ""
Write-Output "=== RIEPILOGO DISINSTALLAZIONE ==="
Write-Output "  App totali da rimuovere: $totalApps"
Write-Output "  App rimosse con successo: $removedCount"
Write-Output "  Errori durante la rimozione: $errorCount"
Write-Output "  App essenziali preservate: $($essentialApps.Count)"
Write-Output ""
Write-Output "  Per un effetto completo, si consiglia un riavvio del sistema."
Write-Output ""

Write-Output "=== OPERAZIONE COMPLETATA ==="
Start-Sleep -Seconds 5