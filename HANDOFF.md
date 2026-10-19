# HANDOFF — state as of 2026-10-18

Written for continuing this work on **either** of the two servers. Each holds a
different and equally important dataset, so analysis runs on both and both edit
`CODE/`. Read this first, then `CLAUDE.md`.

## Machine B replication — the next job, to be done on machine B (written 2026-10-18)

> **DONE 2026-10-19 on machine B (`ARTS-ECON-SHSRV`).** Steps 1-5 are
> committed (`83d8b98` unmodified copy, `c49e135` `$LCODE` repoint across
> all 33 scripts, agreed with the author, `6ac58bb`, `8a9b469`, `e366bd2`).
> The full run (`.\replication\Run-MachineB.ps1`, 234 min) **reproduced all
> five of Deaglan's tables byte-identical** (SHA-256) to
> `deaglan_results/current/`, so his "byte-identical" claim is now verified.
> `figures/deaglan_*.tex` did not change. New results files:
> `replication/results/linkage_{abe_jw,hlink}.tex`. The four denominators
> and 58.06 / 59.52 all match the draft. The checker's only failures are the
> five known draft errors in the 2026-10-15 table below.
> Still open: the Codex + Antigravity review of this work, and the fixes
> listed under "Reproduce first, fix afterwards" (each needs sign-off).

