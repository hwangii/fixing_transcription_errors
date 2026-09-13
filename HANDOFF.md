# HANDOFF — state as of 2026-09-13

Written for continuing this work **on the server where the data lives**. Read
this first, then `CLAUDE.md`.

## What exists now

A cross-model review system: Claude Code writes, **Codex CLI (OpenAI) reviews**.
Codex runs read-only, applies checklists, and returns findings against a JSON
schema. Branch: `add-codex-review-infrastructure`.

```
AGENTS.md              orientation Codex reads automatically
CLAUDE.md              orientation Claude reads automatically + hard-won gotchas
review/
  PROTOCOL.md          the loop, severity + confidence vocabulary (project-agnostic)
  SCOPE.md             what to check in THIS project (rewrite this per project)
  checklists/          one file per dimension: correctness, claims-vs-code,
                       replication, identification
  schema/              forces structured findings
  Run-Review.ps1       the launcher
  render_report.py     JSON -> readable markdown
  reports/             output, and the audit trail
```

`Run-Review.ps1` discovers Codex itself and hardcodes no user paths, so it
should work unchanged on the new host.

## Setup on the new server

1. **Node 22+.** If there is no admin, extract the official zip into the user
   profile and add it to the **user** PATH. `Expand-Archive` fails on long
   paths; use `[System.IO.Compression.ZipFile]::ExtractToDirectory` to a short
   path.
2. `npm install -g @openai/codex`
3. `codex login --device-auth` — ChatGPT **Business/Edu** account. A workspace
   admin may need to enable Codex; if sign-in fails, check that before
   suspecting the install.
4. **Do not call `codex` from the npm shim.** See the warning below; it is the
   single biggest time sink in this setup.

Then:

```powershell
.\review\Run-Review.ps1 -Target full
.\review\Run-Review.ps1 -Target "HEAD~3..HEAD" -Scope correctness
.\review\Run-Review.ps1 -Target full -Scope claims-vs-code -PaperPath "<draft.tex>"
```

## Open items, most useful first

### 1. Size the blank-string bug (needs the data — that's why you're moving)

Both reviews flagged this, and the automated one rated it **major**. In
`CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do`, line 39 admits a
record when *either* name field is non-empty, but lines 43-55 require *both*
components to match — and Stata scores `"" == ""` as true. A surname-only
record is therefore counted as a full-name match.

```stata
count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="")
count if (namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="") ///
    & (namefrst=="" | namelast=="" | fs_namefrst=="" | fs_namelast=="")
```

Second over first is the share of the denominator exposed. Negligible means a
footnote; otherwise every agreement rate this script reports moves, and not
symmetrically across Ancestry and FamilySearch if their blank rates differ.

### 2. Verify the Hawaii restoration actually runs

`"hi"` was uncommented in the state loop (it was the only commented-out state).
**This is untested — the data was not on the machine where the edit was made.**
The loop does `cd `stabb''`; if there is no `hi` directory, `cd` fails, the
matching `cd ..` never runs, and every *subsequent* state then resolves from the
wrong working directory. That corrupts the whole run, not just Hawaii. Check the
directory exists before trusting any output.

Consider making the loop fail loudly instead of drifting:

```stata
capture cd `"`stabb'"';
if _rc {; display as error "missing state dir: `stabb'"; exit _rc; };
```

Also: **Alaska is absent entirely** from the list, not commented out. And
Hawaii and Alaska were *territories* in 1940 — if that was the original reason
for excluding them, restoring Hawaii is a substantive choice about which
population the paper describes, and belongs in the data section rather than in
code.

### 3. Run the dimensions nothing has touched

Only `correctness` has been run, against one file. `claims-vs-code` is the one
that most repays a submission, and it needs the draft via `-PaperPath`.
`replication` will have plenty to say about the hardcoded `D:\Dropbox` and `F:\`
paths and the `V2`/`V3`/`_nber`/`_SSHA2025` variants.

### 4. Open the pull request

Branch is pushed; the PR was never created. `gh` is installed on the old
machine but was never authenticated. Either run `gh auth login` and
`gh pr create`, or open it in a browser from the compare URL.

## Two warnings that cost real time

**The npm shim.** `npm i -g @openai/codex` puts `codex.ps1` on PATH; it pipes
through node and leaves stdio non-TTY. The interactive TUI then refuses to start
("stdout is not a terminal"), and `codex exec` cannot spawn any subprocess,
reporting `CreateProcess ... Rejected ... blocked by policy` for powershell,
cmd, bash, rg and git alike — so it reads nothing and returns an **empty
review**. This looks exactly like a sandbox or OS-support problem. It is not.
Call the native `codex.exe` under the package's `vendor\...\bin\`. Hours went
into chasing this as an OS issue on Windows Server 2019; do not repeat that.

**Codex is confidently wrong about Stata.** It reported, as `major` /
`verified`, that `display `denom', `numer1', ...` at line 62 was invalid syntax
printing nothing. Stata/MP 15.1 says rc=0 and prints all five values: a comma in
`display` separates directives and adds a space, and the commas are load-bearing
(without them the values run together). That finding was **rebutted**. Verify
Stata-specific findings against Stata before acting — batch mode on Stata 15 is
`/b`, not `/e`.

And when reading any report: an empty findings list beside a populated
`review_limits` means *could not review*, **not** *passed*.
