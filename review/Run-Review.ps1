<#
.SYNOPSIS
  Run an independent Codex review of work in this repository.

.DESCRIPTION
  Launches Codex non-interactively in a READ-ONLY sandbox. Codex cannot edit
  files; it reads the repo, applies the checklists named in SCOPE.md, and returns
  findings against review/schema/verdict.schema.json.

  Reports land in review/reports/ as both .json (structured) and .md (readable).

.PARAMETER Target
  What to review:
    working   (default) uncommitted changes vs HEAD
    staged    staged changes only
    full      the entire repository, not a diff
    <range>   any git range, e.g. "HEAD~3..HEAD"
    <path>    a file or directory, e.g. "CODE/clean_ASV5_nber.do"

.PARAMETER Scope
  Dimensions to review. Defaults to all active dimensions in SCOPE.md.
  Valid: correctness, claims-vs-code, replication, identification

.PARAMETER Model
  Override the Codex model.

.PARAMETER PaperPath
  Optional path to the paper draft (.tex/.md/.txt), inside or outside the repo.
  Required for meaningful claims-vs-code review.

.EXAMPLE
  .\review\Run-Review.ps1
.EXAMPLE
  .\review\Run-Review.ps1 -Target "HEAD~3..HEAD" -Scope correctness,replication
.EXAMPLE
  .\review\Run-Review.ps1 -Target full -PaperPath "D:\Dropbox\paper\draft.tex"
#>

[CmdletBinding()]
param(
    [string]   $Target = "working",
    [string[]] $Scope,
    [string]   $Model,
    [string]   $PaperPath
)

$ErrorActionPreference = 'Stop'

$RepoRoot  = Split-Path -Parent $PSScriptRoot
$ReviewDir = $PSScriptRoot
$Reports   = Join-Path $ReviewDir "reports"
$SchemaF   = Join-Path $ReviewDir "schema\verdict.schema.json"

if (-not (Test-Path $Reports)) { New-Item -ItemType Directory -Force $Reports | Out-Null }

# --- Node/Codex on PATH (portable install lives in the user profile) ----------
$NodeDir = "C:\Users\hwangii\nodejs"
if (Test-Path $NodeDir) {
    if ($env:Path -notlike "*$NodeDir*") { $env:Path = "$NodeDir;" + $env:Path }
}
$codex = Get-Command codex -ErrorAction SilentlyContinue
if ($null -eq $codex) {
    Write-Error "codex not found on PATH. Install: npm install -g @openai/codex"
    exit 1
}

