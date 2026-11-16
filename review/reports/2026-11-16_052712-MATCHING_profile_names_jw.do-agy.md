# Antigravity review

*Rendered 2026-11-16 05:36. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_052712-MATCHING_profile_names_jw.do-agy.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 2 minor

## Summary

The Jaro-Winkler comparison script is defensively implemented with robust guards against empty-string agreement inflation, clear separation of comparison sources from ground truth, and comprehensive pre-output assertions that reproduce benchmark sample counts and exact-agreement shares. The most important remaining issue is that cached profile reference names are merged using a positional row index (_id = _n) rather than an invariant record identifier, creating a vulnerability if input sort orders shift. Additionally, the new 'Ours+Anc' fallback rule uses trimmed emptiness rather than the exact raw emptiness and duplicate handling of the linkage pipeline it references.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | minor | likely | Cached profile reference names are merged by mutable row index rather than invariant record identifier | `MATCHING/profile_names_jw.do:54-63, MATCHING/profile_names_jw.do:84-88` || Accepted risk: same as finding 2 of the 2026-11-15_232435 review. Now guarded: refs_fullname.dta must carry pn_normver 2026-11-14a and be newer than profile_names.dta (tested), the four sample counts are asserted, and all 12 exact-agreement rows must reproduce profile_names.md, which a misaligned merge would not. Positional key kept to match profile_names_score.do, which wrote the file. |
| 2 | minor | likely | The 'Ours+Anc' fallback rule diverges from the linkage pipeline's New transcription definition | `MATCHING/profile_names_jw.do:105-111, MATCHING/profile_names_jw.do:183, MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do:168-173` || Accepted risk: the linkage tests raw =="" (1_divide_and_clean...V2.do:168-169), this script strtrim()==""; they differ only on whitespace-only model fields, which would normalise to empty and score 0 under the linkage rule versus Ancestry's name here. Not checkable without another full load of the 88 GB file while the scoring run holds memory; the md says 'as the linkage tables' New transcription' for the fill-in rule, and the gap is at most the whitespace-only count. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Cached profile reference names are merged by mutable row index rather than invariant record identifier

`cached-references-merged-by-row-position` · **minor** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:54-63, MATCHING/profile_names_jw.do:84-88`

**What the code does**  
The script creates a synthetic row index with gen long _id = _n on profile_names.dta and executes merge 1:1 _id using refs_fullname.dta, assert(match). It verifies that both datasets share identical row counts and that refs_fullname.dta is newer with matching version characteristic, but does not verify that corresponding rows represent the same census record.

**Why it matters**  
If profile_names.dta is re-sorted, updated, or extracted without synchronously rebuilding refs_fullname.dta, reference names can be matched to the wrong census records without a merge assertion failure. While the one-decimal benchmark checks at lines 161-176 catch coarse divergence, small row shifts could corrupt the reported three-decimal Jaro-Winkler means without triggering the one-decimal exact-match check.

**How to check**  
Re-extract refs_fullname.dta from profile_names.dta into a temporary file and check row-by-row identity with the cached file. Identify a stable primary key such as histid or unique_ID and test uniqueness with isid in both datasets.

**Suggested fix**  
Persist a stable record identifier (such as histid or unique_ID) in refs_fullname.dta and merge on that key using assert(match) and isid, rather than relying on mutable row numbers (_id = _n).

---

### 2. The 'Ours+Anc' fallback rule diverges from the linkage pipeline's New transcription definition

`ours-anc-fallback-differs-from-linkage-pipeline` · **minor** · claims-vs-code · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:105-111, MATCHING/profile_names_jw.do:183, MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do:168-173`

**What the code does**  
Lines 108-111 construct the fallback using strtrim(namefrst_ml)=="" and strtrim(namelast_ml_ditto)=="", substituting Ancestry field-by-field, and line 183 describes Ours+Anc as 'ours with Ancestry's name wherever the model field is empty, field by field, as the linkage tables' New transcription'. However, the linkage construction in 1_divide_and_clean_everyoneV5_women_addedV2.do:168-173 tests raw string emptiness (namefrst...=="" and namelast...=="") before abeclean, retaining whitespace-only strings rather than falling back to Ancestry, and also invalidates model transcriptions where filename-row duplicates exist (N>1 & _merge==3).

