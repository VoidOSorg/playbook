# Script VoidOS - Importazione Automatica Power Plan
# Cerca automaticamente il file .pow e lo importa

param(
    [switch]$Silent,
    [string]$CustomPath
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Questo script richiede privilegi di amministratore!" -ForegroundColor Red
    Write-Host "Esegui come amministratore e riprova." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    exit 1
}

function Import-PowerPlan {
    param([string]$FilePath)
    
    Write-Output "Importazione da: $FilePath"
    
    # Importa
    $result = powercfg -import "$FilePath" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Output "✓ Importazione completata"
        
        # Trova GUID
        $plans = powercfg -list
        $guid = $null
        
        foreach ($line in $plans) {
            if ($line -match "VoidOS.*([a-fA-F0-9\-]{36})") {
                $guid = $matches[1]
                break
            }
        }
        
        if ($guid) {
            # Attiva
            powercfg -setactive $guid 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Output "✓ Power Plan attivato (GUID: $guid)"
                return $true
            }
        }
    }
    
    return $false
}

# CERCA FILE .pow
$foundFiles = @()

# Directory da cercare
$searchPaths = @(
    (Get-Location).Path,
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop\VoidOS-Tweaks",
    "$env:USERPROFILE\Documents",
    "C:\VoidOS",
    "C:\Temp"
)

Write-Output "=== VoidOS Power Plan Importer ==="
Write-Output "Ricerca file .pow in corso..."

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Filter "*VoidOS*.pow" -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            $foundFiles += $file.FullName
            Write-Output "  Trovato: $($file.FullName)"
        }
    }
}

if ($foundFiles.Count -eq 0) {
    Write-Output "✗ Nessun file .pow trovato!"
    
    # Cerca qualsiasi file .pow
    Write-Output "Ricerca generale file .pow..."
    $allPowFiles = Get-ChildItem -Path C:\ -Filter "*.pow" -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 5
    
    if ($allPowFiles) {
        Write-Output "File .pow trovati (non VoidOS):"
        foreach ($file in $allPowFiles) {
            Write-Output "  $($file.FullName)"
        }
    }
    
    exit 1
}

# Se trovato uno solo, importa automaticamente
if ($foundFiles.Count -eq 1) {
    Write-Output ""
    Write-Output "Trovato 1 file, procedo con l'importazione..."
    $success = Import-PowerPlan -FilePath $foundFiles[0]
    
    if ($success) {
        Write-Output "`n=== IMPORT AZIONE COMPLETATA ==="
    } else {
        Write-Output "`n=== IMPORT AZIONE FALLITA ==="
    }
}
else {
    # Multipli file trovati
    Write-Output ""
    Write-Output "Trovati $($foundFiles.Count) file:"
    
    for ($i = 0; $i -lt $foundFiles.Count; $i++) {
        Write-Output "  [$i] $($foundFiles[$i])"
    }
    
    Write-Output ""
    $selection = Read-Host "Seleziona il numero del file da importare (0-$($foundFiles.Count-1))"
    
    if ($selection -match "^\d+$" -and [int]$selection -lt $foundFiles.Count) {
        $success = Import-PowerPlan -FilePath $foundFiles[$selection]
        
        if ($success) {
            Write-Output "`n=== IMPORT AZIONE COMPLETATA ==="
        }
    }
}

Start-Sleep -Seconds 2