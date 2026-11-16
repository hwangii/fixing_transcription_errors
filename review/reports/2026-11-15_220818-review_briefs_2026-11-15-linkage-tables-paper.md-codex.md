# Codex review

*Rendered 2026-11-15 22:13. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-15_220818-review_briefs_2026-11-15-linkage-tables-paper.md-codex.json`*

**Dimensions:** claims-vs-code, correctness

**Result:** 1 major, 1 minor

## Summary

The rebuilt linkage counts, rates, sample restrictions, contradicted-share arithmetic, and slide rounding agree with the new tables and code. The principal remaining problem is interpretive: the headline 28 percent “match quality” improvement compares old and new links using different 1940 middle-initial validators, so it does not measure a pure change in link quality. Panel B also labels only net entries and exits from linkage as added and removed pairs, omitting changed partners.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | The headline 28 percent match-quality improvement switches the validating transcription between old and new links | `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:68, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:97-99, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:548-553, LINKAGE/code/01_abe_jw/linkage_analysis.do:242-254, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:367-386, replication/diagnostics/validation_fixed_initials.do:109-139` || Accepted risk: pre-existing headline framing, unchanged by this edit and disclosed in the body (lines 549-553) and now in Sec. 4.2 and the table notes. Whether abstract/intro should lead with the fixed-validator estimate is the author's call; raised with the author 2026-11-15. |
| 2 | minor | verified | Panel B calls net linkage entries and exits added and removed pairs while omitting partner changes | `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:605, LINKAGE/code/01_abe_jw/linkage_analysis.do:316-323, LINKAGE/code/01_abe_jw/linkage_analysis.do:353-394, LINKAGE/code/01_abe_jw/linkage_analysis.do:518-528, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:428-435, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:465-490, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:580-590` || Fixed: same note change as agy #2. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. The headline 28 percent match-quality improvement switches the validating transcription between old and new links

`moving-validator-called-match-quality` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:68, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:97-99, D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:548-553, LINKAGE/code/01_abe_jw/linkage_analysis.do:242-254, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:367-386, replication/diagnostics/validation_fixed_initials.do:109-139`

**What the code does**  
For old links the code sets `miv` to `mi_anc`, while for new links it sets `miv` to `mi_ml`, then computes `count if mi1930 == mi1940`. Thus the reported 65.4-to-83.6 percent comparison changes both the linked pairs and the 1940 value used to validate them. The repository's fixed-validator diagnostic shows that the 18.2 percentage-point own-initial rise decomposes into only 10.3 points when Ancestry's initial is held fixed, or 8.4 points when FamilySearch's is held fixed; the remaining 7.9 or 9.8 points arise from changing the transcription of the validator itself.

**Why it matters**  
The abstract and introduction describe the full 28 percent relative rise as improved “match quality,” although roughly half of the percentage-point increase is mechanically due to rescoring links against the model's own different reading of the middle initial. The body discloses this decomposition, but the headline claim still overstates the independently measured improvement in link quality.

**How to check**  
Run `replication/diagnostics/validation_fixed_initials.do` and inspect `replication/results/validation_fixed_initials.tex`, especially `ppTotalTarget`, `ppLinksAncTarget`, `ppReadingAncTarget`, `ppLinksFsTarget`, and `ppReadingFsTarget`. Compare those results with the 65.4 and 83.6 percent headline rates.

**Suggested fix**  
State the fixed-validator result in the abstract and introduction as the link-quality estimate, identifying which fixed source is used. Retain the 65.4-to-83.6 comparison only under an explicit label such as “own-transcription middle-initial agreement,” separate from link quality.

---

### 2. Panel B calls net linkage entries and exits added and removed pairs while omitting partner changes

