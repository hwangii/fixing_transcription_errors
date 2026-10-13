# Codex review

*Rendered 2026-10-02 15:16. Source: `review/reports/2026-10-02_150627-Census_Transcriptions-full-codex.json`*

**Dimensions:** correctness, claims-vs-code, replication, identification

**Result:** 1 blocker, 5 major, 2 minor

## Summary

The saved logs support successful generation of all five tables, but HLINK’s reported match rates include links outside the denominator population. Fix that sample mismatch first: the logs establish discrepancies that change all four displayed HLINK rates. Sample captions, validation claims, and upstream replication gaps also need correction before these tables enter the paper.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | BLOCKER | verified | HLINK counts links outside its eligible denominator population | `F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:179-198, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:259-271, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2500-2506, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2550-2556, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2729-2735, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2785-2791` | **CONFIRMED** — log counts verified exactly; ~0.04% of pairs, but wrong by construction |
| 2 | MAJOR | verified | Captions and documentation describe different populations from those tabulated | `F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:36-54, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:388-394, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:179-198, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:490-495, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:226-232, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:366, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:408-445` | **CONFIRMED** — same as Antigravity #2 |
| 3 | MAJOR | likely | Mortality link counts do not enforce the denominator’s sex and birth-year restrictions | `F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:31-64, F:/Deaglan/Census_Transcriptions/code/03_mortality/01_run_clean_names.do:24-29, F:/Deaglan/Census_Transcriptions/code/03_mortality/00_master_run_all.do:91-92, F:/Deaglan/Census_Transcriptions/code/03_mortality/03_match.do:56-59` | **CONFIRMED structurally** — numerator carries no sex/byear filter; magnitude needs data |
| 4 | MAJOR | verified | The package does not establish the provenance or independence of its truth benchmark | `F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:69-77, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:142-149, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:294-313, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:70, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:104-105, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:541` | **CONFIRMED** — Deaglan's own §2 says the extraction step is absent; independence from HLINK training unestablished |
| 5 | MAJOR | verified | Higher aggregate initial agreement is presented as proof that added mortality links are more accurate | `F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:206-214, F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:49-75` | **CONFIRMED** — doc text at :213-214 draws the conclusion; script measures all links, not added ones |
| 6 | MAJOR | verified | Upstream reconstruction still needs missing inputs and obsolete working-tree paths | `F:/Deaglan/Census_Transcriptions/code/03_mortality/000_import_new_census_vars.do:4-20, F:/Deaglan/Census_Transcriptions/code/03_mortality/0_merge_new_names.do:10-48, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/comparison/00_run_all_comparisons.do:23-46, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:306-332` | **CONFIRMED** — same as Antigravity #4 |
| 7 | minor | verified | Successful table generation is documented, but the claimed equality checks lack accessible audit evidence | `F:/Deaglan/Census_Transcriptions/README.md:17-22, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:179-191, F:/Deaglan/Census_Transcriptions/code/00_run_all_tables.do:41-50, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:3502-3505, F:/Deaglan/Census_Transcriptions/code/02_hlink/build_matched_links.do:18-34` | **CONFIRMED** — same as Antigravity #8 |
| 8 | minor | verified | Published ABE counts retain blank-name links excluded by the reconstructed pipeline | `F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:115-126, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage/diagnose_abe_shortfall_step3.do:43-72, F:/Deaglan/Census_Transcriptions/output/logs/diagnose_abe_shortfall_step3.log:276-283, F:/Deaglan/Census_Transcriptions/output/logs/diagnose_abe_shortfall_step3.log:307-314, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:298-303` | **ACCEPTED** — Deaglan's §6 already records the 845/630 one-name links |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. HLINK counts links outside its eligible denominator population

