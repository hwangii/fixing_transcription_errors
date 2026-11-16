# Codex review

*Rendered 2026-11-15 23:26. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-15_232435-MATCHING_profile_names_jw.do-codex.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 major, 1 minor

## Summary

The computation is largely defensive: empty normalized names cannot count as exact matches, pair merges are made unique, and the output correctly labels agreement as distinct from accuracy. The main issue is that the report calls the model surname “raw” even though it uses the separately inferred, ditto-resolved surname; this materially overstates what the comparison represents. A secondary fragility is the row-number merge used to attach cached profile-name splits.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | The report describes a ditto-resolved surname as raw model output | `MATCHING/profile_names_jw.do:91-92, MATCHING/profile_names_jw.do:141` || Fixed: description now says model first name and ditto-resolved model surname (namelast_ml_ditto, as in profile_names.md), no Ancestry fallback; same wording corrected in the generated md (numbers unaffected). |
| 2 | minor | likely | Cached profile-name splits are attached by mutable row position rather than a record key | `MATCHING/profile_names_jw.do:74-77` || Fixed (guard): refs_fullname.dta must carry pn_normver 2026-11-14a AND be newer than profile_names.dta (the score file's own reuse rule); tested in Stata. Positional key kept, as in profile_names_score.do: the run also asserts four sample counts and reproduces all 12 exact-agreement rows of profile_names.md, which a misaligned merge would not. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. The report describes a ditto-resolved surname as raw model output

`ditto-resolved-surname-described-as-raw` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `MATCHING/profile_names_jw.do:91-92, MATCHING/profile_names_jw.do:141`

**What the code does**  
The model surname is explicitly assigned with `local l_ml namelast_ml_ditto`, and all surname and full-name similarities therefore use the ditto-resolved field. The generated prose nevertheless says `Ours = raw model names (namefrst_ml, namelast_ml_ditto)`. Unlike `namefrst_ml`, `namelast_ml_ditto` incorporates a separate inference that resolves ditto marks, so the two fields are not jointly raw model transcriptions.

**Why it matters**  
Readers may attribute the surname and full-name results solely to transcription performance when they also reflect the success or failure of ditto resolution. This is especially material in census surname comparisons, where ditto marks are common and resolution can change both exact agreement and Jaro-Winkler similarity.

**How to check**  
Tabulate the prevalence and consequences of resolution with `count if namelast_ml!=namelast_ml_ditto` and compare `summarize` results for Jaro-Winkler scores computed once from `namelast_ml` and once from `namelast_ml_ditto`.

**Suggested fix**  
Describe `namefrst_ml` as the raw model first name and `namelast_ml_ditto` as the ditto-resolved model surname. If the intended claim concerns raw transcription quality, additionally report the surname and full-name results using `namelast_ml` before ditto resolution.

---

### 2. Cached profile-name splits are attached by mutable row position rather than a record key

`cached-references-merged-by-row-number` · **minor** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:74-77`

**What the code does**  
The code creates `gen long _id = _n` in the current `profile_names.dta` and then runs `merge 1:1 _id using refs_fullname.dta, assert(match)`. This proves only that both files contain the same row-number keys; it cannot prove that row 1, row 2, and so forth still describe the same records. The evidently intended operation is to attach each saved split name to the profile record from which it was derived.

**Why it matters**  
If `profile_names.dta` is regenerated, reordered, or partly updated while the cached reference file remains, profile names can be attached to the wrong census records without a merge error. The hard-coded counts and rounded aggregate agreement checks would catch a gross mismatch, but they do not establish row identity and can miss limited changes that still alter the three-decimal Jaro-Winkler results.

**How to check**  
Regenerate `refs_fullname.dta` from the current `profile_names.dta` into a temporary file and compare its `ref_first ref_last` values row by row with the cached file. Also verify whether a stable identifier such as `unique_ID` can be carried into both files and run `isid unique_ID` before merging.

**Suggested fix**  
Save a stable record identifier in `refs_fullname.dta` and merge on that identifier with `isid` and `assert(match)`. If memory constraints require positional storage, save and validate a source identifier or checksum alongside every `_id`, rather than relying on `_n` alone.

---

## Checked and sound

- **Exact agreement excludes empty normalized transcriptions** — The indicator requires both components to be non-empty: `cf_...!=""` and `cl_...!=""` at MATCHING/profile_names_jw.do:100. This avoids Stata's `""==""` agreement inflation.
- **Empty source names receive the documented zero similarity rather than missing values** — `jwpair` computes only non-empty pairs, asserts a nonmissing result for them, and assigns zero when the source component is empty at MATCHING/profile_names_jw.do:61-71.
- **The distinct-pair similarity merge has a unique using-side key** — The program retains only the two name variables and executes `duplicates drop` before the `merge m:1` at MATCHING/profile_names_jw.do:62-69.
- **The main cached-reference merge checks row-count matching** — The `merge 1:1` uses `assert(match)` at MATCHING/profile_names_jw.do:77. This prevents unmatched rows, although it does not solve the positional-key issue reported above.
- **The profile reference sample excludes empty first names and surnames** — The sample restriction explicitly requires `ref_first!="" & ref_last!=""` at MATCHING/profile_names_jw.do:83.
- **The generated report does not equate agreement with accuracy** — The output text explicitly states `Agreement with a selected, FamilySearch-linked reference, not accuracy` at MATCHING/profile_names_jw.do:141.
- **Full-name similarity is computed as the documented equal-weight mean** — The code uses `gen double jn_... = (jf_... + jl_...)/2` at MATCHING/profile_names_jw.do:103, matching the definition at lines 15-17 and 141.
- **The exact-agreement benchmark includes sample-size and aggregate-share guards** — The code asserts the two expected sample counts and checks rounded exact-agreement shares for all, disagreement, and concordant groups at MATCHING/profile_names_jw.do:110-135.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to claims embedded in the target file and its generated-report text.
- The external data were not available and the Stata pipeline was not run; consequences involving actual record ordering, missingness, and score magnitudes are inferred from source.
- The implementation and installed version of the external `jarowinkler` command were not available in the target, so its default prefix-weight semantics could not be independently verified.
- No generated `MATCHING/results/profile_names_jw.md` was present in the repository, so the emitted table values themselves could not be inspected.