**Decided 2026-10-18 by the author:** Deaglan's code and data on machine B
(`F:\Deaglan\Census_Transcriptions\`) are now ours to work on, and he is not
expected to edit them again. The copy of his code in this repo becomes the
canonical one. His folder on F: then holds data only.

**Goal:** Tables 5-8, and every draft number quoted from them, reproduce from a
single command on B, as machine A's already do (§ below, 2026-10-15). Today
the draft's `figures/deaglan_*.tex` were extracted from
`deaglan_results/current/` **by hand**, and his package's "all five tables
verified byte-identical" claim has never been checked.

Do these steps in order and commit after each one.

1. **Sync first.** Run `.\Sync.ps1 -Pull` here and `git pull` in B's paper repo
   (`F:\github_repos\6638fa0fd89fbec05130caeb`, per
   `review/scopes/deaglan-census-transcriptions.md`; confirm it). Read
   `replication/README.md`, then this repo's copy of the review of his
   package (item 6 below).
2. **Bring his code into the repo as `LINKAGE/`.** Copy code only: `code/`, his
   `README.md`, `DOCUMENTATION.md` and `LINKAGE_README.md`. Leave out data,
   `output/` and logs.
   - `Sync.ps1` commits with `git add -u`, which never picks up new files. So
     run `git add LINKAGE/` explicitly, then read `git status` and
     `git diff --cached --stat` before committing.
   - Nothing in `LINKAGE/` may be a `.dta`, `.csv`, or anything bigger than a
     script.
   - Commit the copy **unmodified** first, so the history shows exactly what
     he handed over.
   - Then repoint `code/shared/paths.do`. Code is read from the repo; data is
     still read from `F:\Deaglan\Census_Transcriptions` through `$ROOT`.
     That is the one path change agreed in advance; ask before changing any
     others.
3. **Add machine B to the package.**
   - A hostname block in `replication/config.do`. Machine A's block is the
     model; add a global for his data root, e.g. `REP_LINK`.
   - A `[machines.<B hostname>] paper_repo = ...` entry in
     `replication/claims.toml`.
4. **`replication/run_machineB.do` and `replication/Run-MachineB.ps1`**, built
   from the machine-A pair:
   - Set `version 15.1` (or whatever B has; record it in the README).
   - Preflight every input file his scripts read.
   - Run `LINKAGE/code/00_run_all_tables.do`.
   - Then run a new extraction script, written in Python, that writes the
     `tabular` from his output tables into the paper repo's
     `figures/deaglan_{abe_jw,abe_jw_restricted,hlink,hlink_restricted}.tex`
     in exactly today's format. Before the first real run, test the script
     against today's committed `deaglan_results/current/` files: it must
     reproduce today's four `figures/` files byte-for-byte.
   - Then run `check_claims.py`, and `git status` / `git diff` in both repos.
   - Exactly as on A, a changed `figures/deaglan_*.tex` means the table did
     **not** reproduce. That run is the first real check of his
     byte-identical claim.
5. **Script the numbers that are now unchecked.** Add `repnum` calls to his
   scripts so that they write `replication/results/linkage_*.tex`. Then point
   these claims in `claims.toml` at the new keys:
   - `deaglan-denom-abe`: 57,589,273
   - `deaglan-denom-abe-disc`: 15,003,537
   - `deaglan-denom-hlink`: 115,030,746
   - `deaglan-denom-hlink-disc`: 30,754,309
   - `deaglan-hlink-restriction`: 58.06 and 59.52. These came from a Codex
     review, not from any script.

   Each comes from `PROVENANCE.md` Q3 and Q5 in the paper repo's
   `deaglan_results/current/`. Machine A never writes a `linkage_*.tex`, so
   the two machines cannot collide on a results file.
6. **Run the package, then push both repos.** Push the paper repo only after
   asking: its remote is Overleaf itself, so coauthors see the push at once.
   Machine A then pulls, and one `check_claims.py` run covers the whole draft.

**Reproduce first, fix afterwards.** The review of his package (item 6) found
real problems:
- the HLINK numerator counts links outside its denominator;
- `keep if age >= 8` keeps missing ages;
- "Directly Contradicted" is one-sided;
- the mortality numerator is missing the filter its denominator has.

Do **not** fix any of these during steps 2-5. First get his tables to
reproduce **exactly as they are**, so the package proves what the draft
currently says. Then fix them one at a time, each as its own commit, and
let the rerun and the checker show what each fix changes. A fix that moves a
number is a draft change, and needs the author's sign-off.

**Traps from machine A that will hit his Stata code too:**
- Launch Stata batch runs from PowerShell, never Git Bash. Git Bash rewrites
  `/b` into a path.
- `Run-Stata.ps1` is the only reliable way to tell a batch run failed. A failed
  batch run stops its log without writing `r()`, and the Stata process does
  not exit.
- Any log that a script reads back as data has to be written at
  `set linesize 255`. In batch mode Stata wraps the log at 80 characters,
  which splits each row and breaks the import. Look for `infile`, `import`
  or `insheet` reading a `.log` or `.smcl`.
- `shell` is ignored in batch mode. Globals survive `clear all`; timers do not.
  A `version` set inside a do-file reverts when that do-file ends.
- Stata PDFs can differ only in their embedded font bytes. Use
  `compare_figures.py` before calling a figure not reproduced.

When B's work is done, run Codex and Antigravity on it
(`review/Run-Review.ps1`), and disposition every finding.

## Session of 2026-10-15 — replication package

**`replication/` exists; start with its README.** Every number and exhibit in
the draft is registered in `replication/claims.toml` against its source, and
`python replication\check_claims.py` checks the draft against them. It runs
on either machine and never edits the draft. Machine A's whole pipeline reruns
with `.\replication\Run-MachineA.ps1`: 130 min for a full run, 33 with
`-SkipRebuild`.

**Full run, 2026-10-15:**
- Tables 2-4 and Figure 4 reproduce byte-identical.
- Figure 3's drawing is identical; only its embedded font bytes differ.
- Every in-text number reproduces.
- 41 claims match. 19 have no producing code (the ML pipeline: Table 1,
  training counts, GPU benchmark; also Deaglan's denominators).

**Wrong in the draft, not yet edited**, per `replication/claims_report.md`:

| line | says | should be | why |
|---|---|---|---|
| `:101`, `:726` | 1.4% | 1.6% | computed from the rounded 28.1 / 27.7; the unrounded value is 1.55 |
| `:719` | 42% | 43% | the 95th percentile is 42.53 |
| `:577` | 0.41 | 0.40 | 70,375 / 17,391,446 |
| `:575`, `:577` | "ABE" | JW and ABE | mislabels a Jaro-Winkler column |
| `:755-756`, `:770` | gains "by most for groups that were previously least well covered" | — | contradicted by the draft's own numbers: non-white +6.4 vs white +7.9; no schooling +7.0 vs all +8 |

**Next: move the draft onto generated numbers, section by section** (agreed
2026-10-15). The results files must first move into the paper repo so
Overleaf can `\input` them. Two traps found today:
- Stata batch mode silently mis-imports any log it reads back as data unless
  the log is written at `set linesize 255`.
- `Run-Stata.ps1` is the only reliable way to tell whether a batch run failed.

## Where we are — session of 2026-10-14

**The two repos.** Code is here. The paper is a *separate* clone of the
Overleaf project at **`D:\repos\6638fa0fd89fbec05130caeb`** — the draft is
`DHTS-2026-10-12.tex` and several do-files write their exhibits straight into
its `figures/`. Line references below like `DHTS-2026-10-12.tex:66` mean that
repo, not this one. Both repos are pushed and level with their servers.

**The draft is readable right now.** `DHTS-2026-10-12.pdf`, 34 pages, built
2026-10-14 00:33 and committed in `5424c43`. Verified current by extracting
the PDF's text: every statistic edit is in it and no superseded number
survives, and the LaTeX log has no undefined references or citations.

**What the statistics audit changed** (draft repo, `d4bd647`, `e96af4f`,
`0baf6b2`, `5424c43`, all pushed):

| was | now |
|---|---|
| transcriber disagreement "approximately 30 percent" | 28.3 percent |
| model agrees: 11% Ancestry / 47% FamilySearch (Rhode-Island-era) | 14% / 52%, all-states, four-way partition of 35.1M discordant records |
| non-white / white baseline linking 18.3% / 27.1% | 11.0% / 24.1%, gains 6.4% / 7.9% |
| foreign-born +14.5%, no schooling +9.2%, non-English +14.5% | +8.1%, +7.0%, +7.8%, each with its baseline stated |
| inmates "decreased slightly (-1%)" | gain of 7.3% off a 15.0% baseline |

**What this session did here**, besides reconstructing the above from git after
a restart lost the conversation: repaired four `.gitignore` rules that silently
matched nothing because they carried inline `#` comments (`*.log`, `*.smcl`,
`*.stswap`, `*.gph`), added `!review/reports/*.log` so the reviewer audit trail
is not swallowed by the now-working rule, and refreshed items 1, 3 and 4 below.
Commits `dcf7f4e`, `2abfd51`, and the one that added this section.