`hlink-numerator-outside-denominator` · **BLOCKER** · correctness · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:179-198, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:259-271, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2500-2506, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2550-2556, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2729-2735, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2785-2791`

**What the code does**  
Questions 1 and 2: the denominator counts 1940 name-file records satisfying `age >= 8`, intersected with `congruent == 0` for the restricted sample. The numerator is `N_linked = _N` after pair deduplication; the restricted numerator intersects only with the congruence list, not the age-eligible denominator file. Later merges to `cn1940_full` expose 25,765 old and 26,744 new numerator pairs outside that population; restricted merges expose 6,377 and 7,538. Deduplication at line 93 removes identical pairs, line 218 concerns truth pairs, and lines 356/368 deduplicate 1930 IDs only for the subsequent change comparison. None establishes unique eligible 1940 IDs before computing the rate.

**Why it matters**  
Holding the existing pair-count convention fixed, enforcing denominator membership changes full rates from 58.08/59.55 to 58.06/59.52 and restricted rates from 49.70/56.55 to 49.68/56.53. Excluded-population links also enter the unverifiable category because truth is filtered to the denominator population. Contrary to the scope’s proposed assurance, the current code does not guarantee rates at or below 100%: multiple distinct pairs per 1940 ID can still inflate `_N`.

**How to check**  
Before each rate calculation, merge numerator histid1940 against the corresponding cn1940_full or cn1940_restr ID list and tabulate unmatched pairs. Run `duplicates report histid1940`, count distinct eligible histid1940, and compare that count with the saved denominator.

**Suggested fix**  
Construct explicit eligible full/restricted 1940 ID sets and use them consistently for rates, classification, and pair changes. Count distinct eligible 1940 IDs for population coverage; retain pair counts separately. Assert population membership and the coverage bound, and explicitly exclude missing ages if they are ineligible.

---

### 2. Captions and documentation describe different populations from those tabulated

`sample-descriptions-conflict` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:36-54, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:388-394, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:179-198, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:490-495, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:226-232, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:366, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:408-445`

**What the code does**  
ABE/JW uses the men-only cleaned-name file and `age >= 8`: 57,589,273 full records and 15,003,537 restricted records. HLINK uses the women-added file without a sex restriction: 115,030,746 full records and 30,754,309 restricted records. All four census-table captions omit the age restriction, and both HLINK captions incorrectly say men. DOCUMENTATION.md instead gives 35,550,163 for the restricted HLINK population. The draft retains age-10 descriptions at lines 366, 408, 424, and 445.

**Why it matters**  
Readers would compare coverage across different sexes and populations as though denominators were common. The documented restricted HLINK denominator cannot reproduce the displayed rates. The draft’s existing sample descriptions cannot accompany the new tables unchanged.

**How to check**  
Compare the denominator merges in output/logs/00_run_all_tables.log:431-436 and :2116-2121 with DOCUMENTATION.md:231. Search the four generated captions for `men`, and the draft for `aged 10` and `under age 10`.

**Suggested fix**  
State each table’s actual eligible population and denominator count, including age 8+, sex coverage, and availability in the relevant name file. Correct the restricted HLINK count to 30,754,309 for this run. Implement the agreed age-8 draft revision, recomputing any affected descriptive statistics rather than merely relabeling them.

---

### 3. Mortality link counts do not enforce the denominator’s sex and birth-year restrictions

`mortality-eligibility-unenforced` · **MAJOR** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:31-64, F:/Deaglan/Census_Transcriptions/code/03_mortality/01_run_clean_names.do:24-29, F:/Deaglan/Census_Transcriptions/code/03_mortality/00_master_run_all.do:91-92, F:/Deaglan/Census_Transcriptions/code/03_mortality/03_match.do:56-59`

**What the code does**  
Questions 1 and 5: mortality divides matched-row counts by 20,886,324 BUNMD records selected using `sex == 1 & byear <= 1940`. The numerator loads only timediff and initial fields, drops missing timediffs, and counts rows without deduplication or denominator membership checks. Upstream BUNMD preparation imports all rows; matching variables are `fname_cleaned lname_cleaned bpl_h`, with no sex restriction or explicit birth-year eligibility filter. Whether saved links actually include ineligible deaths requires data inspection.

**Why it matters**  
This is a third denominator definition, not census coverage at age 8+. Female BUNMD records or records born after 1940 could contribute to a numerator divided by eligible men only; age-tolerant matching does not itself establish birth-year eligibility. Repeated matched death IDs could also inflate a person-level linkage rate.

**How to check**  
For each consolidated match file, retain matched BUNMD IDs, merge them to ssn/sex/byear in the raw BUNMD input, and count `sex != 1`, `byear > 1940`, missing birth years, and duplicated matched death IDs.

**Suggested fix**  
Define an eligible BUNMD ID file once and enforce it on both matching inputs and tabulation. Count distinct eligible death IDs for coverage and assert uniqueness where one-to-one matching is intended. Preserve the table’s explicit BUNMD-based denominator description.

---

### 4. The package does not establish the provenance or independence of its truth benchmark

`reference-truth-provenance-unestablished` · **MAJOR** · identification · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:69-77, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:142-149, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:294-313, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:70, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:104-105, F:/github_repos/6638fa0fd89fbec05130caeb/DHTS-2024-11-18.tex:541`

