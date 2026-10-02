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
    [string]   $PaperPath,
    # Review a tree OUTSIDE this repo (e.g. a coauthor's package). Codex still
    # starts in this repo so AGENTS.md and the checklists load; it is granted
    # read access to the whole disk so it can reach $Root. -Target defaults to
    # "full" (there is no git diff to review out there).
    [string]   $Root,
    # Alternative scope file, e.g. review/scopes/<project>.md. Defaults to
    # review/SCOPE.md. Use with -Root so the scope describes the right project.
    [string]   $ScopeFile,
    # Which independent reviewer(s) to run. Both get the IDENTICAL prompt and
    # schema, so their reports can be compared finding by finding.
    #   codex  OpenAI Codex CLI   (read-only sandbox)
    #   agy    Google Antigravity (--mode plan: no edits; --sandbox)
    [ValidateSet('codex','agy','both')]
    [string]   $Reviewer = 'codex'
)

$ErrorActionPreference = 'Stop'

$RepoRoot  = Split-Path -Parent $PSScriptRoot
$ReviewDir = $PSScriptRoot
$Reports   = Join-Path $ReviewDir "reports"
$SchemaF   = Join-Path $ReviewDir "schema\verdict.schema.json"

# --- External root / alternative scope ---------------------------------------
$External = -not [string]::IsNullOrWhiteSpace($Root)
if ($External) {
    if (-not (Test-Path $Root)) { Write-Error "Root not found: $Root"; exit 1 }
    $Root = (Resolve-Path $Root).Path.TrimEnd('\')
    if ($Target -eq "working" -or $Target -eq "staged") { $Target = "full" }
}
if ([string]::IsNullOrWhiteSpace($ScopeFile)) {
    $ScopeRef = "review/SCOPE.md"
} else {
    if (-not (Test-Path $ScopeFile)) { Write-Error "ScopeFile not found: $ScopeFile"; exit 1 }
    $ScopeRef = (Resolve-Path $ScopeFile).Path
}

if (-not (Test-Path $Reports)) { New-Item -ItemType Directory -Force $Reports | Out-Null }

# --- Locate Codex -------------------------------------------------------------
# Use the NATIVE codex.exe, never the npm-generated `codex.ps1` shim. The shim
# pipes through node (`$input | & node ...`), leaving stdio non-TTY, which breaks
# Codex two ways: the interactive TUI refuses to start ("stdout is not a
# terminal"), and `codex exec` cannot spawn ANY subprocess -- it reports
# "CreateProcess ... Rejected ... blocked by policy" and returns an empty review.
# That message looks like a sandbox problem and is not one. See CLAUDE.md.
#
# Nothing here is machine-specific: candidate npm prefixes are discovered, so
# this works on any host with Codex installed.

$prefixes = New-Object System.Collections.Generic.List[string]
foreach ($p in @(
        (Join-Path $env:USERPROFILE "nodejs"),
        (Join-Path $env:APPDATA "npm"),
        "C:\Program Files\nodejs")) {
    if (-not [string]::IsNullOrWhiteSpace($p) -and (Test-Path $p)) { $prefixes.Add($p) }
}
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if ($null -ne $npmCmd) { $prefixes.Add((Split-Path -Parent $npmCmd.Source)) }

# Put a discovered node dir on PATH so `git`/`npm` helpers resolve as expected.
foreach ($p in $prefixes) {
    if ($env:Path -notlike "*$p*") { $env:Path = "$p;" + $env:Path }
}

$CodexExe = $null
foreach ($p in $prefixes) {
    $glob = Join-Path $p "node_modules\@openai\codex\node_modules\@openai\codex-win32-*\vendor\*\bin\codex.exe"
    $hit = Get-Item -Path $glob -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $hit) { $CodexExe = $hit.FullName; break }
}
if ([string]::IsNullOrWhiteSpace($CodexExe)) {
    # Fall back to PATH, but insist on a real .exe -- a .ps1/.cmd hit is the shim.
    $onPath = Get-Command codex -All -ErrorAction SilentlyContinue |
              Where-Object { $_.Source -like "*.exe" } | Select-Object -First 1
    if ($null -ne $onPath) { $CodexExe = $onPath.Source }
}
if ([string]::IsNullOrWhiteSpace($CodexExe) -and $Reviewer -ne 'agy') {
    Write-Error @"
Native codex.exe not found.

Install:  npm install -g @openai/codex
Then:     codex login --device-auth

If `codex` is on PATH but only as codex.ps1/.cmd, that is the npm shim and it
does not work -- locate codex.exe under the package's vendor\ directory.
"@
    exit 1
}

