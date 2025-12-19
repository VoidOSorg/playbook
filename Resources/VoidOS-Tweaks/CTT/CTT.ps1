# Verifica se lo script è in esecuzione come amministratore
$adminCheck = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $adminCheck.IsInRole($adminRole)) {
    # Richiede i privilegi di amministratore per eseguire lo script
    $arguments = "& '" + $myinvocation.MyCommand.Definition + "'"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $arguments" -Verb RunAs
    Exit
}

# Esegui l'utility di Cristitus Tech
iwr -useb https://christitus.com/win | iex