`panel-b-omits-changed-partners` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:605, LINKAGE/code/01_abe_jw/linkage_analysis.do:316-323, LINKAGE/code/01_abe_jw/linkage_analysis.do:353-394, LINKAGE/code/01_abe_jw/linkage_analysis.do:518-528, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:428-435, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:465-490, LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:580-590`

**What the code does**  
The code classifies a 1930 person linked in both versions to different 1940 partners as `status = "changed"`. It then builds the displayed Added rows only from `status == "net_added"` and Removed rows only from `status == "net_removed"`; changed links are calculated separately but never written to Panel B. The paper note instead says Panel B “decomposes the pairs added and removed when moving from the old transcription to the new,” even though a changed partner entails one removed pair and one added pair that the panel excludes.

**Why it matters**  
Panel B understates total pair turnover and does not describe the composition of all pairs added and removed. Its displayed added-minus-removed category counts therefore need not reconcile the changes in Panel A, potentially misleading readers who interpret it as a complete pair-level decomposition.

**How to check**  
After the `tab status` commands, tabulate `status` for each method and sample and compare the number of `changed` observations with the displayed Panel B totals. Reconcile `new pairs - old pairs` both with and without treating each changed observation as one added and one removed pair.

**Suggested fix**  
Either relabel Panel B and its note as a decomposition of 1930 persons newly linked versus no longer linked, explicitly excluding partner switches, or include changed partners as one removed old pair and one added new pair and regenerate the category totals.

---

## Checked and sound

- **All updated paper and slide numbers match the four rebuilt linkage tables.** — The prose at D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:108 and 566-585 matches the source tables at D:/repos/6638fa0fd89fbec05130caeb/linkage_tables/linkage_table_abe_jw.tex:12-17, linkage_table_abe_jw_restricted.tex:12-17, linkage_table_hlink.tex:12-17, and linkage_table_hlink_restricted.tex:12-17. Slide counts are correctly rounded at D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:384-417.
- **The claim that contradicted-link shares fall in all six old-new comparisons is arithmetically correct.** — Using contradicted/(verified+unverifiable+contradicted) on the table rows gives JW full 2.43% to 2.03%, ABE full 2.74% to 2.32%, JW restricted 4.08% to 2.24%, ABE restricted 5.09% to 2.56%, HLINK full 0.70% to 0.68%, and HLINK restricted 0.74% to 0.69%, matching D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:585.
- **The full and restricted samples use the stated common denominators.** — Both table scripts load the same `linkage_sample1940.dta`, count all rows, and restrict the second sample with `keep if target == 1` at LINKAGE/code/01_abe_jw/linkage_analysis.do:61-80 and LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:196-213. The builder asserts 51,036,859 total and 14,416,543 target records at LINKAGE/code/prep/build_linkage_sample1940.do:29-31 and 58-67.
- **Candidate-link numerators are restricted to the corresponding denominator population.** — The ABE/JW script retains only merge matches to `den1940_`samp'' at LINKAGE/code/01_abe_jw/linkage_analysis.do:171-175 and 206-210; HLINK does the same at LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:299-304 and 337-342.
- **The target definition uses complete Ancestry and FamilySearch name fields rather than allowing blank-string equality.** — The upstream producer keeps only records with all four names nonempty and both ages nonmissing at CODE/clean_FS_and_combineV5_nber.do:193-225. The sample builder then defines `target = !(namefrst==namefrst_fs & namelast==namelast_fs)` at LINKAGE/code/prep/build_linkage_sample1940.do:50-55.
- **Missing ages cannot pass the age threshold silently.** — The sample builder uses `keep if sex==1 & age>=10 & age<.` at LINKAGE/code/prep/build_linkage_sample1940.do:54-56, explicitly excluding Stata numeric missing values.
- **Blank middle initials do not inflate agreement rates.** — Both implementations require `mi1930 != "" & mi1940 != ""` before counting equality at LINKAGE/code/01_abe_jw/linkage_analysis.do:249-254 and LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:381-386.
- **Verified, unverifiable, and directly contradicted form a complete two-sided classification under the documented one-to-one truth file.** — The code checks both the 1940 and 1930 sides and assigns neither-person-present to unverifiable, the exact truth partner to verified, and either-person-different-partner to contradicted at LINKAGE/code/01_abe_jw/linkage_analysis.do:212-221 and LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:344-353.
- **The ABE columns are gated against the main table rather than merely compared informally.** — LINKAGE/code/01_abe_jw/linkage_analysis.do:410-447 checks denominator counts, initial-availability counts, linkage rates, and middle-initial rates against the main-table constants and exits with code 9 before writing tables if any check fails.
- **The one-to-one interpretation of match rates has been checked against all six input link files.** — The recorded data check states that HLINK, Jaro-Winkler, and ABE files are one-to-one on both census identifiers at replication/fix_effects_2026-10-19.md:91-98, supporting the interpretation at D:/repos/6638fa0fd89fbec05130caeb/DHTS-2026-10-12.tex:589.

## What this review could not establish

- The external census, linkage, and truth datasets were not readable in this sandbox, so counts could not be independently recomputed and the Stata pipeline was not rerun.
- The review verified source logic, committed generated tables, diagnostic outputs, and paper arithmetic; runtime assertions and the recorded one-to-one data check were not independently repeated.
- The construction and substantive accuracy of the selected FamilySearch genealogical reference links could not be validated from the underlying profiles or images.
- The third-party HLINK matching run itself is outside this repository; only its imported pair files and downstream scoring code were reviewable.