**What the code does**  
Question 3: classification establishes agreement or disagreement with `mlp_training1930_1940.dta`, conditional on the 1940 ID appearing in the filtered reference. Documentation says its source is 'almost certainly' the MLP crosswalk and supplies no extraction script or validation protocol. No inspected artifact establishes whether these records were excluded from HLINK training. The draft claims independent genealogical confirmation while its validation section says results are forthcoming.

**Why it matters**  
Reference agreement supports a conditional benchmark result, not independently established correctness for all links. Training overlap, reference errors, or selective reference coverage could affect interpretation, especially within the transcription-disagreement sample. These possibilities are not established defects in the data, but independence and accuracy claims presently lack the necessary evidence.

**How to check**  
Locate the exact reference release and extraction specification, document its construction, and tabulate overlap with HLINK training/evaluation IDs. Identify the completed analysis supporting the draft’s genealogical-confirmation sentence.

**Suggested fix**  
Archive a reproducible reference extraction and document validation, coverage, and training overlap. Until independence is established, label categories as agreement/conflict with the reference and report recall conditional on that reference. Remove or qualify claims of completed independent validation that the available analysis does not support.

---

### 5. Higher aggregate initial agreement is presented as proof that added mortality links are more accurate

`aggregate-initial-agreement-overclaim` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:206-214, F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:49-75`

**What the code does**  
The script separately selects each vintage’s links with nonblank initials and computes `lower(mi) == lower(mname_B)`. It neither isolates newly added pairs nor evaluates them against independent truth. Nevertheless, documentation concludes that 'the extra links are more accurate, not less'. Both the linked population and the census initial field change between vintages.

**Why it matters**  
Aggregate agreement can rise because retained links have differently transcribed initials, low-agreement links disappear, or the nonmissing-initial sample changes. It does not identify the accuracy of added links, and initial agreement itself is a proxy rather than observed correctness.

**How to check**  
Join old and new links by pair IDs, classify retained/added/removed pairs, and report initial agreement and initial availability separately for each group. Repeat using a fixed census initial source and a common eligible population.

**Suggested fix**  
Describe the result as higher aggregate middle-initial agreement. Add pair-transition analysis and an independent validation sample before asserting that the additional links are more accurate.

---

### 6. Upstream reconstruction still needs missing inputs and obsolete working-tree paths

`upstream-inputs-and-paths-incomplete` · **MAJOR** · replication · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/code/03_mortality/000_import_new_census_vars.do:4-20, F:/Deaglan/Census_Transcriptions/code/03_mortality/0_merge_new_names.do:10-48, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/comparison/00_run_all_comparisons.do:23-46, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:306-332`

**What the code does**  
Question 6: mortality imports the absent `$D_CENSUS/usa_00015.dat` and reads a missing `divided_file1940_true_cleaned_third_batch` directory. Its old-name input is also a bare relative directory, although that vintage exists under `$ABEJW/data/full_census/names`. The comparison master changes into absent `$ABEJW/abe_comparison` and looks for dependencies in absent `../abe_original_code`. The demo’s raw_census and clean_names inputs are absent at their expected paths but have supplied producer scripts. All immediate inputs to the five table scripts were found. The purported external D:/ABE_JW source dependency is stale documentation: both source census files are present under `$ABE_SRC`.

