# ===============================
# VoidOS Power Plan Import & Set
# ===============================

$PlaybookRoot = Split-Path -Parent $PSScriptRoot
$PowerPlanPath = Join-Path $PlaybookRoot "Resources\PowerPlans\VoidOS Powerplan - Idle Standard.pow"

if (-not (Test-Path $PowerPlanPath)) {
    Write-Host "[ERROR] Power plan not found: $PowerPlanPath"
    exit 1
}

Write-Host "[INFO] Importing power plan..."

# Import power plan and capture GUID
$ImportOutput = powercfg -import "$PowerPlanPath"
Start-Sleep -Seconds 1

# Get latest imported power plan (non-default)
$Plan = powercfg -list | Select-String "VoidOS"

if (-not $Plan) {
    Write-Host "[ERROR] Power plan not found after import"
    exit 1
}

$Guid = ($Plan -split '\s+')[3]

Write-Host "[INFO] Setting power plan active: $Guid"

powercfg -setactive $Guid

Write-Host "[INFO] Power plan activated successfully."
exit 0
