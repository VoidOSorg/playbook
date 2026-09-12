Write-Host "Optimizing scheduler and latency..." -ForegroundColor Cyan

bcdedit /set disabledynamictick yes
bcdedit /set useplatformclock false
bcdedit /set tscsyncpolicy Enhanced

powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFINCPOL 2
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFDECPOL 1
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFINCTHRESHOLD 10
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFDECTHRESHOLD 8

powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100

powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 1

Write-Host "Scheduler optimization complete." -ForegroundColor Green
