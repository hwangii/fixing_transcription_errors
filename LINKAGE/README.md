# Census Transcription Linkage — Replication Package

Does a better transcription of the 1930/1940 US censuses produce better record
linkage? This package answers that with **three independent linkages**, each
comparing links built on the **old** transcription against the **new** one.

| # | Linkage | Records joined | Table |
|---|---------|----------------|-------|
| 1 | **ABE + Jaro-Winkler** | 1930 census ↔ 1940 census | `linkage_table_abe_jw.tex`, `linkage_table_abe_jw_restricted.tex` |
| 2 | **HLINK** | 1930 census ↔ 1940 census | `linkage_table_hlink.tex`, `linkage_table_hlink_restricted.tex` |
| 3 | **Mortality** | 1940 census ↔ BUNMD death records | `linkage_table_mortality_bunmd.tex` |

**To rebuild every table:** run `code/00_run_all_tables.do` (~4 h 10 m). It
re-runs only the aggregation layer — no matching algorithm is invoked and no
link is recomputed.

**All five tables are verified reproducible.** The full master was run end to end
on 2026-09-06, after the data reorganisation, and every table came back
byte-identical to the previous run — with one exception that is not a number:
the mortality table's first line is a `%` comment naming the file, and the older
copy still carried the pre-rename name. Every figure in all five tables is
unchanged.

**The ABE matcher has been reconstructed and re-run on the full count.** Its
producing code was missing from every drive; the reconstruction now reproduces
99.99% of the original links and is a strict subset of them, with every
difference explained — see `LINKAGE_README.md`, "Reconstructing the ABE links".

See `DOCUMENTATION.md` for data provenance, per-table inputs, and what the numbers
mean, and `LINKAGE_README.md` for how the links themselves were produced.

---

## Folder structure

```
Census_Transcriptions/
├── README.md              this file — where things live
├── DOCUMENTATION.md       provenance, inputs, methods, results
├── LINKAGE_README.md      how the links themselves were produced
│
├── code/                  15 MB — all analysis code
│   ├── 00_run_all_tables.do    master: rebuilds all five tables
│   ├── shared/
│   │   └── paths.do            SINGLE SOURCE OF TRUTH for every path
│   ├── 01_abe_jw/              linkage 1
│   │   ├── linkage_analysis.do   the table
│   │   ├── linkage/              the matching pipeline
│   │   ├── ado/                  required ados
│   │   ├── comparison/           ABE-exact vs ABE-JW comparison
│   │   └── reference/            original ABE algorithm + docs
│   ├── 02_hlink/               linkage 2: link cleanup + table
│   ├── 03_mortality/           linkage 3: full pipeline, steps 0-5
│   └── prep/                   shared data preparation
│
├── data/                  325 GB — organised by ROLE, not by consumer
│   ├── census/                 source census extracts (26 GB)
│   ├── names/
│   │   ├── cleaned/            clean_names_* extracts (16 GB)
│   │   └── flags/              ipums_fs congruence flags (5 GB)
│   ├── transcriptions/         the same data at two stages
│   │   ├── shards/             144 raw shards × 4 vintages (41 GB)
│   │   └── appended/           one file per vintage (43 GB)
│   ├── links/
│   │   ├── raw_hlink/          third-party HLINK CSVs (34 GB)
│   │   └── derived/            linked pairs we produced (17 GB)
│   ├── truth/                  ground truth + the crosswalk it came from
│   └── mortality/
│       ├── raw/                BUNMD + CenSoc sources (8 GB)
│       ├── intermediate/       census with names merged (23 GB)
│       └── working/            bpl splits, matched shards, outputs (96 GB)
│
├── abe_jw/                98 GB — ABE/JW linkage WORKING TREE
│   └── data/                   per-bpl splits, prep intermediates, matched
│                               output, source census extracts. Not needed to
│                               rebuild any table; needed to re-run a match.
│
├── output/                3.3 MB
│   ├── tables/                 ← ALL FIVE .tex TABLES LAND HERE
│   └── logs/                   Stata run logs
│
├── vendor/                132 MB
│   └── censocdev-master/       third-party CenSoc R package (read-only)
│
└── _archive/              187 GB — superseded, nothing deleted
```

