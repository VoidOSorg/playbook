# File: C:\Users\vdrag\Desktop\VoidOS_Playbook\Executables\VoidOSModules\Components\remove-apps.ps1

Write-Host "=== Removing Windows Bloatware ===" -ForegroundColor Cyan

# Lista completa delle app da rimuovere
$AppxPackages = @(
    # Microsoft Apps
    "Microsoft.BingWeather",
    "Microsoft.BingNews", 
    "Microsoft.BingSports",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.YourPhone",
    "Microsoft.WindowsMaps",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    
    # Advertising & Telemetry
    "Microsoft.Advertising.Xaml",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsCommunicationsApps",
    "Microsoft.WindowsSoundRecorder",
    
    # Windows 11 specific
    "Microsoft.Windows.DevHome",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Todos",
    "MicrosoftCorporationII.QuickAssist",
    
    # Third-party apps
    "Clipchamp.Clipchamp",
    "Disney.37853FC22B2CE",
    "SpotifyAB.SpotifyMusic",
    "FACEBOOK.317180B0BB486",
    "PANDORA.MEDIAPANDORA"
)

# Rimuove app per tutti gli utenti
$removedCount = 0
foreach ($Package in $AppxPackages) {
    try {
        Write-Host "Removing: $Package" -ForegroundColor Gray
        
        # Rimuove per l'utente corrente
        Get-AppxPackage -Name $Package -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        
        # Rimuove per tutti gli utenti
        Get-AppxPackage -Name $Package -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        
        # Rimuove pacchetti provisioned
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
            Where-Object DisplayName -Like $Package | 
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        
        $removedCount++
    }
    catch {
        # Silenzioso
    }
}

Write-Host "`n✓ Removed $removedCount apps" -ForegroundColor Green