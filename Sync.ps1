<#
.SYNOPSIS
  Safe git sync for working across two machines.

.DESCRIPTION
  Wraps the three git commands that matter, and refuses to do anything
  destructive. Run with no arguments to find out where you stand.

    .\Sync.ps1                        where am I, and what should I do
    .\Sync.ps1 -Pull                  get the other machine's work (safe)
    .\Sync.ps1 -Push -Message "..."   commit my work and send it

  -Pull uses --ff-only: it will never create a surprise merge. If the two
  machines have genuinely diverged it stops and tells you, rather than
  guessing.
#>

[CmdletBinding()]
param(
    [switch] $Pull,
    [switch] $Push,
    [string] $Message
)

$ErrorActionPreference = 'Continue'
Set-Location $PSScriptRoot

function Line($t, $c = "Gray") { Write-Host "  $t" -ForegroundColor $c }

$branch = (& git rev-parse --abbrev-ref HEAD 2>$null).Trim()
& git fetch -q 2>$null

$dirty    = @(& git status --porcelain 2>$null | Where-Object { $_ -notmatch '^\?\?' })
$untracked= @(& git status --porcelain 2>$null | Where-Object { $_ -match '^\?\?' })
$ahead    = @(& git log --oneline "origin/$branch..HEAD" 2>$null).Count
$behind   = @(& git log --oneline "HEAD..origin/$branch" 2>$null).Count

Write-Host ""
Line "branch    : $branch" "Cyan"
Line "uncommitted: $($dirty.Count) changed, $($untracked.Count) untracked"
Line "ahead     : $ahead commit(s) this machine has that the server does not"
Line "behind    : $behind commit(s) the server has that this machine does not"
Write-Host ""

# ---------- PULL ----------
if ($Pull) {
    if ($dirty.Count -gt 0) {
        Line "Stopping: you have uncommitted changes." "Yellow"
        Line "Commit them first:  .\Sync.ps1 -Push -Message 'what you did'"
        exit 1
    }
    if ($ahead -gt 0 -and $behind -gt 0) {
        Line "Stopping: both machines have new commits (diverged)." "Yellow"
        Line "Nothing is lost. Ask Claude to merge them - do not force anything."
        exit 1
    }
    if ($behind -eq 0) { Line "Already up to date." "Green"; exit 0 }
    & git pull --ff-only
    if ($LASTEXITCODE -eq 0) { Line "Pulled $behind commit(s)." "Green" } else { Line "Pull failed - ask Claude." "Yellow" }
    exit $LASTEXITCODE
}

# ---------- PUSH ----------
if ($Push) {
    if ($dirty.Count -eq 0 -and $ahead -eq 0) { Line "Nothing to send." "Green"; exit 0 }
    if ($dirty.Count -gt 0) {
        if ([string]::IsNullOrWhiteSpace($Message)) {
            Line "Need a message:  .\Sync.ps1 -Push -Message 'what you did'" "Yellow"
            exit 1
        }
        & git add -u                      # tracked files only; never sweeps in data
        & git commit -m $Message | Out-Null
        Line "Committed: $Message" "Green"
    }
    if ($behind -gt 0) {
        Line "The server has $behind newer commit(s). Pull first:" "Yellow"
        Line "  .\Sync.ps1 -Pull"
        exit 1
    }
    & git push
    if ($LASTEXITCODE -eq 0) { Line "Pushed." "Green" } else { Line "Push failed - ask Claude." "Yellow" }
    exit $LASTEXITCODE
}

# ---------- STATUS / ADVICE ----------
if ($behind -gt 0 -and $ahead -gt 0) {
    Line "DIVERGED - both machines have new work." "Yellow"
    Line "Nothing is lost. Ask Claude to merge. Do not force anything."
} elseif ($behind -gt 0) {
    Line "The other machine has work you don't. Run:  .\Sync.ps1 -Pull" "Cyan"
} elseif ($dirty.Count -gt 0 -or $ahead -gt 0) {
    Line "You have work the other machine can't see. Run:" "Cyan"
    Line "  .\Sync.ps1 -Push -Message 'what you did'"
} else {
    Line "In sync. Safe to start working." "Green"
}
Write-Host ""
