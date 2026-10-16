# Replication package: *Fixing Transcription Errors in Historical Census Records*

Draft: `DHTS-2026-10-12.tex` (paper repo, cloned from Overleaf).
Package started 2026-10-15. **Status: in progress.** The section
[What is not covered](#what-is-not-covered) is part of the package. It is not a
footnote to it.

Layout follows the [Social Science Data Editors template README](https://social-science-data-editors.github.io/template_README/).

---

## Overview

The paper's numbers come from three places:

| Source | Runs on | Produces |
|---|---|---|
| Stata scripts in `CODE/` | machine A (`ARTS-ECON-CM`) | Tables 2-4, Figures 3-4, every in-text agreement, sample and subgroup statistic |
| Deaglan's linkage package (`F:\Deaglan\Census_Transcriptions\`, not in this repo) | machine B | Tables 5-8 (ABE, Jaro-Winkler and HLINK linkage), and the prose that quotes them |
| The ML transcription pipeline (not in this repo) | ? | Table 1, the training-set counts, the hyperparameters, the GPU benchmark |

The package does three things:

1. **Reruns** every exhibit machine A can produce, from frozen intermediate
   files, with one command.
2. **Records** each number the draft quotes in a tracked file, as the script
   computes it (`results/*.tex`). Each number is written as a LaTeX macro, so
   the draft can `\input` the file and use the number directly.
3. **Checks** every number in the draft against its source: a results file,
   an exhibit table, or a known gap (`check_claims.py`, using the registry
   `claims.toml`). The latest report is `claims_report.md`.

## Quick start (machine A)

```powershell
.\Sync.ps1 -Pull
.\replication\Run-MachineA.ps1 -SkipRebuild   # minutes: everything except the 22 GB analysis-file rebuild
.\replication\Run-MachineA.ps1                # hours: full run, rebuilds the analysis file first
```

The driver refuses to start if the paper repo has uncommitted changes under
`figures/`. It then runs the Stata master and the claim check, and shows what
changed. Read the output in this order:

- **`check_claims.py` exit status.** 0 means every checkable number in the
  draft matches its source. 1 means at least one `MISMATCH`, `TEXT NOT FOUND`
  or failed assertion. Details are in `claims_report.md`.
- **The paper repo's `figures/`.** A changed `.tex` table did **not**
  reproduce. A changed PDF is checked by `compare_figures.py`, which compares
  the drawing (every point, label and coordinate) and ignores the embedded
  font. Stata 15 PDFs carry no creation date, but the font program embedded
  in them can differ between sessions. On 2026-10-15 Figure 4 regenerated
  byte-identical, and Figure 3 regenerated with an identical drawing and
  different font bytes.
- **`git diff replication/results/`.** A changed line is a number that moved.

To check the draft without running Stata, for example after editing prose:

```powershell
python replication\check_claims.py
```

## Data availability and provenance

None of the data can be redistributed, and none of it is in git.
`.gitignore` excludes `*.dta`, `*.csv` and `*.txt`.

| Data | Source | Access | Location |
|---|---|---|---|
| 1940 full-count census with Ancestry.com name transcriptions | IPUMS USA restricted full count (`us1940b_usa_res.dat`) | IPUMS restricted-data agreement | A: `F:\updated_census_recvd_aug2021\` (zipped) |
| 1940 FamilySearch.org name transcriptions | Scrape of FamilySearch, one CSV per state | Not redistributable; terms of FamilySearch | A: `F:\test_selection_on_unobservable\DATA\ORIGINAL\` (zipped) |
| 1940 socio-demographic extract | IPUMS USA extract `usa_00647` | IPUMS registration | A: `F:\enum_date\DATA\ORIGINAL\usa_00647.dat` |
| 1930-1940 link files (`link1930_1940_{ans,true}_cleaned_noraceblock0.dta`) | `enum_date` project; **no producing code in this repo** | — | A: `D:\SNU ECON Dropbox\sam hwang\enum_date\DATA\INTERMEDIATE\` |
| Model transcriptions, per state (`merged_data.dta`) | ML pipeline; **no producing code in this repo** | — | A: `...\fixing_transcription_errors\DATA\TRANSCRIPTIONS\USCensus1940FullCount\output_and_output1_ssha2025\<st>\` |
| 1940 census images | NARA, public S3 bucket `s3://nara-1940-census` | Public | Downloaded by `CODE/choosing_edist_with_blacks_nber.do`, `CODE/census1940_image_downloader_*.py` |
| FamilySearch genealogical reference links | Used by Deaglan's package | — | B |

**Still to write for each row:** the date each file was downloaded or scraped,
and its licence terms. Data editors require both.

### Frozen intermediate files the analysis tier reads

`run_machineA.do` checks for all 56 before it runs anything.

| File | Size | Dated | Built by |
|---|---|---|---|
| `...\fixing_transcription_errors\DATA\ORIGINAL\census1940_all_labeled_data.dta` | 43 GB | 2025-01-10 | `clean_FS_and_combineV5_nber.do`, block 5 (**now commented out**) |
| `F:\enum_date\DATA\ORIGINAL\all_states_socio_demo_char_for_SSHA2025.dta` | 5.9 GB | 2025-11-21 | `usa00647_for_SSHA2025_socio_demo_char.do` |
| `...\enum_date\DATA\INTERMEDIATE\link1930_1940_{ans,true}_cleaned_noraceblock0.dta` | 2.8 / 3.1 GB | 2026-02-15 | external (`enum_date` project) |
| `F:\fixing_transcription_errors\DATA\INTERMEDIATE\temp.dta` | 14 GB | 2026-09-08 | `munir_figures_for_nber.do` (state loop) |
| `...\output_and_output1_ssha2025\<st>\merged_data.dta`, 49 jurisdictions | ~1 GB each | 2025-11 | external (ML pipeline) |
| `...\enum_date\DATA\INTERMEDIATE\temp.dta` (the analysis file) | 22 GB | 2026-09-13 | `create_figures_SSHA2025.do`, rebuilt by a full run |

## Computational requirements

- **Stata/MP 15.1.** `run_machineA.do` sets `version 15.1`.
- **User-written Stata commands** used by active code:

  | Command | Version | Install |
  |---|---|---|
  | `binsreg` | 1.3 (06-Jul-2023) | `net install binsreg, from("https://raw.githubusercontent.com/nppackages/binsreg/master/stata") replace` |
  | `grc1leg` | 1.0.5 (02jun2010) | `net install grc1leg, from("http://www.stata.com/users/vwiggins")` |
  | `repnum` | 1.0 | included: `replication/stata/repnum.ado`, put on the adopath by `config.do` |

- **Python 3.11+**, standard library only, for `check_claims.py`.
- **Hardware.** Machine A has 128 GB RAM and 16 logical cores. The full run
  reads a 43 GB file and writes a 22 GB one.
- **Runtime.** With `-SkipRebuild`, 33 minutes (2026-10-15). The full run takes about
  TBD hours. Fill both in from the first complete run's log.

## Description of the package

```
replication/
  README.md            this file
  config.do            the one place paths are set; one block per machine
  run_machineA.do      master for machine A: preflight, then every script in order
  Run-MachineA.ps1     driver: clean-repo check -> Stata -> claim check -> what changed
  Run-Stata.ps1        runs one do-file in batch mode and reports its real return code
  stata/repnum.ado     writes one number as \newcommand{\Key}{value}% raw=...
  results/*.tex        the numbers each script wrote (tracked; one file per script)
  claims.toml          registry: every number and exhibit in the draft -> its source
  check_claims.py      compares the draft with results/, the exhibit tables, and claims.toml
  compare_figures.py   says whether a regenerated PDF has the same drawing as the committed one
  diagnostics/         one-off sizing scripts (e.g. missing ages, blank names)
  claims_report.md     the latest check (generated)
```

### Why `Run-Stata.ps1` exists

Stata 15 batch mode returns no exit code. When a do-file errors, the log stops
mid-command, `r(###);` is never written, and Stata waits on a hidden dialog
until it is killed. A failed run therefore looks like a hung one, or like a
short, complete one. HANDOFF item 2 records the time this cost on Hawaii.

`Run-Stata.ps1` wraps the target in `capture noisily` and always prints its
return code, so a failure is reported within seconds with its `r()` code.
Call it from PowerShell. Git Bash rewrites the `/b` flag into a drive path, and
Stata then never runs the file.

## Exhibits and the scripts that produce them

| Exhibit | Draft label | Script | Machine | Output |
|---|---|---|---|---|
| Table 1 | `tab:transcription-performance` | **none** (hand-typed) | ? | — |
| Table 2 | `tab:sample_characteristics` | `make_balance_exhibits.do` | A | `figures/balance_allstates.tex` |
| Table 3 | `tab:cong_vs_incong` | `make_balance_exhibits.do` | A | `figures/incongruent_allstates.tex` |
| Table 4 | `tab:avg_performance` | `create_figures_SSHA2025.do` | A | `figures/avg_performance_allstates.tex` |
| Tables 5-8 | `tab:deaglan_*` | Deaglan, `code/00_run_all_tables.do` | B | `figures/deaglan_*.tex` (tabular extracted by hand from `deaglan_results/current/`) |
| Figure 1 | `fig:schedule` | **none** (image crop) | ? | `figures/rhode_island_4_252_61.png` |
| Figure 2 | `fig:error_examples` | **none** (image crops) | ? | three `.png` |
| Figure 3 | `fig:hetero_socio` | `create_figures_SSHA2025.do` | A | `figures/all_states_socio_demo_combinedV2.pdf` |
| Figure 4 | `fig:hetero_legibility` | `create_figures_SSHA2025.do` | A | `figures/all_states_hetero_combinedV2.pdf` |
| Table A1 | `tab: network-params` | **none** (hand-typed parameters) | ? | — |

The registry (`claims.toml`) holds the same mapping for every **in-text**
number: about 65 claims, each tied to a script, a result key, a table cell,
or "no producing code".

### In-text numbers: scripts and result files

| Script | Result file | What the draft quotes from it |
|---|---|---|
| `make_balance_exhibits.do` | `results/make_balance_exhibits.tex` | 55,350,482; 51,066,203; 14,427,780; 28.3%; 72%; urban and farm shares |
| `create_figures_SSHA2025.do` | `results/create_figures_SSHA2025.tex` | 8.9 → 19.4%, +119%, 65 → 84%, +28%, +8%, +1%; 51,036,859; "every group improved" |
| `compute_model_agreement_on_discordant.do` | `results/compute_model_agreement_on_discordant.tex` | 66%, 14%, 52%, 24%, 10%, 35.1 million, 66 → 73 |
| `compute_race_linkage_rates.do` | `results/compute_race_linkage_rates.tex` | 11.0% / 24.1%; +6.4% / +7.9% |
| `compute_subgroup_linkage_rates.do` | `results/compute_subgroup_linkage_rates.tex` | foreign-born, no-schooling and non-English baselines and gains |
| `verify_inmates_and_county_stats.do` | `results/verify_inmates_and_county_stats.tex` | inmates 15.0%, +7.3%; county p5/p95 18% / 42% |
| `compute_legibility_quartiles.do` | `results/compute_legibility_quartiles.tex` | 46.2 vs 14.0; 16.9 vs 27.7; +20% vs +1.4% |

## Two machines

Machine A holds all the data the `CODE/` scripts read. Machine B holds
Deaglan's package. The draft needs numbers from both, and neither machine can
see the other's data.

- **Machine A** runs `Run-MachineA.ps1`. Its outputs are the `results/*.tex`
  files in this repo and the exhibit tables in the paper repo's `figures/`.
  All of them travel by git.
- **Machine B: not built yet.** It needs its own block in `config.do`, a
  `run_machineB` that reruns Deaglan's `00_run_all_tables.do`, and a script
  that extracts the `tabular` from `deaglan_results/current/*.tex` into
  `figures/deaglan_*.tex`. That step is currently done by hand. Until then, the
  checker verifies that the prose matches Deaglan's tables as committed. It does
  not verify that those tables reproduce.
- **`check_claims.py` runs on either machine.** It needs only the two repos.

## What is not covered

These are the gaps between this package and a submittable one, ordered by what
would actually stop a replicator. `claims_report.md` lists the affected claims
individually.

1. **The ML pipeline has no code here.** Nothing covers segmentation, training,
   evaluation or benchmarking. That leaves without a source: Table 1 (97.38 /
   98.61 / 94.54 / 98.29), the training counts (392,085; 121,465; 29,641;
   28,032), the Table A1 hyperparameters, the Rhode Island benchmark (299,880
   records, 1,600 GPU-hours) and its 730,000 extrapolation. The per-state
   `merged_data.dta` files the agreement statistics read also come from this
   pipeline. Whoever holds the pipeline needs to supply the code, or at minimum
   the evaluation script and its log.
2. **The build tier cannot run.** `CODE/_master_for_creating_training_dataset.do`
   changes to `D:\Dropbox\...`, which no longer exists (Dropbox moved to
   `D:\SNU ECON Dropbox\sam hwang\`). The stages of
   `clean_FS_and_combineV5_nber.do` that import, clean and merge FamilySearch
   and build `census1940_all_labeled_data.dta` are commented out. So the
   intermediates the analysis reads exist only as products of earlier runs.
   Re-enabling those stages, and checking that they reproduce the frozen files,
   is the next big piece of work.
3. **The 1930-1940 link files** come from the `enum_date` project, whose code
   is not in this repo.
4. **Machine B's runner** (see above).
5. **Inputs with no checksum.** Nothing records which version of each frozen
   file produced the results. Adding a SHA-256 manifest of the inputs to each
   run's log would close this.
6. **Data provenance dates and licences** (see the table above).
7. **Known hazards, not yet fixed.** All of these are recorded in the review
   reports:
   - `keep if age>=10` retains records with a missing age.
   - No merge uses `assert()`.
   - `munir_figures_for_nber.do` still writes old versions of Tables 2-3 if run.
   - `choosing_edist_with_blacks_nber.do` samples after an unstable sort, so
     its `set seed` does not make the sample reproducible.

## Moving the draft onto generated numbers

This is the agreed plan. The checker runs first, as a read-only check against
the draft as it stands. Then the draft switches over **section by section**:
each hand-typed number is replaced with its `\Key` macro, and each result file
is `\input` in the preamble. The checker stays in place afterwards, to catch
any number that is still typed by hand.

The paper repo's rules apply to each step: pull immediately before, push
immediately after, one sentence per line, and no reflowing.
