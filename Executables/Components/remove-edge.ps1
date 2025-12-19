# File: C:\Users\vdrag\Desktop\VoidOS_Playbook\Executables\VoidOSModules\Components\remove-edge.ps1

Write-Host "=== Removing Microsoft Edge ===" -ForegroundColor Cyan

# 1. Ferma Edge se in esecuzione
Get-Process -Name "msedge" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "MicrosoftEdge" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "MicrosoftEdgeUpdate" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Rimuove AppX Edge
$EdgePackages = @(
    "Microsoft.MicrosoftEdge.Stable",
    "Microsoft.MicrosoftEdge",
    "Microsoft.MicrosoftEdgeDevToolsClient"
)

foreach ($Package in $EdgePackages) {
    try {
        Write-Host "Removing Edge: $Package" -ForegroundColor Gray
        
        # Rimuove per tutti gli utenti
        Get-AppxPackage -Name $Package* -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        
        # Rimuove pacchetti provisioned
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
            Where-Object DisplayName -Like "$Package*" | 
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    catch {
        # Silenzioso
    }
}

# 3. Disinstalla Edge con winget (se disponibile)
try {
    winget uninstall "Microsoft Edge" --silent --accept-source-agreements --disable-interactivity
}
catch {
    # Fallback
}

Write-Host "✓ Microsoft Edge removed" -ForegroundColor Green