**Next, in order.** Item 4 is the live one and the draft is waiting on a
decision, not on work:

1. **Decide how to handle the transcription-quality claims** (item 4). Reword
   to agreement + linkage outcomes, which is cheap and defensible today, or
   commit to building the blinded adjudicated-name sample. The reword is a
   half-hour; the sample is a project.
2. **Fill the Disposition column** in both `2026-10-14_002133-full-*` reports.
   Three are Fixed in `5424c43`; the remainder are item 4.
3. **Find or recompute Table 1 and Appendix A.4's percentages** (item 4, second
   half) — no producing code exists for them.
4. **Run `-Scope replication`** before submission (item 3). It has never run.

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

### 1. ~~Size the blank-string bug~~ — DONE 2026-10-02: negligible

Measured on the 1940 transcription data, 49 states, 121,129,456 records in the
denominator of `comparing_model_transcription_with_anc_fs_SSHA2025.do`:

| | records | share |
|---|---|---|
| ≥1 human name field blank (exposure) | 10,485 | 0.0087% |
| agreements actually resting on `""==""` | 4,890 | 0.0040% |

Both reviewers were right about the logic and wrong about the magnitude: this
does not move any reported agreement rate at three decimal places. Worst state
is `wv` at 0.026%. It is near-symmetric across sources (Ancestry blanks 8,928,
FamilySearch 9,728), so it does not bias the Ancestry-vs-FamilySearch
comparison either. **A footnote, not a correction.** Per-state detail was
written to a scratchpad CSV; rerun the diagnostic if it is needed again.

**But sizing it surfaced something larger in the same denominator.** The
*model's* fields are blank far more often than the humans': `namefrst_ml` on
2,420,641 records (2.0%) and `namelast_ml_ditto` on 3,832,347 (3.2%). Those
records have no model transcription at all, and the script files them under
"agrees with neither" — a different claim from "the model read it and
disagreed". Restricting to records with all six fields non-empty:

| | as coded | strict (6 fields) |
|---|---|---|
| agrees with Ancestry only | 4.15% | 4.36% |
| agrees with FamilySearch only | 15.01% | 15.81% |
| agrees with both | 63.23% | 66.56% |
| agrees with neither | 17.61% | 13.27% |
| denominator | 121,129,456 | 115,057,761 |

6,066,244 records — **28.4% of the whole "agrees with neither" bucket** — are
there only because the model produced nothing. Concentrated in the Northeast
(`ct` 5.2%, `nj` 4.7%, `ri` 4.5%, `ma` 4.4%). Splitting "no model output" out
of "agrees with neither" is real outstanding work, and unlike the blank-string
bug it *does* move the numbers.

Note for the draft — **the discordant-subset half of this is DONE
(2026-10-12)**. The Rhode-Island-era "11\% Ancestry / 47\% FamilySearch"
sentence has been recomputed all-states by
`CODE/compute_model_agreement_on_discordant.do` and now reads **14\% / 52\%**
(`DHTS-2026-10-12.tex:301`). No-model-output is split out there rather than
buried: the four outcomes are 14\% Ancestry, 52\% FamilySearch, 24\% a
complete name matching neither, and 10\% no usable transcription, partitioning
all 35.1 million discordant records whose four human name fields are present.
Conditioning on the model having produced something would raise the headline
66\% to 73\%, and the draft says so rather than conditioning.

**Still open: the whole-sample partition above.** The 121,129,456-record
table in this item is not in the draft, which reports only the discordant
subset. If the paper ever quotes the full-sample shares, use the strict column
and report "no model output" as its own bucket — do not let 6,066,244 records
sit inside "agrees with neither".

### 2. ~~Verify the Hawaii restoration~~ — DONE 2026-10-02: reverted

