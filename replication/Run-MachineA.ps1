<#
.SYNOPSIS
  Reproduce every machine-A exhibit and number, then check the draft against them.

.DESCRIPTION
  1. Refuses to start if the paper repo has uncommitted changes to tracked files
     under figures/ -- otherwise a regenerated exhibit could not be told apart
     from a hand edit when the diff is read afterwards.
  2. Runs replication/run_machineA.do through Run-Stata.ps1.
  3. Runs replication/check_claims.py.
  4. Shows what the run changed. In the paper repo, a changed .tex table is a
     result that did not reproduce. PDFs always differ (they embed a timestamp),
     so figures are checked through the numbers behind them, not their bytes.
     In this repo, a changed replication/results/*.tex is a number that moved.

.PARAMETER SkipRebuild
  Skip create_figures_SSHA2025.do (hours) and run the rest on the existing
  analysis file. Table 4's numbers are then left from the last full run.

.EXAMPLE
  .\replication\Run-MachineA.ps1 -SkipRebuild
#>
param([switch]$SkipRebuild)

$ErrorActionPreference = "Stop"
$repo  = Split-Path $PSScriptRoot
$paper = "D:\repos\6638fa0fd89fbec05130caeb"

$dirty = git -C $paper status --porcelain --untracked-files=no figures/
if ($LASTEXITCODE -ne 0) { Write-Error "git status failed in $paper"; exit 1 }
if ($dirty) {
    Write-Host "Paper repo has uncommitted changes under figures/ -- commit or stash them first:" -ForegroundColor Red
    $dirty | ForEach-Object { Write-Host "  $_" }
    exit 1
}

# Pass the switch to Stata through a global, set in a one-line wrapper.
$wrapper = Join-Path $env:TEMP "run_machineA_entry.do"
$skip = if ($SkipRebuild) { 1 } else { 0 }
Set-Content -Path $wrapper -Encoding ASCII -Value @(
    "global REP_SKIP_REBUILD $skip",
    "do `"$($repo -replace '\\','/')/replication/run_machineA.do`""
)

& (Join-Path $PSScriptRoot "Run-Stata.ps1") -DoFile $wrapper
$stataExit = $LASTEXITCODE
$log = Join-Path $env:TEMP "run_machineA_entry.log"
$keep = Join-Path $PSScriptRoot "run_machineA.log"
if (Test-Path $log) { Move-Item $log $keep -Force; Write-Host "Stata log: $keep" }
Remove-Item $wrapper -ErrorAction SilentlyContinue
if ($stataExit -ne 0) { Write-Host "Stata run failed; claim check not run." -ForegroundColor Red; exit $stataExit }

Write-Host "`n=== claim check ==="
python (Join-Path $PSScriptRoot "check_claims.py")
$checkExit = $LASTEXITCODE

Write-Host "`n=== exhibits changed in the paper repo (a changed .tex table did not reproduce) ==="
git -C $paper status --short figures/
Write-Host "`n=== result files changed in this repo (a changed line is a number that moved) ==="
git -C $repo status --short replication/results/
git -C $repo diff --stat replication/results/

exit $checkExit