**Why it matters**  
The aggregation layer can run from retained intermediates, but the package cannot currently reconstruct all upstream analyses from the supplied inputs and documented paths. Substituting another new-name vintage for the missing third batch could change the mortality comparison.

**How to check**  
List the named paths without opening datasets. Compare mortality’s relative input directories with the directories under abe_jw/data/full_census/names. Check comparison/00_run_all_comparisons.do against the current code and working-tree layout.

**Suggested fix**  
Recover and identify the exact mortality raw extract and third-batch transcription input, or explicitly delimit replication to retained intermediates. Replace bare mortality paths with configured vintage-specific paths. Repair the comparison runner’s working-directory and dependency references, and document the demo regeneration order.

---

### 7. Successful table generation is documented, but the claimed equality checks lack accessible audit evidence

`reproducibility-comparison-evidence-missing` · **minor** · replication · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/README.md:17-22, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:179-191, F:/Deaglan/Census_Transcriptions/code/00_run_all_tables.do:41-50, F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:3502-3505, F:/Deaglan/Census_Transcriptions/code/02_hlink/build_matched_links.do:18-34`

**What the code does**  
Question 4: the master invokes the three table scripts and prints 'all tables rebuilt into output/tables/'. Its log records the five output writes, but neither master nor log performs a byte comparison, hash comparison, or comparison with prior tables. The HLINK reconstruction names five inferred settings and asserts pair-set equality with prep_HLINK_matches.do, but the independent implementation and original producing log are archived, outside the permitted content-review scope; no accessible comparison log establishes that assertion.

**Why it matters**  
The evidence supports a completed aggregation run, not independently verified byte identity or an audited independent HLINK reconstruction. This does not show the equality claims are false; it makes them unverifiable from the allowed evidence.

**How to check**  
Provide the saved comparison report or compare current and previous table bytes, explicitly handling the mortality filename comment. For HLINK, compare both implementations by the full pair key and report unmatched pairs in each direction, rather than only equal totals.

**Suggested fix**  
Archive comparison commands, input/output hashes, and results alongside the logs. Make the independent HLINK implementation and its comparison evidence available in the active validation tree.

---

### 8. Published ABE counts retain blank-name links excluded by the reconstructed pipeline

`blank-name-abe-links-retained` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:115-126, F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage/diagnose_abe_shortfall_step3.do:43-72, F:/Deaglan/Census_Transcriptions/output/logs/diagnose_abe_shortfall_step3.log:276-283, F:/Deaglan/Census_Transcriptions/output/logs/diagnose_abe_shortfall_step3.log:307-314, F:/Deaglan/Census_Transcriptions/DOCUMENTATION.md:298-303`

**What the code does**  
The table reads original links and filters only on `fiveyr_band == 1`; it retains 845 old and 630 new links from the diagnosed blank-name shortfall. Diagnostics establish blank-on-blank fields, not that those links are false. Moreover, the blank-field counts imply 123 old and 135 new shortfall pairs have both name fields blank, so 'one-name' does not describe every pair.

**Why it matters**  
The originals and reconstructed pipeline implement different name-eligibility rules. The statement that this cannot move 'any published figure' is too strong: the tables publish integer category counts, whose sums necessarily change when these links are removed, even if rounded rates barely move.

**How to check**  
In each original link file, tabulate `fiveyr_band` against missing first name, missing surname, and both missing. Repeat all table panels with a common nonblank-name rule and compare counts and rounded percentages.

**Suggested fix**  
Use a consistent nonblank first-and-last-name rule for the primary comparison, or explicitly retain the historical rule and report the exclusion sensitivity. Do not equate blank-name links with proven false links or claim numerical invariance without comparing the regenerated cells.

---

## Checked and sound

