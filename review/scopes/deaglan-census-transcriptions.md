# SCOPE — Deaglan's linkage replication package

> Project-specific scope for reviewing **`F:\Deaglan\Census_Transcriptions\`**.
> Used by `Run-Review.ps1 -Root F:\Deaglan\Census_Transcriptions -ScopeFile <this file>`.
> The checklists, schema and protocol are shared; only this file is specific.

## What this is

A replication package written by coauthor Deaglan Jakob (finished 2026-09-06,
with Claude Code assistance) answering: *does a better transcription of the
1930/1940 US census produce better record linkage?* Three independent linkages,
each run on the **old** (Ancestry) and **new** (ML) transcription:

| # | Linkage | Table script | Output |
|---|---|---|---|
| 1 | ABE + Jaro-Winkler, 1930↔1940 | `code/01_abe_jw/linkage_analysis.do` | `output/tables/linkage_table_abe_jw*.tex` |
| 2 | HLINK (IPUMS MLP), 1930↔1940 | `code/02_hlink/linkage_analysis_newlinks.do` | `output/tables/linkage_table_hlink*.tex` |
| 3 | Mortality, 1940↔BUNMD deaths | `code/03_mortality/05_make_linkage_table.do` | `output/tables/linkage_table_mortality_bunmd.tex` |

Master: `code/00_run_all_tables.do`. All paths flow from `code/shared/paths.do`
(`$ROOT`). Read `README.md`, `DOCUMENTATION.md` (esp. §6 *Known gaps*) and
`LINKAGE_README.md` first — they are candid and name their own weak spots.
**It is not a git repository.** Nothing here has version history.

These tables are about to be wired into the paper draft at
`F:\github_repos\6638fa0fd89fbec05130caeb\DHTS-2024-11-18.tex`.

## Active dimensions

| Key | Weight | Why here |
|---|---|---|
| `replication` | **high** | Two pieces of producing code were lost and reconstructed (`run_abe_match.do`, `build_matched_links.do`). HLINK matching is third-party and cannot be regenerated. No version control. The package claims "all five tables verified byte-identical" — that claim was written by an agent reading logs; check it against `output/logs/`. |
| `claims-vs-code` | **high** | The draft will quote these tables. Captions, denominators and sample definitions must match what the scripts compute, and must match each other across the three tables. |
| `correctness` | **high** | The table scripts classify 13–68M pairs against ground truth. Dedup rules, denominators and merge keys decide every number; a retired version of the HLINK script produced match rates of 116–119%. |
| `identification` | medium | The "restricted" sample (`congruent == 0`) selects on transcription disagreement, and one-name joins exist in the original ABE links. Judge whether the comparison design supports the paper's claim. |

## Facts already verified — confirm, do not rediscover

- **Age cutoff:** both census-to-census scripts use `keep if age >= 8`
  (`01_abe_jw/linkage_analysis.do:38`, `02_hlink/linkage_analysis_newlinks.do:182`).
  The draft currently says "aged 10 and above" in three places. The decision
  taken is that **the draft will follow the code (8)**. Report every place the
  package's own docs or captions say otherwise.
- **Denominators differ across tables.** The HLINK script's denominator is built
  from `divided_file1940_true_cleaned_women_added.dta` — **men and women** aged
  8+ — into a scalar still named `N_men_1940_full`. The ABE/JW script's
  denominator is `clean_names_1940_new.dta`, **men only**. Both captions say
  "all men in the 1940 census". Deaglan's §6 admits the HLINK naming is stale.
  Establish exactly what each denominator counts, and whether the mortality
  table uses a third definition.
- **`linkage_table_newlinks*.tex` is retired.** It lives in
  `_archive/output_previous/`, came from a script using `dedup_rule "prob"` /
  `unique1940` that the current script replaced with
  `duplicates drop histid1930, force`, and reports match rates of 116.01 / 118.94
  (full) and 101.87 / 115.92 (restricted) — over 100%. Explain mechanically how
  the retired logic exceeded 100%, and prove the current script cannot.
- **ABE reconstruction:** `run_abe_match.do` reproduces 16,944,747 of
  16,946,362 (old) and 18,197,078 of 18,198,099 (new) original pairs, a strict
  subset; every missing pair is a one-name join (blank first or last name
  matched to another blank). 845 / 630 of those carry `fiveyr_band == 1` and so
  enter the published table (0.007%). Check `validate_abe_reconstruction.do`
  and `diagnose_abe_shortfall*.do` actually establish this, and whether the
  one-name links should be *removed* from the originals before tabulation
  rather than tolerated.
- **`build_matched_links.do`** was recovered from a log's command echo; its
  SETTINGS block was *inferred*. The file says which five values. Verify the
  independent check against `prep_HLINK_matches.do` is a real cross-check and
  not the same code twice.
- **Stale drive letters:** `F:\Deaglan\HLINK\CLAUDE.md` references `E:\...`;
  `paths.do` says D:/E:/F: drift was repaired. Find any surviving absolute path
  that is not derived from `$ROOT` (`grep -rn '[A-Z]:[/\\]' code/`).

## Specific questions to answer, with `path:line`

1. In each table script, how is **`N_linked`** computed for the match rate
   (`linkage_analysis_newlinks.do:271`): unique 1940 ids, unique 1930 ids, or
   pair count? Which dedup (`:93`, `:218`, `:356`, `:368`) applies *before* the
   rate, and which only to the later pair-level comparison? Can any
   one-to-many link push the rate above 100% today?
2. For the **restricted** sample, is the numerator restricted by
   `histid1940 ∈ congruent==0` while the denominator is the same set? (`:263`,
   `:195-198`). Any mismatch of restriction between numerator and denominator
   is a blocker.
3. "Verified Correct / Unverifiable / Directly Contradicted": how is a pair
   classified against `mlp_training1930_1940.dta`? Is "unverifiable" treated as
   neutral, and does the text in the draft risk reading it as correct?
4. Does `00_run_all_tables.do` actually produce the files the README lists,
   and does `output/logs/00_run_all_tables.log` (2026-09-06) support
   "byte-identical to the previous run"? Quote the evidence or its absence.
5. Does the mortality pipeline's `05_make_linkage_table.do` share the
   vocabulary (denominator, age, sex restriction) of the other two, or is the
   third table on yet another base?
6. List every input the package needs that is **not** on disk or lives outside
   `$ROOT` (§6 names `usa_00015.dat` and `D:\ABE_JW\DATA\ORIGINAL\matching_intgen1940.dta`).

## Out of scope

- `code/01_abe_jw/reference/` (original ABE `.ado`s by Abramitzky–Boustan–Eriksson)
  and `vendor/censocdev-master/`: third-party, vendored. Note licensing only.
- The internals of HLINK/PySpark under `F:\Deaglan\HLINK\`: third-party
  matching, not reproducible here by the package's own admission.
- Anything under `_archive/` or `data/` beyond confirming existence. Do not
  attempt to open multi-GB `.dta` files.
- Style, naming, comment density.

## Honest limits to state in `review_limits`

The data (325 GB) cannot be read; the master takes ~4 h and will not be run;
HLINK links cannot be regenerated by anyone. Say so rather than inferring
runtime behaviour as fact.
