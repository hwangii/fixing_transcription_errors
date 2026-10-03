# Codex review

*Rendered 2026-09-13 04:40. Source: `F:\github_repos\fixing_transcription_errors\review\reports\2026-09-13_043910-CODE_comparing_model_transcription_with_anc_fs_SSHA2025.do.json`*

**Dimensions:** correctness

**Result:** 1 major

## Summary

The script's four categories are logically exhaustive and the state totals are accumulated correctly, but the eligible sample permits partial names while the agreement tests treat shared empty components as matches. The most important fix is to require complete, nonblank comparable fields—or explicitly score fields separately—before reporting whole-name agreement.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | likely | Shared blank name components are counted as whole-name agreement | `CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:39, CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:43-55` | |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Shared blank name components are counted as whole-name agreement

`blank-components-count-as-name-agreement` · **MAJOR** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:39, CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:43-55`

**What the code does**  
Eligibility requires only `(namefrst!=""|namelast!="") & (fs_namefrst!=""|fs_namelast!="")`, so either component may be blank. The category predicates then use equalities such as `namefrst==namefrst_ml & namelast==namelast_ml_ditto`; because Stata evaluates `""==""` as true, a surname-only record can be classified as a whole-name match based solely on its surname, and likewise for first-name-only records.

**Why it matters**  
The Ancestry-only, FamilySearch-only, and both-source counts can be inflated. Because blank-field prevalence may differ across sources, this can also distort the relative agreement attributed to Ancestry versus FamilySearch, although the magnitude depends on unseen data.

**How to check**  
For every state file, count the line-39 eligible sample and tabulate the four categories by `namefrst=="" | namelast=="" | fs_namefrst=="" | fs_namelast=="" | namefrst_ml=="" | namelast_ml_ditto==""`; then recompute all four totals after requiring all six fields to be nonblank and compare the results.

**Suggested fix**  
For a whole-name comparison on a common sample, require first and last names to be nonblank in Ancestry, FamilySearch, and the ML output before applying the equality predicates. If partial records should remain, calculate first-name and surname agreement separately and do not label a match on one populated component as whole-name agreement.

---

## Checked and sound

- **The four category predicates partition the stated eligible sample.** — The predicates implement Ancestry-match/not-FamilySearch-match, FamilySearch-match/not-Ancestry-match, both matches, and neither match, respectively, at CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:43-55.
- **State totals are initialized once and accumulated immediately after each count.** — The denominator and four numerators are initialized at CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:19-23 and updated from the corresponding `r(N)` values at CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:39-56.
- **Directory traversal returns to the parent directory after each state.** — Each iteration enters the state directory at CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:33 and executes `cd ..` at CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:58.
- **The final display syntax is valid Stata syntax for emitting multiple display directives.** — CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:62 separates the five expanded local values with commas; this was also documented as successfully tested under Stata/MP 15.1 in the repository's prior verification report.
- **The target contains no merges, joins, numeric inequalities, random sampling, estimation, or preserve/restore branches requiring additional correctness findings.** — The complete target is CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:1-64; its substantive operations are directory traversal, variable loading, counts, local accumulation, and display.

## What this review could not establish

- The external state-level data were unavailable, so the prevalence of partial names and the numerical magnitude of the agreement distortion could not be established.
- The Stata pipeline was not run in this review; runtime and data-dependent conclusions are based on source inspection.
- No paper draft was supplied, so claims-vs-code—including whether the Hawaii exclusion at CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:26 and absence of Alaska are disclosed or consistent with the claimed population—could not be assessed.
- Only the requested correctness dimension and target file were reviewed; replication and identification were outside scope.