# --- Preflight: authentication ----------------------------------------------
# Without this, an unauthenticated run spends five reconnect attempts before
# failing with a wall of 401s that does not name the actual problem.
$loginRc = 0; $loginState = ""
if ($Reviewer -ne 'agy') {
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $loginState = & $CodexExe login status 2>&1 | Out-String
    $loginRc = $LASTEXITCODE
    $ErrorActionPreference = $prevEAP
}
if ($Reviewer -ne 'agy' -and ($loginRc -ne 0 -or $loginState -match 'Not logged in')) {
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
    "full"    {
        if ($External) {
            $TargetDesc = "the ENTIRE tree at ``$Root``. It is OUTSIDE the repository you start in and is NOT a git repository: read its files directly by absolute path; there is no diff. Start with its README/DOCUMENTATION files, then the code."
        } else {
            $TargetDesc = "the ENTIRE repository. Read the files under CODE/ directly; do not rely on a diff."
        }
    }
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
  2. $ScopeRef
     - what matters in THIS project (if it is an absolute path, read it there)
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
if ($External) { $safeTgt = (Split-Path -Leaf $Root) + "-" + $safeTgt }   # which tree was reviewed
$baseName  = "$stamp-$safeTgt"
$renderer  = Join-Path $ReviewDir "render_report.py"

# Both reviewers receive this exact text. It is saved beside the reports so a
# reader can see precisely what each model was asked.
$promptFile = Join-Path $Reports "$baseName-prompt.md"
[IO.File]::WriteAllText($promptFile, $prompt, [Text.UTF8Encoding]::new($false))

# PowerShell 5.1 wraps a native command's stderr in an ErrorRecord, and under
# $ErrorActionPreference='Stop' that turns ordinary progress messages into a
# terminating error. Native calls below run with it relaxed and are judged by
# exit code.

function Render-Report([string]$json, [string]$md, [string]$tag) {
    if (-not (Test-Path $renderer)) { Write-Host "  Raw JSON: $json" -ForegroundColor Green; return }
    & python $renderer $json $md
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $tag report: review/reports/$(Split-Path -Leaf $md)" -ForegroundColor Green
    } else {
        Write-Warning "$tag rendering failed; raw JSON is at $json"
    }
}

# ---------- Codex -------------------------------------------------------------
function Invoke-CodexReview {
    $jsonOut = Join-Path $Reports "$baseName-codex.json"
    $mdOut   = Join-Path $Reports "$baseName-codex.md"
    Write-Host ""
    Write-Host "  Codex review" -ForegroundColor Cyan
    Write-Host "  target : $Target$(if ($External) { "  (root: $Root)" })"
    Write-Host "  scope  : $($Scope -join ', ')"
    Write-Host "  mode   : read-only sandbox (Codex cannot edit files)"
    Write-Host "  output : review/reports/$baseName-codex.{json,md}"
    Write-Host ""

    $args = @(
        "exec",
        "--cd", $RepoRoot,
        "--sandbox", "read-only",
        # Non-interactive runs have nobody to approve an escalation, so the
        # default OnRequest policy auto-rejects the commands Codex needs to read
        # files ("blocked by policy"). This does NOT widen the sandbox -- it only
        # stops Codex pausing for an approver who is not present.
        "-c", 'approval_policy="never"',
        "--output-schema", $SchemaF,
        "--output-last-message", $jsonOut,
        "--color", "never"
    )
    if (-not [string]::IsNullOrWhiteSpace($Model)) { $args += @("--model", $Model) }
    if ($External) {
        # The read-only sandbox is scoped to the working directory; the external
        # tree lives elsewhere on disk. Reading is widened, writing is not.
        $args += @("-c", 'sandbox_permissions=["disk-full-read-access"]')
    }

    # The prompt goes in on stdin, which avoids Windows command-line length and
    # quoting limits on a long multi-line prompt.
    $prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $rc = 0
    try { $prompt | & $CodexExe @args; $rc = $LASTEXITCODE }
    catch { Write-Warning "codex invocation failed: $($_.Exception.Message)"; $rc = 1 }
    finally { $ErrorActionPreference = $prevEAP }

    if (-not (Test-Path $jsonOut)) {
        Write-Warning "Codex produced no output file (exit $rc). If it said 'Not logged in', run: codex login --device-auth"
        return $false
    }
    if ($rc -ne 0) { Write-Warning "codex exited with code $rc but wrote a report; rendering it." }
    Render-Report $jsonOut $mdOut "Codex"
    return $true
}

