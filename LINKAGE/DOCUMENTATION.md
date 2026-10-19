# Documentation — data provenance, inputs, and results

Companion to `README.md`, which covers folder layout. This file covers where the
data came from, what each table needs, how each table is computed, and what the
numbers mean.

---

## 1. The research question

All three linkages test the same thing: **does a better transcription of census
name fields produce better record linkage?** Each linkage was run twice — once on
the *old* transcription, once on the *new* — and each table compares the two.

"Old" and "new" appear under different names depending on the linkage:

| Linkage | Old transcription | New transcription |
|---|---|---|
| ABE / Jaro-Winkler | `..._ans_cleaned` (Ancestry) | `..._true_cleaned` |
| HLINK | `matches_before.dta` | `matches_after.dta` |
| Mortality | `..._oldnames` | `..._newnames` |

---

## 2. Data provenance

### `data/census/`

| File | Size | Origin |
|---|---|---|
| `1930_1940_full_w_women.dta` | 16.0 GB | IPUMS full-count 1930 + 1940. 254,679,910 persons. Converted from the IPUMS extract `usa_00021.dta.gz` (now in `_archive/data/`). Vars: `year sample serial hhwt gq pernum perwt sex age race raced bpl bpld versionhist histid`. |
| `1940_census_for_merge_with_bunmd.dta` | 5.8 GB | Built by `code/03_mortality/000_merge_new_census_vars.do`: `$ABE_SRC/matching_intgen1940.dta` (11.9 GB, now in `abe_jw/data/source_census/`) merged 1:1 on `histid` with `marriage_status_1940.dta`. |
| `marriage_status_1940.dta` | 6.2 GB | Built by `code/03_mortality/000_import_new_census_vars.do` from IPUMS extract `usa_00015.dat`. **The raw `.dat` is not on disk** — see Known gaps. |

### `data/names/` — `$D_NAMES` and `$D_FLAGS`