**Why it matters**  
If whitespace-only model fields or duplicate filename-row pairs exist, the Ours+Anc series reported in profile_names_jw.md does not strictly reflect the New transcription fed to the linkage pipeline, despite the generated markdown text explicitly equating them.

**How to check**  
In profile_names.dta, check for records where namefrst_ml!="" & strtrim(namefrst_ml)=="" or namelast_ml_ditto!="" & strtrim(namelast_ml_ditto)=="", and compare summary statistics under the exact raw equality condition vs strtrim.

**Suggested fix**  
Either align the fallback condition to the exact linkage pipeline logic (or test and confirm whether whitespace-only records exist), or soften the description in line 183 to state that Ours+Anc is a field-by-field empty-string fallback approximation to the linkage tables' New transcription.

---

## Checked and sound

- **Exact agreement cannot be inflated by empty-string equality** — MATCHING/profile_names_jw.do:132-133 explicitly requires non-empty normalized source values (cf_`s'!="" & cl_`s'!="" for ex_`s' and cf_`s'!="" for xf_`s') before evaluating exact equality against reference names.
- **Empty source names receive the documented zero Jaro-Winkler score rather than missing values** — MATCHING/profile_names_jw.do:73-81 in jwpair excludes empty inputs from jarowinkler, asserts valid scores for all non-empty pairs, and explicitly sets outv = 0 if a=="".
- **Distinct pair deduplication guarantees 1-to-many uniqueness on using side** — MATCHING/profile_names_jw.do:74-79 retains only variables a and b and executes duplicates drop before merge m:1 a b using pairs, preventing Cartesian duplication.
- **Cached reference merge enforces complete record matching** — MATCHING/profile_names_jw.do:87 executes merge 1:1 _id using refs_fullname.dta, assert(match), ensuring no records are dropped or unmatched.
- **Profile reference names required by analysis samples are strictly non-empty** — MATCHING/profile_names_jw.do:96-98 requires ref_first!="" & ref_last!="" for men and ref_first!="" for women in sample definitions.
- **Women are strictly excluded from surname and full-name scoring** — MATCHING/profile_names_jw.do:136-139 and MATCHING/profile_names_jw.do:193-196 blank surname inputs for non-men, replace surname similarity with missing (jl_`s' = . if !men), and limit women's output measures to first names only (xf jf).
- **Ditto-resolved surnames are explicitly documented as ditto-resolved rather than raw OCR** — MATCHING/profile_names_jw.do:183 explicitly documents Ours as 'the model's first name (namefrst_ml) and its surname with ditto marks resolved to the surname they refer to (namelast_ml_ditto)... no fallback to Ancestry'.
- **Generated report text avoids presenting agreement as accuracy** — MATCHING/profile_names_jw.do:183 explicitly states 'Agreement with a selected, FamilySearch-linked reference, not accuracy' in the generated report header.
- **Full-name similarity matches documented equal-weight arithmetic mean** — MATCHING/profile_names_jw.do:139 computes jn_`s' = (jf_`s' + jl_`s')/2, matching the arithmetic mean documented at lines 17-18 and line 183.
- **Sample sizes and benchmark exact-agreement shares are asserted before output generation** — MATCHING/profile_names_jw.do:153-176 asserts exact record counts across four demographic subsets (33,593,927 men; 27,334,035 men with death month; 31,426,868 women; 23,365,543 women with death month) and validates exact-agreement shares against profile_names.md across 12 cells, halting with exit 9 on mismatch.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to claims stated in the script comments and the generated markdown text.
- External census and profile datasets (profile_names.dta, refs_fullname.dta) reside on external storage outside the repository and could not be inspected; runtime data characteristics were inferred from source code.
- The Stata pipeline was not executed, so runtime execution and behavior of the external SSC jarowinkler package could not be verified directly.
- The checked-in MATCHING/results/profile_names_jw.md file predates the addition of the Ours+Anc series, so the newly generated output values could not be compared against existing committed results.
