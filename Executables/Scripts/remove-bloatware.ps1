# Rimuove bloatware Microsoft
Write-Host "Rimozione bloatware Microsoft..." -ForegroundColor Cyan

# Esempio - aggiungi i pacchetti che vuoi rimuovere
$appsToRemove = @(
    "Microsoft.BingNews"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    # Aggiungi altri pacchetti qui
)

foreach ($app in $appsToRemove) {
    try {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Host "Rimosso: $app" -ForegroundColor Green
    } catch {
        Write-Host "Non rimosso: $app" -ForegroundColor Yellow
    }
}