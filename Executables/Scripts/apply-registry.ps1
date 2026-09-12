# Applica tweak registry VoidOS dai file .reg
$Global:Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
function Write-Elapsed { "[{0:N1}s] " -f $Global:Stopwatch.Elapsed.TotalSeconds }

Write-Host "$(Write-Elapsed) Applicazione tweak registry VoidOS..." -ForegroundColor Cyan

# Definisci i percorsi dei tuoi file .reg
$regFiles = @(
    "$PSScriptRoot\..\Registry\fix.reg",       # File 1
    "$PSScriptRoot\..\Registry\full.reg"       # File 2
)

$ok = 0
$fail = 0

foreach ($regFile in $regFiles) {
    if (Test-Path $regFile) {
        $name = Split-Path $regFile -Leaf
        Write-Host "$(Write-Elapsed) Applico: $name ..." -ForegroundColor Yellow
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        reg import $regFile 2>$null
        if ($LASTEXITCODE -eq 0) {
            $ok++
            Write-Host "$(Write-Elapsed)  [OK] $name in $([math]::Round($sw.Elapsed.TotalSeconds,1))s" -ForegroundColor Green
        } else {
            $fail++
            Write-Host "$(Write-Elapsed)  [X] Errore nell'applicare $name (exit $LASTEXITCODE)" -ForegroundColor Red
        }
    } else {
        $fail++
        Write-Host "$(Write-Elapsed) File non trovato: $regFile" -ForegroundColor Red
    }
}

Write-Host "$(Write-Elapsed) Registry import done. OK=$ok fail=$fail" -ForegroundColor Green