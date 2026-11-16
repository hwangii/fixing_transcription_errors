# Codex review

*Rendered 2026-11-16 05:30. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_052712-MATCHING_profile_names_jw.do-codex.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 2 minor

## Summary

The script is largely defensive: it excludes empty normalized names from exact matches, validates merge coverage, and labels agreement as distinct from accuracy. The most important remaining issue is that cached reference names are attached by row position rather than a stable record identifier; the timestamp and aggregate checks reduce but do not eliminate the risk of silent misattachment. The new “Ours+Anc” construction also differs slightly from the linkage pipeline it claims to reproduce.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | minor | likely | Cached profile names are attached by mutable row position rather than record identity | `MATCHING/profile_names_jw.do:54-63, MATCHING/profile_names_jw.do:84-88` || Accepted risk: same as finding 2 of the 2026-11-15_232435 review. Now guarded: refs_fullname.dta must carry pn_normver 2026-11-14a and be newer than profile_names.dta (tested), the four sample counts are asserted, and all 12 exact-agreement rows must reproduce profile_names.md, which a misaligned merge would not. Positional key kept to match profile_names_score.do, which wrote the file. |
| 2 | minor | likely | The “Ours+Anc” fallback is not exactly the linkage tables’ New transcription | `MATCHING/profile_names_jw.do:105-111, MATCHING/profile_names_jw.do:183, MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do:168-173` || Accepted risk: the linkage tests raw =="" (1_divide_and_clean...V2.do:168-169), this script strtrim()==""; they differ only on whitespace-only model fields, which would normalise to empty and score 0 under the linkage rule versus Ancestry's name here. Not checkable without another full load of the 88 GB file while the scoring run holds memory; the md says 'as the linkage tables' New transcription' for the fill-in rule, and the gap is at most the whitespace-only count. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Cached profile names are attached by mutable row position rather than record identity

`cached-references-merged-by-row-position` · **minor** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:54-63, MATCHING/profile_names_jw.do:84-88`

**What the code does**  
The script creates `gen long _id = _n` in the current `profile_names.dta` and executes `merge 1:1 _id using refs_fullname.dta, assert(match)`. This verifies that both files have the same row-number keys, but not that corresponding rows represent the same census record. The intended operation is to attach each cached split name to the record from which it was derived.

**Why it matters**  
If either file is reordered or copied with misleading modification times, reference names can be assigned to the wrong records without a merge failure. The later sample-count and one-decimal agreement checks would catch a gross mismatch but could miss limited corruption that changes the reported three-decimal Jaro-Winkler means.

**How to check**  
Regenerate `refs_fullname.dta` from the current `profile_names.dta` into a temporary file and compare `ref_first ref_last` row by row with the cached file. Also identify a stable key such as `histid` or `unique_ID` and run `isid` on it in both inputs.

**Suggested fix**  
Store a stable record identifier in `refs_fullname.dta`, verify uniqueness with `isid`, and merge on that identifier with `assert(match)`. If positional storage is necessary, retain and validate a stable identifier or checksum alongside `_id`.

---

### 2. The “Ours+Anc” fallback is not exactly the linkage tables’ New transcription

`ours-anc-fallback-differs-from-linkage-pipeline` · **minor** · claims-vs-code · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:105-111, MATCHING/profile_names_jw.do:183, MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do:168-173`

**What the code does**  
This script defines fallback using `strtrim(namefrst_ml)==""` and `strtrim(namelast_ml_ditto)==""`, then substitutes Ancestry field by field. The linkage construction it invokes as the comparator uses exact raw emptiness—`namefrst...==""` and `namelast...==""`—before applying `abeclean`. Thus a whitespace-only model value is replaced here but retained and subsequently cleaned in the linkage pipeline.

**Why it matters**  
If whitespace-only model fields exist, the reported Ours+Anc means do not describe precisely the name-source combination used by the linkage tables, despite the generated report saying they do. The affected count may be small or zero, but that cannot be established without the data.

**How to check**  
In `profile_names.dta`, run `count if namefrst_ml!="" & strtrim(namefrst_ml)==""` and the analogous count for `namelast_ml_ditto`; then recompute Ours+Anc once with `strtrim(x)==""` and once with `x==""` and compare the printed means.

**Suggested fix**  
Use the linkage pipeline’s exact fallback rule if this series is meant to reproduce its New transcription, or relabel the series as a trimmed-empty approximation and report whether the two rules differ on any records.

---

## Checked and sound

- **Exact agreement cannot be inflated by empty-string equality** — Both full-name and first-name indicators require nonempty normalized source values at MATCHING/profile_names_jw.do:132-133.
- **Empty source names receive the documented zero Jaro-Winkler score** — The helper excludes empty pairs, asserts nonmissing scores for every nonempty pair, and assigns zero where the source is empty at MATCHING/profile_names_jw.do:71-81.
- **The distinct-pair merge has a unique using-side key** — Only the two name fields are retained and `duplicates drop` is executed before the `merge m:1` at MATCHING/profile_names_jw.do:72-79.
- **The primary merge rejects unmatched rows** — The cached-reference merge uses `assert(match)` at MATCHING/profile_names_jw.do:87.
- **Profile reference names required by each reported sample are nonempty** — Men require both `ref_first!=""` and `ref_last!=""`; women require `ref_first!=""` at MATCHING/profile_names_jw.do:96-98.
- **Women are not inadvertently included in surname or full-name summaries** — Surname values are blanked for non-men, their surname scores are then set missing, and the women’s output measures are limited to `xf jf` at MATCHING/profile_names_jw.do:135-139 and MATCHING/profile_names_jw.do:193-196.
- **The ditto-resolved model surname is described accurately** — The computation uses `namelast_ml_ditto` at MATCHING/profile_names_jw.do:123-124, and the generated prose explicitly identifies it as a surname with ditto marks resolved at MATCHING/profile_names_jw.do:183.
- **The output does not present agreement as accuracy** — The generated report states `Agreement with a selected, FamilySearch-linked reference, not accuracy` at MATCHING/profile_names_jw.do:183.
- **Full-name similarity matches its documented equal-weight definition** — The code computes `(jf_... + jl_...)/2` at MATCHING/profile_names_jw.do:139, matching the definition at MATCHING/profile_names_jw.do:15-19.
- **Sample sizes and benchmark agreement rates are guarded before output is written** — Expected male and female sample counts are asserted, and Ancestry, FamilySearch, and model agreement shares are checked for the principal groups at MATCHING/profile_names_jw.do:148-177.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to claims embedded in the target and its generated-report text.
- The external census and profile datasets were unavailable and the Stata pipeline was not run; the prevalence and numerical consequences of whitespace-only fields or row misalignment could not be measured.
- The installed implementation and version of the external SSC `jarowinkler` command were unavailable, so its prefix-weight and empty-dataset runtime semantics could not be independently verified.
- The checked-in `MATCHING/results/profile_names_jw.md` predates the current target code and lacks its Ours+Anc series, so the newly emitted table values could not be inspected.
