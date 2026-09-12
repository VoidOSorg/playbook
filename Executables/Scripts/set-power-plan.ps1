$PlaybookRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$PowerPlanPath = Join-Path $PlaybookRoot "Resources\PowerPlan\VoidOS_Powerplan.pow"
$SettingsPath  = Join-Path $PlaybookRoot "Resources\PowerPlan\settings.xml"

$PlanName        = "VoidOS - Pwrpln - Performance * Remastered"
$PlanDescription = "The best way to incrase the perfomances in 2026"
$GuidRegex       = "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"

if (-not (Test-Path $PowerPlanPath)) {
    Write-Host "[!] Power plan not found: $PowerPlanPath"
    exit 1
}
if (-not (Test-Path $SettingsPath)) {
    Write-Host "[!] Settings file not found: $SettingsPath"
    exit 1
}

# --- 1) IMPORT (catch the scheme GUID from import output: it can change per machine) ---
Write-Host "[+] Importing power plan: $PowerPlanPath"
$ImportOut = powercfg -import "$PowerPlanPath" 2>&1
$Guid = $null
if ($ImportOut) {
    $m = [regex]::Match(($ImportOut -join " "), $GuidRegex)
    if ($m.Success) { $Guid = $m.Value }
}
if (-not $Guid) {
    # Fallback: find it by name in the plan list
    $plans = powercfg -list 2>&1
    foreach ($line in $plans) {
        if ($line -match "VoidOS.*($GuidRegex)") {
            $Guid = $Matches[1]
            break
        }
    }
}
if (-not $Guid) {
    Write-Host "[!] Could not determine the imported power plan GUID"
    exit 1
}
Write-Host "[OK] Imported plan GUID: $Guid"

# --- 2) RENAME to the official VoidOS name/description ---
powercfg -changename $Guid "$PlanName" "$PlanDescription" 2>&1 | Out-Null

# --- 3) APPLY every setting from settings.xml to THIS scheme GUID ---
Write-Host "[+] Applying optimization settings from settings.xml..."
[xml]$Xml = Get-Content $SettingsPath
$ok = 0
$fail = 0

foreach ($sub in $Xml.root.subgroup) {
    $subGuid = $sub.guid
    foreach ($setting in $sub.setting) {
        $setGuid = $setting.guid
        $ac = $setting.acindex.value
        $dc = $setting.dcindex.value

        powercfg -setacvalueindex $Guid $subGuid $setGuid $ac 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $ok++ } else { $fail++ }

        powercfg -setdcvalueindex $Guid $subGuid $setGuid $dc 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $ok++ } else { $fail++ }
    }
}
Write-Host "[OK] Applied settings (ac+dc). OK=$ok skipped=$fail"

# --- 4) ACTIVATE ---
powercfg -setactive $Guid 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Power plan activated: $PlanName (GUID: $Guid)"
    exit 0
} else {
    Write-Host "[!] Failed to set the power plan active"
    exit 1
}