- **Question 3: the three reference classifications form a partition and unverifiable links are not counted as verified** — F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:170-189 and F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:294-313 classify unmatched reference IDs as unverifiable and matched IDs by equality versus inequality of the 1930 ID. Recall uses verified/(verified+FN). Added and removed unverifiable links are explicitly labeled Neutral at linkage_analysis.do:423-428 and output/tables/linkage_table_hlink.tex:21-26. This verifies the conditional calculation, not reference accuracy.
- **Question 4: the master targets the five advertised outputs and the saved run reaches completion** — F:/Deaglan/Census_Transcriptions/code/00_run_all_tables.do:41-48 calls all three table scripts. F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:1717-1721, :3007-3011, :3494-3505 records the five output writes and completion. All five files exist and their reported main counts agree with the logged calculations.
- **Middle-initial agreement calculations exclude empty strings on both sides** — F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage_analysis.do:202-207, F:/Deaglan/Census_Transcriptions/code/02_hlink/linkage_analysis_newlinks.do:326-331, and F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:67-74 explicitly require nonempty initials before equality counting. Empty-string equality does not inflate these reported agreement rates.
- **ABE reconstruction checks compare pair identities, not only totals** — F:/Deaglan/Census_Transcriptions/code/01_abe_jw/linkage/validate_abe_reconstruction.do:121-171 compares pair keys and seven fields; output/logs/validate_abe_reconstruction.log:360-417 reports 488,439 shared Massachusetts pairs, zero exclusive pairs, and identical fields. Full-count totals appear at output/logs/run_abe_match.log:2124-2128 and :3372-3376. The shortfall merge and name diagnostics establish the reported missing-pair counts and blank-field pattern; the saved direction check explicitly establishes the old-vintage subset at output/logs/diagnose_abe_shortfall.log:309-320.
- **The retired over-100% rates are numerically explained by using men-only denominators with HLINK pair counts** — F:/Deaglan/Census_Transcriptions/output/logs/00_run_all_tables.log:2454-2460 and :2671-2683 gives HLINK numerators 66,807,539/68,498,407 and 15,284,570/17,391,446. Dividing by the ABE/JW denominators 57,589,273 and 15,003,537 reproduces exactly the scope’s retired rates after rounding: 116.01/118.94 and 101.87/115.92. The current HLINK denominators are larger, while its later 1930-ID dedup removes zero rows in this run (:2571-2583 and :2812-2830). Thus later deduplication is not an evidenced explanation for the rate reduction; archived implementation details remain unreviewed.
- **Question 6: the alleged external source-census path and commented author path are not live external data dependencies** — F:/Deaglan/Census_Transcriptions/code/03_mortality/000_merge_new_census_vars.do:1-3 uses `$ABE_SRC/matching_intgen1940`; code/shared/paths.do:98-107 places both source extracts inside ROOT, and directory listings confirmed both files. The C:/Users path at code/01_abe_jw/comparison/abeclean.ado:518 is inside the block comment starting at :516. The code-wide absolute-path search otherwise found ROOT bootstrap literals and documentation/examples, not another active hardcoded external data input.
- **Question 5: mortality explicitly documents a distinct BUNMD denominator and does not use the census reference-link file** — F:/Deaglan/Census_Transcriptions/code/03_mortality/05_make_linkage_table.do:31-43 and :201-204 defines BUNMD men born by 1940 and conditional initial agreement; output/logs/00_run_all_tables.log:3219 records 20,886,324. There is no age-8 or congruence restriction and no mlp_training input. This contradicts DOCUMENTATION.md:71’s incidental assertion that all five tables depend on that reference file, but the mortality table itself identifies its denominator.

## What this review could not establish

- No files were modified and no pipeline, Stata command, or data-processing program was run. The approximately 325 GB of data was not opened; directory listings were used only to establish input existence. The roughly four-hour master was not rerun.
- HLINK links cannot be regenerated within this review: third-party matching code and configuration are unavailable in the package, and the HLINK/PySpark internals were excluded.
- The governing scope excludes all archived content beyond existence checks. Consequently, the retired HLINK implementation, original reconstruction command echo, previous tables, and archived prep_HLINK_matches.do could not be inspected. The historical denominator explanation is an exact numerical reconciliation, not a direct trace of the retired script.
- The mortality eligibility concern is traced to missing restrictions in source; the number of affected saved links, their sex distribution, and person-key uniqueness require data access. Missing-age prevalence and reference-key validity were not independently measured.
- The draft currently incorporates none of these five package tables. Its existing effect sizes were not treated as proven incorrect merely because they differ from this package’s results; their original producing analyses and included figures were outside this review.
- Review covered the active table calculations, supporting preparation and matching paths, diagnostics, documentation, generated tables, and available logs. Auxiliary matching code was inspected selectively; this is not a line-by-line certification of every helper or a runtime validation of Stata semantics. Vendored/reference implementations were not reviewed.