# --- Preflight: authentication ----------------------------------------------
# Without this, an unauthenticated run spends five reconnect attempts before
# failing with a wall of 401s that does not name the actual problem.
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$loginState = & codex login status 2>&1 | Out-String
$loginRc = $LASTEXITCODE
$ErrorActionPreference = $prevEAP
if ($loginRc -ne 0 -or $loginState -match 'Not logged in') {
    Write-Host ""
    Write-Host "  Codex is not logged in." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Sign in with your ChatGPT account (Business/Edu works if your"
    Write-Host "  workspace admin has enabled Codex):"
    Write-Host ""
    Write-Host "      codex login --device-auth" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  --device-auth prints a code to enter on any device with a browser,"
    Write-Host "  which is the right flow on a server with no usable browser."
    Write-Host ""
    exit 1
}

# --- Scope -------------------------------------------------------------------
$AllDims = @("correctness","claims-vs-code","replication","identification")
if ($null -eq $Scope -or $Scope.Count -eq 0) { $Scope = $AllDims }
foreach ($d in $Scope) {
    if ($AllDims -notcontains $d) {
        Write-Error "Unknown scope '$d'. Valid: $($AllDims -join ', ')"
        exit 1
    }
}

# --- Describe the target -----------------------------------------------------
switch ($Target) {
    "working" { $TargetDesc = "the uncommitted changes in the working tree. Run ``git --no-pager diff HEAD`` to see them." }
    "staged"  { $TargetDesc = "the staged changes. Run ``git --no-pager diff --cached`` to see them." }
    "full"    { $TargetDesc = "the ENTIRE repository. Read the files under CODE/ directly; do not rely on a diff." }
    default   {
        if ($Target -match '\.\.') {
            $TargetDesc = "the commit range ``$Target``. Run ``git --no-pager diff $Target`` to see the changes, and ``git --no-pager log --oneline $Target`` for context."
        } else {
            $TargetDesc = "the file(s) at ``$Target``. Read them in full."
        }
    }
}

# Warn on an empty working-tree diff before spending a review on nothing.
if ($Target -eq "working") {
    Push-Location $RepoRoot
    $diffStat = & git --no-pager diff HEAD --stat 2>$null | Out-String
    Pop-Location
    if ([string]::IsNullOrWhiteSpace($diffStat)) {
        Write-Warning "No uncommitted changes. Use -Target full, or a commit range like -Target 'HEAD~3..HEAD'."
        exit 0
    }
}

$paperLine = "No paper draft was supplied. Review code only; for claims-vs-code, report that the draft was unavailable in review_limits rather than inventing claims."
if (-not [string]::IsNullOrWhiteSpace($PaperPath)) {
    if (Test-Path $PaperPath) {
        $paperLine = "The paper draft is at ``$PaperPath``. Read it and check its claims and numbers against the code."
    } else {
        Write-Warning "PaperPath '$PaperPath' not found; continuing without it."
    }
}

$checklistLines = ($Scope | ForEach-Object { "  - $_  ->  review/checklists/$_.md" }) -join "`n"

$prompt = @"
You are an independent reviewer. You did not write this code and you have no
stake in it being correct. Your value here is finding what is wrong.

Read these first, in order:
  1. AGENTS.md              - what this project is and the domain traps
  2. review/SCOPE.md        - what matters in THIS project
  3. The checklists below, one per active dimension.

Active dimensions for this run:
$checklistLines

REVIEW TARGET: $TargetDesc

PAPER: $paperLine

Reading files: the repository is readable and commands work. If any single
command is rejected, try another form rather than concluding you cannot see the
repository - and never fall back to searching the web for the source, which
would review a different version of the file than the one on disk.

Rules:
- You are in a read-only sandbox. Do not attempt to edit anything.
- Cite every finding as path:line. A finding without a location is not a finding.
- Mark confidence honestly. You cannot see the data and you cannot run the Stata
  pipeline, so most runtime claims are inference from source - say so.
- Stata semantics are the point of this review: missing values exceed any number,
  "" == "" is true, merges without assert hide mismatches. Prioritise anything
  that yields a wrong number without an error.
- Do not pad the findings list. Three real defects beat twenty stylistic notes.
  Populate verified_clean with what you checked and found sound - a short
  findings list is only credible alongside evidence of what was examined.
- The author is submitting within months. Rank by what changes a number or a
  claim, not by what would make the code prettier.

Return ONLY JSON conforming to the provided output schema.
"@

# --- Run ---------------------------------------------------------------------
$stamp     = Get-Date -Format "yyyy-MM-dd_HHmmss"
$safeTgt   = ($Target -replace '[^A-Za-z0-9._-]','_')
$baseName  = "$stamp-$safeTgt"
$jsonOut   = Join-Path $Reports "$baseName.json"
$mdOut     = Join-Path $Reports "$baseName.md"

Write-Host ""
Write-Host "  Codex review" -ForegroundColor Cyan
Write-Host "  target : $Target"
Write-Host "  scope  : $($Scope -join ', ')"
Write-Host "  mode   : read-only sandbox (Codex cannot edit files)"
Write-Host "  output : review/reports/$baseName.{json,md}"
Write-Host ""
Write-Host "  Running. This takes a few minutes on a large target." -ForegroundColor DarkGray
Write-Host ""

$codexArgs = @(
    "exec",
    "--cd", $RepoRoot,
    "--sandbox", "read-only",
    # Non-interactive runs have nobody to approve an escalation, so the default
    # OnRequest policy auto-rejects the commands Codex needs to read files
    # ("blocked by policy"). This does NOT widen the sandbox -- read-only still
    # applies; it only stops Codex pausing for an approver who is not present.
    "-c", 'approval_policy="never"',
    "--output-schema", $SchemaF,
    "--output-last-message", $jsonOut,
    "--color", "never"
)
if (-not [string]::IsNullOrWhiteSpace($Model)) { $codexArgs += @("--model", $Model) }

# The prompt goes in on stdin: `codex exec` reads instructions from stdin when
# piped, which avoids Windows command-line length and quoting limits on a long
# multi-line prompt.
# PowerShell 5.1 wraps a native command's stderr in an ErrorRecord, and under
# $ErrorActionPreference='Stop' that turns Codex's ordinary progress messages
# ("Reading prompt from stdin...") into a terminating error. Relax it here and
# judge success by the exit code instead.
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$rc = 0
try {
    $prompt | & codex @codexArgs
    $rc = $LASTEXITCODE
} catch {
    Write-Warning "codex invocation failed: $($_.Exception.Message)"
    $rc = 1
} finally {
    $ErrorActionPreference = $prevEAP
}

if ($rc -ne 0) {
    Write-Warning "codex exited with code $rc."
    if (-not (Test-Path $jsonOut)) {
        Write-Error "No report produced. If this says 'Not logged in', run: codex login --device-auth"
        exit $rc
    }
}

if (-not (Test-Path $jsonOut)) {
    Write-Error "Codex produced no output file."
    exit 1
}

# --- Render markdown ---------------------------------------------------------
$renderer = Join-Path $ReviewDir "render_report.py"
if (Test-Path $renderer) {
    & python $renderer $jsonOut $mdOut
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "  Report: review/reports/$baseName.md" -ForegroundColor Green
    } else {
        Write-Warning "Rendering failed; raw JSON is at review/reports/$baseName.json"
    }
} else {
    Write-Host "  Raw JSON: review/reports/$baseName.json" -ForegroundColor Green
}