# ---------- Antigravity (agy) -----------------------------------------------
function Invoke-AgyReview {
    $agy = Join-Path $env:LOCALAPPDATA "agy\bin\agy.exe"
    if (-not (Test-Path $agy)) {
        $cmd = Get-Command agy -ErrorAction SilentlyContinue
        if ($null -ne $cmd) { $agy = $cmd.Source }
    }
    if (-not (Test-Path $agy)) {
        Write-Warning "Antigravity CLI (agy) not found. Install: irm https://antigravity.google/cli/install.ps1 | iex"
        return $false
    }
    $rawOut  = Join-Path $Reports "$baseName-agy.raw.json"
    $jsonOut = Join-Path $Reports "$baseName-agy.json"
    $mdOut   = Join-Path $Reports "$baseName-agy.md"
    Write-Host ""
    Write-Host "  Antigravity review" -ForegroundColor Cyan
    Write-Host "  target : $Target$(if ($External) { "  (root: $Root)" })"
    Write-Host "  scope  : $($Scope -join ', ')"
    Write-Host "  mode   : --mode plan (edit tools disabled); commands governed by settings.json allow/deny lists"
    Write-Host "  output : review/reports/$baseName-agy.{json,md}"
    Write-Host ""

    # agy takes the prompt on the command line; a long one hits Windows limits,
    # so it gets a one-line pointer to the saved prompt file instead.
    $pointer = "Read and follow every instruction in the file $promptFile. It tells you what to read, what to review, the rules, and the output format. Then return only the JSON object."
    # No --sandbox: agy's terminal sandbox cannot execute commands on this host
    # (Windows Server 2019) and the run dies with exit 2 and no output. Safety
    # comes from --mode plan (edit tools disabled) plus the allow/deny lists in
    # ~/.gemini/antigravity-cli/settings.json -- see review/agy-settings.json.
    $agyModel = if ([string]::IsNullOrWhiteSpace($Model)) { "gemini-3.1-pro-high" } else { $Model }
    $agyLog   = Join-Path $Reports "$baseName-agy.log"
    $args = @("-p", $pointer, "--mode", "plan",
              "--json-schema", $SchemaF, "--output-format", "json",
              "--model", $agyModel, "--effort", "high",
              "--print-timeout", "45m", "--log-file", $agyLog)
    if ($External) { $args += @("--add-dir", $Root) }
    if (-not [string]::IsNullOrWhiteSpace($PaperPath) -and (Test-Path $PaperPath)) {
        $args += @("--add-dir", (Split-Path -Parent (Resolve-Path $PaperPath).Path))
    }

    $prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $rc = 0; $out = ""
    try { $out = (& $agy @args 2>&1 | Out-String -Width 1000000); $rc = $LASTEXITCODE }
    catch { Write-Warning "agy invocation failed: $($_.Exception.Message)"; $rc = 1 }
    finally { $ErrorActionPreference = $prevEAP }
    [IO.File]::WriteAllText($rawOut, $out, [Text.UTF8Encoding]::new($false))

    # The verdict is the `structured_output` object of agy's JSON envelope. The
    # `response` string beside it carries extra keys and must not be used.
    $py = @"
import io, json, sys
raw = io.open(r'''$rawOut''', encoding='utf-8').read()
start = raw.find('{')
env = json.loads(raw[start:]) if start >= 0 else {}
so = env.get('structured_output')
if not so:
    sys.stderr.write('agy status=%s; no structured_output\n' % env.get('status'))
    sys.exit(1)
io.open(r'''$jsonOut''', 'w', encoding='utf-8').write(json.dumps(so, indent=2, ensure_ascii=False))
u = env.get('usage', {})
print('agy ok: %s turns, %s tokens' % (env.get('num_turns'), u.get('total_tokens')))
"@
    $py | & python -
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $jsonOut)) {
        Write-Warning "agy produced no usable verdict (exit $rc). Raw envelope: $rawOut"
        return $false
    }
    Render-Report $jsonOut $mdOut "Antigravity"
    return $true
}

# ---------- Dispatch ----------------------------------------------------------
$ok = @()
if ($Reviewer -eq 'codex' -or $Reviewer -eq 'both') { $ok += ,@('codex', (Invoke-CodexReview)) }
if ($Reviewer -eq 'agy'   -or $Reviewer -eq 'both') { $ok += ,@('agy',   (Invoke-AgyReview)) }

Write-Host ""
Write-Host "  Prompt used by every reviewer: review/reports/$baseName-prompt.md" -ForegroundColor DarkGray
$failed = @($ok | Where-Object { -not $_[1] } | ForEach-Object { $_[0] })
if ($failed.Count -gt 0) { Write-Warning "Reviewer(s) without a report: $($failed -join ', ')"; exit 1 }