## Claude's verification (2026-10-02)

Codex (gpt-5.6 via `codex exec`, read-only sandbox, 200k tokens, zero policy
rejections, zero web searches) on the identical prompt Antigravity received.
Every finding was checked against the source before acceptance.

### 1. HLINK numerator includes links outside the denominator — CONFIRMED

`prep_links` (`:84-94`) keeps every pair in the link file and applies no
population filter. For the full sample, Part 1 (`:259-271`) never merges the
numerator against `cn1940_full` (the age-8+ names file) before
`N_linked = _N`; only the restricted sample intersects with the congruence
list — and that list, not the age-eligible file. The master log's later merges
show exactly what falls outside: **25,765** (old) and **26,744** (new) full-
sample pairs, **6,377** and **7,538** restricted (`00_run_all_tables.log:2502,
2552, 2731, 2787`, "not matched from master"). Against 66.8M pairs that is
~0.04%, so the printed rates move in the fourth decimal — but the numerator is
wrong by construction, and together with Antigravity's finding that it is a
*pair* count, the correct numerator is *unique, eligible* `histid1940`. One
fix covers both: merge against the denominator file, keep `first40 == 1`,
then count.

### 3. Mortality numerator unrestricted — CONFIRMED structurally, magnitude open

`05_make_linkage_table.do:38-42` builds the denominator from BUNMD rows with
`sex == 1 & byear <= 1940`; `:58-64` counts every row of the matched file
with non-missing `timediff`, with no sex, birth-year or uniqueness filter.
Whether ineligible deaths were actually linked needs the data; the structure
permits it.

### 4. Truth benchmark provenance and independence — CONFIRMED

`DOCUMENTATION.md:69-77` says the extraction of `mlp_training1930_1940.dta`
"is not in this package" and the crosswalk is "almost certainly" its source.
Codex adds the sharper point: the file is literally named *training*, and
HLINK is the IPUMS MLP method. If the truth set overlaps HLINK's training data,
evaluating HLINK links against it is circular. Nothing in the package rules
that out. The draft (`DHTS-2024-11-18.tex:70, :104-105`) claims independent
genealogical confirmation; the package does not supply it.

### 5. "Extra links are more accurate" — CONFIRMED as an overreach

`DOCUMENTATION.md:213-214` concludes the added mortality links are more
accurate because middle-initial agreement rises. `05_make_linkage_table.do:
49-75` computes MI agreement over *all* links of each vintage, never isolating
the added pairs. Rising aggregate agreement is consistent with the added links
being *worse* than average if the retained ones improved. Do not carry that
sentence into the paper without the retained/added/removed split.

### The one disagreement: Question 3

Codex's `verified_clean` passes Q3 ("the three classifications form a
partition and unverifiable links are not counted as verified"). Antigravity's
#1 flags the same block as one-sided. **Both statements are true and
Antigravity's finding stands**: the partition is exhaustive and Unverifiable is
never counted as Verified — but the merge at `:295` is on `histid1940` only,
so a wrong link whose 1940 record is outside the truth set is called
Unverifiable even when the truth set pairs its 1930 record with someone else.
Codex answered the narrower question. Not a contradiction; a gap in coverage.

### Agreement with Antigravity

Six of eight issues are shared in substance: captions vs populations, the
BUNMD denominator, external/missing inputs, the unsupported byte-identical
claim, the truth-benchmark provenance, and (via #1 and Antigravity's #6) the
HLINK numerator. Unique to Codex: the numerator-outside-population count and
the mortality "more accurate" overreach. Unique to Antigravity: the one-sided
truth check, missing ages retained by `age >= 8`, and the linked-sample
upper-bound caveat. Combined, the two reviews cover more than either alone,
which is the point of running both.