**Hawaii cannot be in the loop, and the original `/*"hi"*/` was correct.**
`hi\merged_data.dta` holds only the model columns — `filename`, `row`,
`parsing_quality`, `non_ditto*`, `namefrst_ml`, `namelast_ml`,
`namelast_ml_ditto`. It was never merged against the Ancestry and FamilySearch
transcriptions, so `namefrst`, `namelast`, `fs_namefrst` and `fs_namelast` do
not exist in it and the `use` cannot succeed.

The failure mode was worse than the drift this item anticipated. Hawaii sits
11th of 50 and the `use` had no `capture`, so the run died there with `r(111)`
— and **in batch mode the log simply stops, recording no error at all**, with
the totals (printed after the loop) never reaching the console. Ten states of
work discarded, forty never attempted, no output, no explanation. Reproduced
directly before reverting.

Also note the guard this item proposed would **not** have caught it: it guards
`cd`, and the `hi` directory exists. The contents are the problem. Both guards
are now in place — directory *and* columns — and each skips the state loudly
and keeps going, with a coverage line (`states attempted / contributed /
skipped`) next to the totals so a partial run can never again look complete.
Verified: `hi` and a synthetic `zz` both skip, the loop continues, and the
totals for good states are byte-identical to an unguarded run.

**Alaska is the opposite case.** `ak\merged_data.dta` is complete (all six
fields, 14.7 MB) and is absent from the list entirely. So the exclusions were
never about 1940 territorial status, as this item speculated — `ak` could
legitimately be added; `hi` cannot until its merge is built. Adding `ak` is a
substantive choice about which population the paper describes and belongs in
the data section, not in code.

### 3. Run the dimensions nothing has touched

**Updated 2026-10-14.** `correctness` has been run against two files, and
`claims-vs-code` has now been run six times over the full repo with the draft
passed via `-PaperPath`, four of those with both reviewers — the latest pair is
`2026-10-14_002133-full-{codex,agy}` with the side-by-side in
`2026-10-14-post-audit-comparison.md`. Three of its four shared findings were
addressed in `5424c43` of the draft repo: the manual-review claim, the
conclusion's bias language, and a new paragraph disclosing that the linking
runs in a separate codebase. **The one still open is the big one** — see item
4 below.

**`replication` and `identification` have still never been run.** `replication`
will have plenty to say about the hardcoded `D:\Dropbox` and `F:\` paths, the
`V2`/`V3`/`_nber`/`_SSHA2025` variants, and the missing linking code just
mentioned. Run it before submission, with `-Target full`.

### 4. Weaken the transcription-quality claims, or get an adjudicated sample

**Open as of 2026-10-14, and the most important thing left in the draft.** Both
reviewers independently made this their finding #1, `MAJOR` / `verified`, and
`5424c43` did not touch it. The code measures two things: agreement with
Ancestry and FamilySearch, and downstream linkage. Neither establishes that a
name was transcribed *more accurately*, because nothing compares model output
to an adjudicated reading of the image. The draft concedes this at
`DHTS-2026-10-12.tex:302-304` and then claims the stronger thing anyway:

- `:66` "improves name transcription"
- `:71` "improved transcription methods"
- `:121` "machine learning can systematically improve transcription quality"
- `:131` "dramatic improvements in both the quantity and quality"
- `:132-133`, `:138` the same claim again

Two ways out, and they are not equivalent. Either reword throughout to
"improved agreement with commercial transcriptions and improved linkage
outcomes" — cheap, and defensible today — or build the blinded
adjudicated-name sample the draft already says is planned, which is the only
thing that earns the current wording. Do not leave it as it stands into a
referee's hands.

Also open, from Antigravity only: **Table 1 and Appendix A.4's out-of-sample
performance percentages have no producing code** in this repo
(`DHTS-2026-10-12.tex:261-273`, `:917-920`). Either find the script that made
them or recompute them.

And: **the Disposition column is empty in both 2026-10-14 reports.**
`CLAUDE.md` requires every finding to carry Fixed / Rebutted / Accepted risk.
Three are Fixed in `5424c43`; the rest are the items above.

### 5. Open the pull request

Done 2026-10-03: https://github.com/hwangii/fixing_transcription_errors/pull/1.
`gh` is now authenticated on this server. Through Claude Code's `!` prefix,
bare `gh auth login` hangs waiting for Enter; use
`echo "" | gh auth login --hostname github.com --git-protocol https --web`
and enter the printed code at github.com/login/device.

### 6. Act on the review of Deaglan's package (2026-10-02)

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

- **Do not use `deaglan_results/retired/linkage_table_newlinks*.tex`.**
  Retired script, different dedup rule, match rates of 116–119%; moved to
  `retired/` on 2026-10-12. The current tables, mortality included, are in the
  paper repo under `deaglan_results/current/` with `PROVENANCE.md`.
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
