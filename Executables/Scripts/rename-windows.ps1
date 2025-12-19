# Rinomina Windows in VoidOS
Write-Host "Rinominando Windows in VoidOS..." -ForegroundColor Cyan

# Esempio - modifica con i tuoi comandi effettivi
$newName = "VoidOS"
try {
    Rename-Computer -NewName $newName -Force -ErrorAction Stop
    Write-Host "Nome computer cambiato in $newName" -ForegroundColor Green
} catch {
    Write-Host "Errore nel rinominare il computer: $_" -ForegroundColor Red
}