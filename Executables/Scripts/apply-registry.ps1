# Applica tweak registry VoidOS dai file .reg
Write-Host "Applicazione tweak registry VoidOS..." -ForegroundColor Cyan

# Definisci i percorsi dei tuoi file .reg
$regFiles = @(
    "$PSScriptRoot\..\Registry\fix.reg"       # File 1
    "$PSScriptRoot\..\Registry\full.reg"      # File 2
)

foreach ($regFile in $regFiles) {
    if (Test-Path $regFile) {
        Write-Host "Applico: $(Split-Path $regFile -Leaf)..." -ForegroundColor Yellow
        # Importa il file .reg
        reg import $regFile 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Successo" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Errore nell'applicare $(Split-Path $regFile -Leaf)" -ForegroundColor Red
        }
    } else {
        Write-Host "File non trovato: $regFile" -ForegroundColor Red
    }
}