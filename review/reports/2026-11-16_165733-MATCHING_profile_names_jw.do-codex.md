# Codex review

*Rendered 2026-11-16 16:59. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_165733-MATCHING_profile_names_jw.do-codex.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 minor

## Summary

The script is generally defensive: it excludes empty normalized names from exact agreement, asserts merge coverage, and explicitly distinguishes agreement from accuracy. The remaining numerical concern is that “Ours+Anc” uses a fallback rule that is neither the linkage pipeline’s raw-empty rule nor the scoring code’s normalized-empty definition, so it can silently score the wrong source on unusual model strings.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | minor | likely | “Ours+Anc” applies an inconsistent definition of an empty model field | `MATCHING/profile_names_jw.do:108-111, MATCHING/profile_names_jw.do:126-134, MATCHING/profile_names_jw.do:197` || Accepted risk: as 2026-11-16_052712 #2. Ours+Anc no longer goes on the slide (user, 2026-11-16: slide uses only records with model names); the column is kept for reference and differs from the linkage rule only on whitespace-only model fields. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. “Ours+Anc” applies an inconsistent definition of an empty model field

`fallback-empty-definition-mismatch` · **minor** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `MATCHING/profile_names_jw.do:108-111, MATCHING/profile_names_jw.do:126-134, MATCHING/profile_names_jw.do:197`

**What the code does**  
The fallback indicators use `strtrim(namefrst_ml)==""` and `strtrim(namelast_ml_ditto)==""` before normalization. Scoring later applies `pnorm`, under which nonblank values containing only punctuation, annotations, or removable titles can become empty and score zero, while the report describes Ancestry as filling an empty model field. Conversely, whitespace-only values trigger fallback here although the cited linkage construction tests raw `==""`.

**Why it matters**  
If either kind of value exists, reported Ours+Anc agreement and Jaro-Winkler means use a different transcription source than the prose and linkage comparison imply. The numerical size cannot be established without the data.

**How to check**  
After constructing normalized model fields, run counts for `(strtrim(namefrst_ml)!="" & cf_ml=="")`, `(strtrim(namelast_ml_ditto)!="" & cl_ml=="")`, and raw-nonempty whitespace-only fields. Recompute Ours+Anc using raw-empty, trimmed-empty, and normalized-empty fallback rules and compare the table means.

**Suggested fix**  
Choose the intended definition explicitly. To reproduce the linkage pipeline, use raw `==""`; to mean analytically usable names, normalize first and fall back when the normalized value is empty. Update the report text to name the chosen rule.

---

## Checked and sound

- **Exact agreement cannot be inflated by empty-string equality** — Both the full-name and first-name indicators require nonempty normalized source values at MATCHING/profile_names_jw.do:132-133.
- **Empty normalized source names receive zero Jaro-Winkler similarity** — `jwpair` excludes empty pairs from calculation, asserts scores for nonempty pairs, and assigns zero where the candidate is empty at MATCHING/profile_names_jw.do:71-81.
- **The distinct-pair similarity merge has a unique using-side key** — The helper retains only the two name fields and executes `duplicates drop` before `merge m:1` at MATCHING/profile_names_jw.do:72-79.
- **The reference-name merge rejects unmatched observations** — The positional `merge 1:1` uses `assert(match)` at MATCHING/profile_names_jw.do:85-88.
- **Sex-specific reference-name requirements match the reported measures** — Men require nonempty profile first and last names, while women require only a profile first name, at MATCHING/profile_names_jw.do:92-98.
- **The model-name-present restriction uses normalized names and the correct sex-specific fields** — Normalized model first-name and surname availability are captured at MATCHING/profile_names_jw.do:135-139; `hasml` requires both for men and only first name for women at MATCHING/profile_names_jw.do:148-155.
- **Women are excluded from surname and full-name summaries** — Surname candidates and scores are suppressed for non-men at MATCHING/profile_names_jw.do:140-145, and women's output measures are limited to exact-first and JW-first at MATCHING/profile_names_jw.do:207-210.
- **The ditto-resolved surname is accurately disclosed** — The computation uses `namelast_ml_ditto` at MATCHING/profile_names_jw.do:123-124, and the emitted prose identifies it as a surname with ditto marks resolved at MATCHING/profile_names_jw.do:197.
- **The generated prose does not equate agreement with accuracy** — The output explicitly says `Agreement with a selected, FamilySearch-linked reference, not accuracy` at MATCHING/profile_names_jw.do:197.
- **Full-name similarity matches its documented equal-weight definition** — The code computes `(jf_... + jl_...)/2` at MATCHING/profile_names_jw.do:144, matching the definition at MATCHING/profile_names_jw.do:15-19.
- **Core sample sizes and exact-agreement benchmarks are checked before output** — Male and female sample counts are asserted and twelve sets of rounded agreement rates are checked at MATCHING/profile_names_jw.do:157-191.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to claims embedded in the target's comments and generated-report text.
- The external census and profile datasets were unavailable, and the Stata pipeline could not be run; the prevalence and numerical effect of inconsistent empty-field definitions could not be measured.
- The installed version and runtime behavior of the external SSC `jarowinkler` command could not be independently verified.
- The checked-in MATCHING/results/profile_names_jw.md predates the current target: it lacks the two model-name-present sections added at MATCHING/profile_names_jw.do:199. Consequently, those new output values could not be inspected.
