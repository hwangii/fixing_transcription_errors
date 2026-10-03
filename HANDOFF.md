# HANDOFF — state as of 2026-09-13

Written for continuing this work on **either** of the two servers. Each holds a
different and equally important dataset, so analysis runs on both and both edit
`CODE/`. Read this first, then `CLAUDE.md`.

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

### 1. Size the blank-string bug (needs the 1940 transcription data)

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
**This is untested — the relevant data was not on the machine where the edit was
made.**
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

Done 2026-10-03: https://github.com/hwangii/fixing_transcription_errors/pull/1.
`gh` is now authenticated on this server. Through Claude Code's `!` prefix,
bare `gh auth login` hangs waiting for Enter; use
`echo "" | gh auth login --hostname github.com --git-protocol https --web`
and enter the printed code at github.com/login/device.

### 5. Act on the review of Deaglan's package (2026-10-02)

His code is at `F:\Deaglan\Census_Transcriptions\` (not a git repo; see
`review/scopes/deaglan-census-transcriptions.md`). Antigravity reviewed it
with `Run-Review.ps1 -Reviewer agy -Root ... -ScopeFile ...`; every finding was
verified against source by Claude — see
`review/reports/2026-10-02_033757-Census_Transcriptions-full-agy.md`. The
Codex pass on the identical prompt is done and dispositioned:
`review/reports/2026-10-02_150627-Census_Transcriptions-full-codex.md`, with a
side-by-side in `2026-10-02-Census_Transcriptions-comparison.md` (made by
`review/compare_reviews.py`). Four issues shared, four unique to each.

What it means for the draft, in order:

- **Do not use `deaglan_results/linkage_table_newlinks*.tex`.** Retired
  script, different dedup rule, match rates of 116–119%. The current tables
  are `output/tables/linkage_table_hlink*.tex` and `linkage_table_abe_jw*.tex`
  in his package; the mortality table was never copied to Overleaf.
- **"Directly Contradicted" undercounts wrong links.** The truth check is
  1940-side only (`02_hlink/linkage_analysis_newlinks.do:295`); a wrong link
  whose 1940 record is outside the truth set is called "Unverifiable". Do not
  describe Contradicted as a false-positive rate without saying so, or ask for
  a two-sided classification.
- **"Match Rate" is pairs ÷ persons, not the share of people linked**
  (`:270`; the link file is not one-to-one). Either describe it as such or
  have it recomputed on `first40 == 1` — the flag already exists in
  `build_matched_links.do:220`.
- **Three tables, three denominators**: men-only census (ABE/JW), men and
  women (HLINK), BUNMD death records (mortality). Captions say "all men" for
  both census tables; the HLINK one is wrong and his §6 admits it. Never
  present the three rates as one series.
- **Age cutoff is 8 in his code, 10 in the draft.** Decision taken: the draft
  follows the code. But the balance table's own script
  (`CODE/munir_figures_for_nber.do:82,294,630`) uses 10, so the draft must
  state each table's cutoff or the balance table must be regenerated at 8.
  Also: `keep if age >= 8` retains *missing* ages (`:182`).
- **The package's "byte-identical reproduction" claim is unverified** — the
  master log has no comparison step. Either reproduce it with a `cf`/checksum
  script or do not repeat the claim in the paper.
- **HLINK numerator counts links outside the denominator population**
  (Codex #1). Small — full rates 58.08/59.55 → 58.06/59.52 — but wrong by
  construction; enforce denominator membership before the table is used.
- **"Added mortality links are more accurate" is unsupported** (Codex #5).
  `DOCUMENTATION.md:213-214` draws it from agreement over *all* links; do not
  repeat it without a retained/added/removed split.
- **Mortality numerator has no sex/birth-year filter** while its denominator
  does (Codex #3). Magnitude needs the data.

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