| File | Size | Origin |
|---|---|---|
| `cleaned/clean_names_{1930_old,1940_old,1940_new}.dta` | 16.2 GB | The canonical cleaned-name extracts, produced by `code/01_abe_jw/linkage/00_merge_names_to_census.do` (step 0). Men only: 62,079,010 rows (1930) and 66,135,592 (1940). Vars: `age histid mi f_name l_name sex birthyr race bpl`. Originally lived outside the package at `F:\Deaglan\abe_jw\data\clean_names\`; step 0 now writes here directly, so no second copy is made. |
| `flags/ipums_fs_names_for_Deaglan1940.dta` | 5.0 GB | `histid` + `congruent`, 122,551,263 rows. `congruent == 0` flags 1940 records where the Ancestry and FamilySearch transcriptions **disagree** — this defines the "restricted" sample in linkages 1 and 2. Separated from the name extracts because it is a flag file, not names. |

### `data/transcriptions/` — `$D_TRANSCRIPT` and `$D_APPENDED`

The same data at two stages, now stored together:

| Path | Size | Origin |
|---|---|---|
| `shards/` | 40.6 GB | Four folders of 144 `norace<N>.dta` shards each, one per transcription vintage. The four source `.zip` archives are in `_archive/data/transfer_zips/`. |
| `appended/divided_file{1930,1940}_{ans,true}_cleaned_women_added.dta` | 42.8 GB | The shards appended, one file per vintage, by `code/prep/append_transfer.do`. 122,771,589 rows (1930) and 131,899,064 (1940) — men **and** women. Carry the census histid in a column named `id`, and the middle initial as `mi` or `mi_true_cleaned`. |

These two used to sit in different top-level folders (`transcriptions/` and
`Names/`) under different names, which hid the fact that one is simply the
appended form of the other.

### `data/links/` — `$D_LINKS` and `$D_LINKS_RAW`

Split by who produced it: `raw_hlink/` is third-party input, `derived/` is
everything this project made.

| File | Size | Origin |
|---|---|---|
| `raw_hlink/step{1,2}_matches_{before,after}.csv` | 33.5 GB | **Raw HLINK output, produced by a third party.** The matching itself was not done here. |
| `derived/matches_before.dta` / `matches_after.dta` | 4.7 / 4.8 GB | HLINK links, built by `code/02_hlink/build_matched_links.do` from the four step CSVs. 66,807,539 and 68,498,407 pairs. Vars: `histid1930 histid1940 probability`. |
| `derived/JW_matches_x2_unique_{new,old}.dta` | 1.0 GB each | Jaro-Winkler links. 13,478,232 / 12,670,605 pairs. Keys `Ahistid` / `Bhistid`. |
| `derived/link1930_1940_{true,ans}_cleaned_noraceblock0.dta` | 2.9 / 2.6 GB | ABE links. 18,198,099 / 16,946,362 pairs. Keys `id_A` / `id_B`, with `fiveyr_band`. Producing code was missing; reconstructed as `code/01_abe_jw/linkage/run_abe_match.do` and verified to reproduce these files exactly on Massachusetts — see Known gaps. |

### `data/truth/`

| File | Size | Origin |
|---|---|---|
| `mlp_training1930_1940.dta` | 2.6 GB | Ground-truth 1930→1940 links, used to classify every proposed pair as correct, contradicted, or unverifiable. Every one of the five tables depends on it. |
| `mlp_census_crosswalk_v2_0.stata.zip` | 16.0 GB | The **MLP census crosswalk v2.0** — one `.dta` of 62.3 GB uncompressed. Almost certainly the source `mlp_training1930_1940.dta` was extracted from. Kept compressed: nothing reads it directly. |

> **The extraction step is not in this package.** No script here derives
> `mlp_training1930_1940.dta` from the crosswalk, so the 1930→1940 subsetting
> is undocumented. The derived file is present and every table uses it, so
> nothing is blocked, but the provenance chain has a gap at this link.

### `abe_jw/data/` — the ABE/JW working tree

| Path | Size | Contents |
|---|---|---|
| `by_bpl/`, `by_bpl_new_transcription/` | 28 GB | One folder per birthplace, each with `clean_names_{1930,1940}.dta`. Direct input to both matchers. 136 birthplaces, 128,090,207 records |
| `full_census/`, `full_census_new_transcription/` | 38 GB | Prep-stage output plus `names/` — the men-only transcription shards the ABE/JW pipeline reads |
| `source_census/` | 21.4 GB | `matching_intgen{1930,1940}.dta`, copied in from `D:\ABE_JW\DATA\ORIGINAL`. Raw input to step 0; **not regenerable from anything in this package** |
| `matched/`, `matched_new_transcription/` | 10 GB | JW outputs at both age bands. `JW_matches_x2_unique` is also copied into `data/links/derived/` |
| `matched_abe_old/`, `matched_abe_new/` | 0.2 GB | Per-birthplace output from the reconstructed ABE matcher |

This tree sits at the project root rather than under `data/` because its scripts
`cd "$ABEJW"` and then use relative paths like `"data\matched\..."`. Preserving
its internal layout means one global (`ABEJW`) relocates the whole thing.

### `data/mortality/`

| Path | Size | Contents |
|---|---|---|
| `raw/bunmd_v2/bunmd_v2.csv` | 7.3 GB | Berkeley Unified Numident Mortality Database v2 |
| `raw/censoc_{numident,dmf}_v3.csv` | 1.2 GB | CenSoc public releases |
| `intermediate/` | 23 GB | Census with old and new names merged; title/nickname dictionaries |
| `working/` | 95.9 GB | Birthplace splits, cleaned names, 448 matched shards, four consolidated matched files. Renamed from `output_sam/`, which was named after a person and mixed inputs, logs, intermediates and outputs under a name suggesting it held only outputs. |
| `temp.dta` | 146 MB | BUNMD male denominator: 20,886,324 men, birth year ≤ 1940. Written by `04_post_match.do`, read by `05_make_linkage_table.do`. **Was written by a bare `save temp`** with no directory, so it landed wherever Stata happened to be started from; nothing in the pipeline `cd`s to `$D_MORT`, so writer and reader only agreed by accident. Now written explicitly to `$D_MORT/temp.dta`. |

---

## 3. Necessary files per table

Each table needs only a handful of files. Expensive matching output is kept on
disk deliberately, so tables rebuild in minutes-to-an-hour rather than the many
hours a re-match would cost.

**Table 1 — ABE / Jaro-Winkler** (`code/01_abe_jw/linkage_analysis.do`)
- `data/names/cleaned/clean_names_1930_old.dta`, `clean_names_1940_new.dta`
- `data/names/flags/ipums_fs_names_for_Deaglan1940.dta`
- `data/links/derived/JW_matches_x2_unique_{new,old}.dta`
- `data/links/derived/link1930_1940_{true,ans}_cleaned_noraceblock0.dta`
- `data/truth/mlp_training1930_1940.dta`

**Table 2 — HLINK** (`code/02_hlink/linkage_analysis_newlinks.do`)
- `data/transcriptions/appended/divided_file1930_ans_cleaned_women_added.dta`
- `data/transcriptions/appended/divided_file1940_true_cleaned_women_added.dta`
- `data/names/flags/ipums_fs_names_for_Deaglan1940.dta`
- `data/links/derived/matches_{before,after}.dta`
- `data/truth/mlp_training1930_1940.dta`

**Table 3 — Mortality** (`code/03_mortality/05_make_linkage_table.do`)
- `data/mortality/working/censoc_bunmd_matched_{old,new}names{,_conservative}.dta`
- `data/mortality/temp.dta` (denominator; rebuilt from `bunmd_v2.csv` if absent)

**Checked-in intermediate results.** `matches_*.dta` (10.3 GB) and the four
`censoc_bunmd_matched_*.dta` plus `temp.dta` (5.6 GB) are retained precisely so
the tables do not depend on re-running a match. Treat them as inputs.

---

## 4. How each table is built, and what the numbers mean

### Shared vocabulary (linkages 1 and 2)

Every proposed pair is compared against the ground-truth links and lands in one
of three buckets:

| Term | Meaning |
|---|---|
| **Verified correct** | The pair matches a ground-truth link. |
| **Directly contradicted** | The 1940 record *is* in the truth set, but linked to a different 1930 person. An outright error. |
| **Unverifiable** | The 1940 record does not appear in the truth set. Neither confirmed nor refuted — the truth set does not cover everyone. |
| **Match rate** | Linked pairs ÷ eligible population. |
| **Recall** | verified ÷ (verified + ground-truth pairs never proposed). |
| **MI match rate** | Among links with a middle initial observed on both sides, the share that agree. Middle initials are **not** used for matching, so this is an out-of-sample quality check. |

The **restricted** variants repeat everything on the subset where
`congruent == 0` — 1940 records whose Ancestry and FamilySearch transcriptions
disagree. That is where transcription quality should matter most, and it is where
the largest improvements appear.

### Table 2 detail — HLINK link cleanup

`build_matched_links.do` combines two rounds of HLINK output under one rule:
**step 2 supersedes step 1.** A step-1 pair survives only if *neither* of its
records appears anywhere in step 2, which catches both collision types — one 1930
record linked to two different 1940 records, and two 1930 records linked to the
same 1940 record.

### Table 3 detail — Mortality

| Term | Meaning |
|---|---|
| **Exact match** | ABE match on cleaned first name, cleaned last name, and harmonized birthplace, unique within a ±2-year birth-year window in both files. |
| **Conservative match** | Additionally drops records having *any* competing candidate within ±2 years of birth. |
| **Linkage rate** | Matches ÷ 20,886,324 BUNMD men with birth year ≤ 1940. |
| **Validation sample** | Links with a middle initial observed in both sources. |

---

## 5. Results

Rebuilt via `code/00_run_all_tables.do`; output in `output/tables/`.

### Reproducibility check, 2026-09-06

The full master was run end to end after the data reorganisation — a ~110 GB
move of the ABE/JW tree into the package, a restructure of `data/` by role, and
roughly 60 path changes. **All five tables came back byte-identical** to the
pre-reorganisation copies, with one exception that is not a number: the mortality
table's first line is a `%` comment naming the file, and the older copy still
carried the name it had before the table outputs were renamed. Every figure in
every table is unchanged.

This is the check that matters after a move of that size. Paths resolving
(`code/shared/verify_paths.do`) only proves files were found; reproducing the
numbers proves the *right* files were found.

Measured runtime, StataMP-64 15.1, ~3 cores, 12.6 GB peak:

| Stage | Time |
|---|---|
| 1/3 ABE + Jaro-Winkler | 88 min |
| 2/3 HLINK | 159 min |
| 3/3 Mortality | minutes |
| **total** | **4 h 07 m** |

### Mortality (`linkage_table_mortality_bunmd.tex`)

| | Old names | New names | Change |
|---|---|---|---|
| Exact matches | 5,754,061 | 6,165,698 | +7.15% |
| Exact linkage rate | 27.55% | 29.52% | +1.97 pp |
| Conservative matches | 4,286,765 | 4,621,152 | +7.80% |
| Conservative linkage rate | 20.52% | 22.13% | +1.60 pp |
| MI agreement (exact) | 82.54% | 84.70% | +2.16 pp |
| MI agreement (conservative) | 87.12% | 88.87% | +1.74 pp |

The new transcription links **more** records, and the extra links are **more**
accurate, not less — middle-initial agreement rises even as volume grows.

### HLINK (`linkage_table_hlink.tex`)

| | Old | New |
|---|---|---|
| Match rate | 58.08% | 59.55% |
| Recall | 78.48% | 79.88% |
| MI match rate | 86.11% | 86.34% |
| Verified correct | 28,357,041 | 28,863,711 |
| Directly contradicted | 293,078 | 296,657 |

Denominator 115,030,746 (1940 population aged 8+, men and women). Pair changes:
4,090,989 added, 2,400,121 removed, 309,900 changed, 64,097,518 unchanged. Of
links added, 27.7% verify correct against 1.6% contradicted; of links removed,
26.4% were correct against 2.4% contradicted — a favourable trade.

Restricted sample (`congruent == 0`, 35,550,163 people): 49.70% → 56.55%, a much
larger gain, as expected where the two transcriptions disagree.

### ABE / Jaro-Winkler (`linkage_table_abe_jw.tex`)

See `output/tables/`.

| | JW old | JW new | ABE old | ABE new |
|---|---|---|---|---|
| Match rate | 22.00% | 23.40% | 21.73% | 23.42% |
| MI match rate | 86.25% | 87.00% | 86.27% | 87.00% |
| Verified correct | 6,222,698 | 6,627,332 | 6,188,445 | 6,690,920 |
| Directly contradicted | 190,805 | 171,174 | 210,054 | 194,387 |
| Recall | 31.95% | 34.03% | 31.78% | 34.36% |

Both methods improve under the new transcription, and — as with the other two
linkages — the added links are disproportionately good: of links added, 42.3% (JW)
and 45.1% (ABE) verify correct against roughly 2% contradicted.

**Verified against the previous run.** This table reproduces the 2026-04-02
version (preserved in `_archive/output_previous/`) **exactly, in every cell**, despite the
script having been repointed from dead `D:` and `E:` paths onto the reorganized
tree. That makes it a complete regression test of the path repairs.

One caution for anyone repeating this check: the ground-truth file
`mlp_training1930_1940.dta` carries an mtime of 2026-08-18, four months *after*
that table was written, which suggests the truth set changed. It did not — the
timestamp records the file being **moved** during reorganization, not edited. An
mtime cannot distinguish a move from a content change; the reproduction of the
truth-dependent columns is what actually establishes the content is unchanged.

---

## 6. Known gaps and caveats

- **`build_matched_links.do` is a reconstruction.** The original was deleted. Its
  body was recovered verbatim from the command echo in
  `_archive/output_previous/build_matched_links.log`; its SETTINGS block was *not* in that
  echo and has been inferred from paths and counts in the run output. The file
  documents exactly which five values are inferred. Its logic was validated
  against the independent `prep_HLINK_matches.do` implementation: both produce the
  same pair set, matching to the row (66,807,539 / 68,498,407).
- **The ABE matcher is a reconstruction, but a validated one.** No script on any
  drive referenced `noraceblock`, the string in the ABE link filenames, so the
  code that produced `link1930_1940_*_noraceblock0.dta` is gone.
  `code/01_abe_jw/linkage/run_abe_match.do` reconstructs it; its header lists
  every inferred parameter and the basis for each.
  `linkage/validate_abe_reconstruction.do` then tests it against the originals
  by **pair**, not by count — counts are weak evidence, since different
  parameterisations can land on similar totals. On Massachusetts it reproduced
  the originals exactly: the identical 488,439-pair set, zero pairs on either
  side alone, and `f_name_A`, `l_name_A`, `f_name_B`, `l_name_B`, `fiveyr_band`,
  `mi1930`, `mi1940` all identical. One birthplace exercising every parameter on
  1.6M × 1.8M records is strong evidence for the parameter set; it is not proof
  that the other 135 reproduce. Whether `f_name_A` holds cleaned or raw names
  remains undetermined — the two are identical on every bpl-25 row, so the test
  could not discriminate, and output is the same either way.
- **The reconstruction has now also been run on the full count** (6.9 h, both
  vintages, zero birthplace failures). It reproduces 16,944,747 of 16,946,362
  pairs (old) and 18,197,078 of 18,198,099 (new) — 99.99%, and a **strict
  subset** both times, producing zero pairs the originals lack. **Every missing
  pair is a one-name join**: the 1930 record has a blank first or last name, and
  `run_full_census_prep.do` excludes it because a record with no initial cannot
  be blocked. In the originals those pairs are blank on the same field on both
  sides (`george <blank>` ↔ `george <blank>`), which is the only way an exact
  name matcher could have joined them. Diagnosed by
  `code/01_abe_jw/linkage/diagnose_abe_shortfall*.do`; see `LINKAGE_README.md`.
- **The original ABE links contain a small number of one-name links.** 845 (old)
  and 630 (new) of the pairs above carry `fiveyr_band == 1`, so they enter
  `linkage_table_abe_jw.tex`. Against 12.5M and 13.5M `fiveyr_band` pairs that is
  0.007% — far too small to move any published figure, and it appears on both
  sides of the old-vs-new comparison. Recorded because it is a property of the
  link files a reader should know, not because it changes a result.
- **HLINK matching is third-party.** The step CSVs in `data/links/raw_hlink/` were produced
  elsewhere. Only the link cleanup and the table analysis are ours.
- **`usa_00015.dat` is missing.** The IPUMS extract behind `marriage_status_1940.dta`
  is not on disk. Its *output* is, so no table is blocked. A file with the same
  extract number exists at `F:\Deaglan\Indicators\ipums_data\usa_00015.dta` — an
  unverified lead, not a confirmed match.
- **One live dependency outside the package:**
  `D:\ABE_JW\DATA\ORIGINAL\matching_intgen1940.dta`, referenced by
  `000_merge_new_census_vars.do`. Provenance only — its output is in `data/census/`.
- **`code/03_mortality/README_original.md` is superseded.** It documents pipeline
  steps 0-4 and predates `05_make_linkage_table.do`, so the table it produces
  appears nowhere in it, and its path examples are stale. Kept as a historical
  record of the mortality pipeline's design; this file is authoritative.
- **`linkage_table_newlinks*.tex` (in `_archive/`) is not comparable to
  `linkage_table_hlink*.tex`.** It came from a retired script with a settings block
  (`dedup_rule "prob"`, `unique1940`) that the current script dropped in favour of
  `duplicates drop histid1930, force`. A methodological difference, not a
  relabelling.
- **Transcription shard naming — partially resolved.** `data/transcriptions/`
  holds `divided_file{1930,1940}_{ans,true}_cleaned_women_added`, while the ABE/JW
  working tree at `$ABEJW/data/full_census/names/` holds
  `divided_file{1930,1940}_{ans,true}_cleaned` — the same four names *without* the
  `_women_added` suffix. So these are two genuinely distinct vintages, not a
  naming inconsistency: the ABE/JW pipeline filters to males, so its shards are
  the men-only originals, and the `_women_added` set is the later expansion used
  by the HLINK table. `code/03_mortality/0_merge_new_names.do` reads the
  unsuffixed names, i.e. the ABE/JW vintage. Still unaccounted for: that script
  also wants `divided_file1940_true_cleaned_third_batch`, which exists in neither
  location. Off every table path either way.
- **`vendor/censocdev-master/` declares no license.** It is an unmodified GitHub
  ZIP of the UC Berkeley CenSoc `censocdev` R package (Breen, Alexander, Joo,
  Goldstein, Yildirim, Osborne). The mortality `.do` files are a Stata port of its
  `codebase/02_create_censoc/` scripts. Resolve licensing before redistributing.
- **Denominator naming.** The HLINK script's `N_men_1940_full` scalar now holds a
  whole-population count, not a men-only one, because the linked files include
  women. The value is correct; the name is stale, as is the "all men in the 1940
  census" phrasing in the table captions.

---

## 7. Archived material

`_archive/` (187 GB) — nothing deleted, nothing needed to rebuild a table.

| Path | Size | Why |
|---|---|---|
| `abe_jw/data/clean_names/` | 21.2 GB | All four files are byte-size-identical duplicates of `data/names/cleaned/`. Step 0 now writes to `data/names/cleaned/` directly, so this second copy is no longer produced |
| `abe_jw/data/full_census/for_Deaglan_Feb15_2026.zip` | 10.9 GB | Delivery archive; its contents are unpacked in `full_census/` |
| `abe_jw/data/BlocksAtoB/` | 7,801 files | Transient block scratch from a Feb 2026 run; regenerated by the matcher |
| `abe_jw/data/raw_census/` | 1.7 GB | Delaware/Pennsylvania synthetic extracts for the small-scale demo pipeline. Regenerable by `linkage/00_create_synthetic_dataset.do` |
| `abe_jw/abe_comparison/` | 0.1 GB | Its `.do`/`.ado` files duplicate `code/01_abe_jw/`; the remaining 12,000 files are transient block and `parallel` scratch |
| `abe_jw/abe_original_code/`, `abe_jw/code/` | — | Byte-size-identical duplicates of `code/01_abe_jw/reference/` and `code/01_abe_jw/linkage/`. **Note:** `abe_jw/code/ado/` was referenced by the JW runner as `"code\ado\..."`; those 15 references now point at `$C_ABEJW/ado/` |
| `hlink/Names_census/` | 24.1 GB | Names × census merge; no code produced or consumed it |
| `hlink/step1_step2_merged_*` | 30.0 GB | Output of `prep_HLINK_matches.do`; read by nothing |
| `code/prep_HLINK_matches.do` | — | Superseded parallel implementation of the link cleanup |
| `data/matched_links_intermediate/` | 40.8 GB | Intermediates from the retired newlinks generation |
| `data/mortality_new_pipeline/` | 1.1 GB | Abandoned candidate-pair linkage attempt; no code on disk |
| `data/transfer_zips/`, `Transfer.zip` | 47.4 GB | Source archives, already unzipped |
| `data/census_raw.7z` | 5.4 GB | Duplicate of `data/census/` contents |
| `data/usa_00021.dta.gz` | 7.3 GB | Compressed source of `1930_1940_full_w_women.dta` |
| `data/stray_mortality_copies_from_Matched_Links/` | 2.4 GB | Older duplicates of two mortality outputs |
| `code/mortality_old_code/`, `mortality_replication_temp/` | — | Two superseded generations of the mortality pipeline |
| `code/post_match_STRAY_from_F_log.smcl` | — | Log written outside the project by the `$log_dir` bug, since fixed |
| `output_previous/` | 150 KB | Tables and logs from runs predating the reorganization, kept for comparison. Includes the 2026-04-02 ABE/JW table that the current run reproduces exactly, and `build_matched_links.log`, the only surviving source of that script. |
