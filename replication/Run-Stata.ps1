<#
.SYNOPSIS
  Run one do-file in Stata batch mode and report success or failure reliably.

.DESCRIPTION
  Stata 15 batch mode (/b) writes no end-of-run marker and no exit code. Worse,
  when a do-file errors, the log simply stops mid-command -- no r(###); is
  written -- and Stata waits on an invisible dialog until killed. So the
  target is wrapped in a do-file that runs it under `capture noisily` and
  then always prints "RUN-STATA-RC: <return code>". rc 0 is success; any
  other rc is the error; no RC line by the timeout is a failure. The log is
  left next to the do-file as <name>.log. Logs are gitignored.

  Do not call StataMP-64.exe /b from Git Bash: MSYS rewrites "/b" into a
  drive path and Stata never runs the file.

.EXAMPLE
  .\replication\Run-Stata.ps1 replication\run_machineA.do
#>
param(
    [Parameter(Mandatory)][string]$DoFile,
    [string]$Stata = "C:\Program Files (x86)\Stata15\StataMP-64.exe",
    [int]$TimeoutMinutes = 600
)

$ErrorActionPreference = "Stop"
$do   = (Resolve-Path $DoFile).Path
$dir  = Split-Path $do
$name = [IO.Path]::GetFileNameWithoutExtension($do)
$wrap = Join-Path $dir "_run_$name.do"
$wlog = Join-Path $dir "_run_$name.log"
$log  = Join-Path $dir "$name.log"

foreach ($f in $wlog, $log) { if (Test-Path $f) { Remove-Item $f } }
Set-Content -Path $wrap -Encoding ASCII -Value @(
    "capture noisily do `"$do`"",
    "display `"RUN-STATA-RC: `" _rc"
)

$start = Get-Date
$p = Start-Process -FilePath $Stata -ArgumentList "/b", "do", "`"$wrap`"" `
                   -WorkingDirectory $dir -PassThru
$deadline = $start.AddMinutes($TimeoutMinutes)
$status = "timeout"; $rc = $null

# Read with sharing: Stata holds the log open while it runs.
function Read-Log($path) {
    try {
        $fs = [IO.File]::Open($path, 'Open', 'Read', 'ReadWrite')
        $sr = New-Object IO.StreamReader($fs)
        $t = $sr.ReadToEnd(); $sr.Close(); return $t
    } catch { return "" }
}

while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 5
    $text = if (Test-Path $wlog) { Read-Log $wlog } else { "" }
    if ($text -match "(?m)^RUN-STATA-RC: (\d+)") {
        $rc = [int]$Matches[1]
        $status = if ($rc -eq 0) { "ok" } else { "error" }
        break
    }
    if ($p.HasExited) { Start-Sleep -Seconds 2; $status = "exited"; break }
}

if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1
if (Test-Path $wlog) { Move-Item $wlog $log -Force }
Remove-Item $wrap -ErrorAction SilentlyContinue
$mins = [math]::Round(((Get-Date) - $start).TotalMinutes, 1)

switch ($status) {
    "ok"      { Write-Host "OK ($mins min): $log"; exit 0 }
    "error"   {
        Write-Host "STATA ERROR r($rc) after $mins min. Last lines of $log :" -ForegroundColor Red
        Get-Content $log | Select-Object -Last 25 | ForEach-Object { Write-Host "  $_" }
        exit 1
    }
    "exited"  { Write-Host "FAILED: Stata exited without finishing ($log)" -ForegroundColor Red; exit 2 }
    "timeout" { Write-Host "FAILED: timed out after $TimeoutMinutes min ($log)" -ForegroundColor Red; exit 3 }
}
