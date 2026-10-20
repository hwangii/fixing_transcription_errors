<#
.SYNOPSIS
  Reproduce Tables 5-8 (Deaglan's linkage tables) on machine B, then check the draft against them.

.DESCRIPTION
  1. Refuses to start if the paper repo has uncommitted changes to tracked files
     under figures/, deaglan_results/ or linkage_tables/ -- otherwise a regenerated exhibit could
     not be told apart from a hand edit when the diff is read afterwards.
  2. Runs replication/run_machineB.do through Run-Stata.ps1: preflight, then
     LINKAGE/code/00_run_all_tables.do (~4 hours).
  3. Runs extract_deaglan_tables.py --regenerated: compares each regenerated
     table with the committed copy in the paper repo's linkage_tables/ by
     SHA-256, then writes the tabular into figures/deaglan_*.tex.
  4. Runs replication/check_claims.py.
  5. Shows what the run changed. As on machine A, a changed
     figures/deaglan_*.tex in the paper repo is a table that did NOT reproduce.
     In this repo, a changed replication/results/*.tex is a number that moved.

.PARAMETER PreflightOnly
  Check that config.do, the code and all inputs resolve, and stop. Seconds.

.EXAMPLE
  .\replication\Run-MachineB.ps1 -PreflightOnly
  .\replication\Run-MachineB.ps1
#>
param([switch]$PreflightOnly)

$ErrorActionPreference = "Stop"
$repo   = Split-Path $PSScriptRoot
$paper  = "F:\github_repos\6638fa0fd89fbec05130caeb"
$tables = "F:/Deaglan/Census_Transcriptions/output/tables"

$dirty = git -C $paper status --porcelain --untracked-files=no figures/ deaglan_results/ linkage_tables/
if ($LASTEXITCODE -ne 0) { Write-Error "git status failed in $paper"; exit 1 }
if ($dirty) {
    Write-Host "Paper repo has uncommitted changes under figures/, deaglan_results/ or linkage_tables/ -- commit or stash them first:" -ForegroundColor Red
    $dirty | ForEach-Object { Write-Host "  $_" }
    exit 1
}

# Pass the switch to Stata through a global, set in a one-line wrapper.
$wrapper = Join-Path $env:TEMP "run_machineB_entry.do"
$pre = if ($PreflightOnly) { 1 } else { 0 }
Set-Content -Path $wrapper -Encoding ASCII -Value @(
    "global REP_PREFLIGHT_ONLY $pre",
    "do `"$($repo -replace '\\','/')/replication/run_machineB.do`""
)

& (Join-Path $PSScriptRoot "Run-Stata.ps1") -DoFile $wrapper -TimeoutMinutes 480
$stataExit = $LASTEXITCODE
$log = Join-Path $env:TEMP "run_machineB_entry.log"
$keep = Join-Path $PSScriptRoot "run_machineB.log"
if (Test-Path $log) { Move-Item $log $keep -Force; Write-Host "Stata log: $keep" }
Remove-Item $wrapper -ErrorAction SilentlyContinue
if ($stataExit -ne 0) { Write-Host "Stata run failed; extraction and claim check not run." -ForegroundColor Red; exit $stataExit }
if ($PreflightOnly) { Select-String -Path $keep -Pattern "^preflight:" | ForEach-Object { Write-Host $_.Line }; exit 0 }

Write-Host "`n=== did Deaglan's tables reproduce? (regenerated vs linkage_tables/) ==="
python (Join-Path $PSScriptRoot "extract_deaglan_tables.py") --paper-repo $paper --regenerated $tables
$extractExit = $LASTEXITCODE

Write-Host "`n=== claim check ==="
python (Join-Path $PSScriptRoot "check_claims.py")
$checkExit = $LASTEXITCODE

Write-Host "`n=== exhibits changed in the paper repo (a changed deaglan_*.tex did NOT reproduce) ==="
git -C $paper status --short --untracked-files=no figures/ deaglan_results/ linkage_tables/
git -C $paper diff --stat figures/
Write-Host "`n=== result files changed in this repo (a changed line is a number that moved) ==="
git -C $repo status --short replication/results/
git -C $repo diff --stat replication/results/

if ($extractExit -ne 0) { exit 1 }
exit $checkExit
