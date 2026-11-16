# Antigravity review

*Rendered 2026-11-15 23:32. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-15_232435-MATCHING_profile_names_jw.do-agy.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 major, 1 minor

## Summary

The Jaro-Winkler comparison script is defensively constructed: it guards against empty-string agreement inflation, ensures uniqueness for distinct-pair merges, and validates exact-agreement shares against benchmark numbers before generating output. The primary defect is in claims-vs-code: the generated report text describes the model names as 'raw' despite using the ditto-resolved surname namelast_ml_ditto, which incorporates a separate inference step. A secondary correctness vulnerability is merging cached reference names on a positional row index (_id = _n) rather than a stable record identifier.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | The generated report describes ditto-resolved surnames as raw model output | `MATCHING/profile_names_jw.do:91-92, MATCHING/profile_names_jw.do:141` || Fixed: description now says model first name and ditto-resolved model surname (namelast_ml_ditto, as in profile_names.md), no Ancestry fallback; same wording corrected in the generated md (numbers unaffected). |
| 2 | minor | likely | Split profile reference names are attached by positional row index rather than a stable key | `MATCHING/profile_names_jw.do:74-77` || Fixed (guard): refs_fullname.dta must carry pn_normver 2026-11-14a AND be newer than profile_names.dta (the score file's own reuse rule); tested in Stata. Positional key kept, as in profile_names_score.do: the run also asserts four sample counts and reproduces all 12 exact-agreement rows of profile_names.md, which a misaligned merge would not. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. The generated report describes ditto-resolved surnames as raw model output

`ditto-resolved-surname-described-as-raw` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `MATCHING/profile_names_jw.do:91-92, MATCHING/profile_names_jw.do:141`

**What the code does**  
Lines 91-92 set `local l_ml namelast_ml_ditto`, using the ditto-resolved surname for similarity comparisons. Line 141 writes into the markdown report header: `Ours = raw model names (namefrst_ml, namelast_ml_ditto)`. While `namefrst_ml` is a raw model transcription, `namelast_ml_ditto` incorporates post-model ditto mark resolution, which is a separate inference step.

**Why it matters**  
Describing ditto-resolved surnames as raw model names conflates transcription performance with downstream ditto resolution. Ditto marks (") are common in census records; resolving them is a separate inference step that alters both exact agreement and Jaro-Winkler similarity, so performance cannot be attributed solely to the OCR transcription model.

**How to check**  
Tabulate the prevalence of ditto resolution on the sample with `count if namelast_ml!=namelast_ml_ditto` and compare summarize output for Jaro-Winkler scores computed from `namelast_ml` versus `namelast_ml_ditto`.

**Suggested fix**  
Clarify the description in line 141 to state that `namefrst_ml` is the raw model first name and `namelast_ml_ditto` is the ditto-resolved surname. If raw transcription benchmarking is intended, report Jaro-Winkler similarity on `namelast_ml` alongside or instead of `namelast_ml_ditto`.

---

### 2. Split profile reference names are attached by positional row index rather than a stable key

`cached-references-merged-by-row-number` · **minor** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:74-77`

**What the code does**  
The script loads `profile_names.dta`, creates a positional row number with `gen long _id = _n`, and merges `refs_fullname.dta` on `_id` with `merge 1:1 _id using ... refs_fullname.dta, assert(match)`. It relies entirely on the assumption that `profile_names.dta` and `refs_fullname.dta` retain identical row ordering.

**Why it matters**  
If `profile_names.dta` is reordered, updated, or re-extracted without synchronously rebuilding `refs_fullname.dta`, census records will be paired with the wrong profile names without triggering a merge assertion failure. Although lines 110-135 check aggregate exact agreement to one decimal place, minor row-order shifts could alter the three-decimal Jaro-Winkler means while passing the rounded exact agreement check.

**How to check**  
Re-extract `refs_fullname.dta` from `profile_names.dta` into a temporary file and verify row-by-row identity. Check whether a stable record key like `unique_ID` or `histid` can be preserved in `refs_fullname.dta` and merged with `isid`.

**Suggested fix**  
Store a stable record identifier (`unique_ID` or `histid`) in `refs_fullname.dta` and merge on that key using `isid` and `assert(match)` rather than relying on arbitrary row index `_id = _n`.

---

## Checked and sound

- **Exact agreement excludes empty normalized transcriptions** — MATCHING/profile_names_jw.do:100 explicitly checks `cf_...!=\"\"` and `cl_...!=\"\"` in `ex_`s'' before scoring exact match, preventing Stata's `\"\"==\"\"` inflation.
- **Empty source names receive a documented score of zero rather than missing values** — In `jwpair` (MATCHING/profile_names_jw.do:63, 69-71), pairs with `a==\"\"` are excluded from jarowinkler, merge as `_merge==1`, and are explicitly set to 0 with `replace outv = 0 if a==\"\"`.
- **Distinct pair similarity merge has a unique using-side key** — MATCHING/profile_names_jw.do:62-69 keeps only `a` and `b`, executes `duplicates drop`, and merges with `m:1`, guaranteeing a unique key on the using side.
- **Profile reference sample excludes empty first names and surnames** — MATCHING/profile_names_jw.do:83 explicitly requires `ref_first!=\"\" & ref_last!=\"\"`.
- **Gender consistency filtering matches census sex** — MATCHING/profile_names_jw.do:83 restricts the sample with `sex==1 & lower(gender)!=\"female\"`, matching the male first-name-and-surname sample in profile_names_score.do.
- **Full-name similarity is computed as the documented equal-weight arithmetic mean** — MATCHING/profile_names_jw.do:103 computes `jn_`s'' as `(jf_`s' + jl_`s')/2`, matching the arithmetic mean documented at lines 15-17 and 141.
- **Generated report text does not equate agreement with ground-truth accuracy** — MATCHING/profile_names_jw.do:141 explicitly states 'Agreement with a selected, FamilySearch-linked reference, not accuracy' in the output report header.
- **Exact agreement benchmark includes sample-size and aggregate-share assertions** — MATCHING/profile_names_jw.do:110-135 asserts sample counts (33,593,927 and 27,334,035) and verifies that rounded exact agreement shares match profile_names.md across all, discordant, and concordant cells before writing output.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to claims stated in the script comments and the generated markdown text.
- Census microdata and intermediate datasets (profile_names.dta, refs_fullname.dta) reside outside the repository and could not be loaded; runtime behavior was inferred from Stata source reading.
- The Stata execution pipeline was not run; runtime execution of the external SSC jarowinkler package could not be verified directly.
- The output file MATCHING/results/profile_names_jw.md was not present in the repository, so emitted table values could not be inspected directly.