**The package is self-contained.** Nothing reads a path outside this folder, and
no drive letter appears in any script. `code/shared/verify_paths.do` proves it —
it checks every global and every required file, and takes seconds to run.

**Where a folder was split, the global kept its old meaning**, so the split cost
almost no code changes. `$D_NAMES` still means "the cleaned name extracts" and
`$D_LINKS` still means "the links we derived" — those are what nearly every
script wanted. The new globals name the things that were previously mixed in
with them:

| Global | Points at | Why it is separate |
|---|---|---|
| `$D_NAMES` | `data/names/cleaned/` | What scripts mean by "names" |
| `$D_FLAGS` | `data/names/flags/` | Congruence flags — a different kind of thing |
| `$D_TRANSCRIPT` | `data/transcriptions/shards/` | Raw shards |
| `$D_APPENDED` | `data/transcriptions/appended/` | The same shards, appended |
| `$D_LINKS` | `data/links/derived/` | Links we produced |
| `$D_LINKS_RAW` | `data/links/raw_hlink/` | Third-party input we did not produce |

## Where to look first

| I want to… | Go to |
|---|---|
| Rebuild the tables | `code/00_run_all_tables.do` |
| See the results | `output/tables/` |
| Re-run the ABE match on the full count | `code/01_abe_jw/linkage/run_abe_match.do` (6.9 h, both vintages) |
| Check every path still resolves | `code/shared/verify_paths.do` |
| Move the project to another drive | `code/shared/paths.do` (then see below) |
| Understand a number in a table | `DOCUMENTATION.md` |
| See how the links were made | `LINKAGE_README.md` |
| Find why a file is in `_archive/` | `DOCUMENTATION.md`, "Archived material" |

## Paths

Every script derives its paths from `code/shared/paths.do`, which defines one
`ROOT` global. This package previously carried absolute paths across three
different drive letters (`D:`, `E:`, `F:`) that silently went stale whenever a
folder moved; nothing outside `paths.do` and the bootstrap lines may hardcode a
drive letter again.

**To relocate the package**, update `ROOT` everywhere it appears:

```
grep -rl "global ROOT" code/
```

There are 31 occurrences — `paths.do` plus one bootstrap line per script.
Then run `code/shared/verify_paths.do` to confirm the move landed.
Stata cannot resolve a path relative to the running
do-file, and `clear all` inside each script wipes globals set by the master, so
each entry point must be able to find `ROOT` on its own.

## `_archive/`

Nothing has been deleted. `_archive/` holds superseded script generations,
orphaned intermediate data, duplicate archives, and outputs from retired
pipeline versions. It is **not** needed to rebuild any table, and it is safe to
move off this drive. `DOCUMENTATION.md` lists what is in there and why.

## Requirements

Stata 15+ (developed on StataMP-64 15.1). The three **table** scripts need no
external packages. The **linkage** steps additionally require `abematch`,
`abeclean`, `statastates`, `gtools`, `ftools`, and `parallel` — see
`LINKAGE_README.md`.

Budget disk headroom outside the project as well: Stata writes its tempfiles to
the system temp drive, not into the package, and the table run moves 5-12 GB
files through it.

## Running a script headless (Windows)

```powershell
Start-Process "C:\Program Files (x86)\Stata15\StataMP-64.exe" `
  -ArgumentList '/e','do','"F:\Deaglan\Census_Transcriptions\code\00_run_all_tables.do"' `
  -Wait -NoNewWindow -WorkingDirectory "F:\Deaglan\Census_Transcriptions\output\logs"
```

Two traps, both of which cost time here:

- **Launch from PowerShell, not from a Unix-style shell.** Stata is a GUI
  application: started from bash it detaches immediately, the caller returns
  success, and no log is ever written. `Start-Process -Wait` is what makes the
  call block until Stata actually exits.
- **`-WorkingDirectory` decides where the log lands.** Batch mode writes
  `<dofile>.log` into the *process* working directory, not next to the do-file,
  so without this the log appears wherever the shell happened to be. Point it at
  `output/logs/`. Do not add a `log using` with the same name — batch mode has
  already opened that file and the script will fail with `r(608)`.

**Never edit a do-file while it is running.** Stata reads do-files incrementally
by byte offset, so an edit mid-run shifts everything after the read point and
splices unrelated lines together. The failure is silent and confusing: it
surfaces as a syntax error on a line that looks fine.
