# Antigravity review

*Rendered 2026-11-16 17:09. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_165733-MATCHING_profile_names_jw.do-agy.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 major, 2 minor, 1 nit

## Summary

The script MATCHING/profile_names_jw.do implements a rigorous Jaro-Winkler string similarity comparison between census transcriptions and FamilySearch profile names, correctly verifying exact agreement against prior benchmarks and guarding against missing-string equalities. The primary defect is in the newly added hasml specification for women, where group 4 is described in the markdown header as 'empty or near-empty' but actually contains over 300,000 records because cell 4 was defined using surname completeness while hasml for women requires only first-name completeness. Additionally, discordant cells 1-4 for women partition on full-name discordance rather than first-name discordance, misclassifying women with concordant first names into discordant cells.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | Group 4 is claimed to be empty or near-empty under model-names-present restriction but contains ~330,000 records for women | `MATCHING/profile_names_jw.do:150, 197-199` || Fixed after the run: the md text will say group 4 holds women whose model surname is missing (their first names are scored), and that only men's group 4 is empty under 'model names present'. Numbers unaffected; same finding as 2026-11-16_165733-agy #1. |
| 2 | minor | verified | Discordant groups for women partition on full-name discordance rather than first-name discordance | `MATCHING/profile_names_jw.do:197, 207-216` || Accepted risk: Target is the deck's definition throughout (Ancestry and FamilySearch disagree on first or last name); noted in the slide's LaTeX comment. |
| 3 | minor | verified | Empty group 4 under men with model names present outputs Stata missing value dots across all 16 metric columns | `MATCHING/profile_names_jw.do:217-228` || Fixed after the run: the empty men's group-4 row will print '-' instead of '.'. |
| 4 | nit | verified | Fallback to Ancestry for ours+Anc is evaluated on raw strings while model presence is evaluated after normalization | `MATCHING/profile_names_jw.do:108-111, 136-138` || Accepted risk: as 2026-11-16_052712 #2. Ours+Anc no longer goes on the slide (user, 2026-11-16: slide uses only records with model names); the column is kept for reference and differs from the linkage rule only on whitespace-only model fields. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Group 4 is claimed to be empty or near-empty under model-names-present restriction but contains ~330,000 records for women

`wom-hasml-cell4-contradiction` · **MAJOR** · correctness · confidence: **verified** (traced in source)

**Where:** `MATCHING/profile_names_jw.do:150, 197-199`

**What the code does**  
Line 150 defines 'gen byte hasml = (men & hm_f & hm_l) | (wom & hm_f)', requiring only first-name completeness for women. Line 197 writes to the report header that sections marked 'model names present' keep only records where the model produced every name scored, 'so no source is scored on an empty model name; group 4 is then empty or near-empty'. However, 'cell' is inherited from profile_names_build.do:47-53, where cell 4 is defined as 'disc & !ml_ok' with 'ml_ok = namefrst_ml!=\"\" & namelast_ml_ditto!=\"\"'. Women whose model first name is present but whose model surname is missing were assigned to cell 4 in profile_names_build.do, yet satisfy hasml in profile_names_jw.do. In the resulting table for women under hasml, group 4 is not empty; it contains over 330,000 records.

**Why it matters**  
The generated report header directly contradicts the table printed beneath it. Readers are told group 4 is empty or near-empty and that no source is scored on an empty model name, but will see hundreds of thousands of observations in group 4 where the model first name is present, valid, and scored (~41% exact agreement and ~0.89 JW similarity). Labeling these valid first-name transcriptions under group 4 '(missing)' misrepresents their completeness.

**How to check**  
Run in Stata: count if wom & has_dmonth & hasml & cell==4. The count will be ~330,000, refuting the claim that group 4 is empty or near-empty.

**Suggested fix**  
Either amend the note in line 197 to state that group 4 is empty only for men (for women, group 4 contains records where the model produced a first name but lacked a surname in the full-name cell classification), or define a sex-specific cell variable where cell 4 reflects first-name missingness for women.

---

### 2. Discordant groups for women partition on full-name discordance rather than first-name discordance

`women-discordance-partition-mismatch` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `MATCHING/profile_names_jw.do:197, 207-216`

**What the code does**  
Lines 207-216 iterate over groups all, 0, disc, 1, 2, 3, 4 for women and evaluate first-name agreement (xf and jf). Line 197 defines the partition as: 'Cell 0 = Ancestry and FamilySearch agree; 1-4 = they disagree'. However, cell is inherited from profile_names_build.do:46 where disc is defined as '!(namefrst==fs_namefrst & namelast==fs_namelast)'. Consequently, records where Ancestry and FamilySearch agree on first name but disagree on surname are assigned to disc (and cells 1-4).

**Why it matters**  
In a table specifically presenting first-name performance for women, a reader expects 'disc' and cells 1-4 to represent cases where Ancestry and FamilySearch disagreed on first name. Instead, millions of records in group disc have identical first names across Ancestry and FamilySearch, causing both sources to show high exact agreement (~53% and ~66%) within the ostensibly 'discordant' partition.

**How to check**  
Run in Stata: count if wom & inrange(cell,1,4) & namefrst==fs_namefrst. The count will reveal millions of women in discordant cells who have identical first names across Ancestry and FamilySearch.

**Suggested fix**  
Clarify in line 197 that cells 0-4 are partitioned on full-name discordance (first name or surname) rather than first-name discordance alone.

---

### 3. Empty group 4 under men with model names present outputs Stata missing value dots across all 16 metric columns

`empty-subsample-missing-dots` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `MATCHING/profile_names_jw.do:217-228`

**What the code does**  
In lines 217-228, when cond is 'men&has_dmonth&hasml' and g is 4, count returns r(N)==0 because hasml requires both model names while cell 4 requires at least one model name missing. When quietly sum evaluates over 0 observations, r(mean) is missing (.), and string(100*r(mean), \"%5.1f\") and string(r(mean), \"%5.3f\") format it as '.'. The code writes '| 4 | 0 | . | . | ... | .' to the markdown file.

**Why it matters**  
A published exhibit or documentation table containing raw Stata missing value dots '.' looks unhandled and can cause issues for automated markdown table parsers expecting numeric values.

**How to check**  
Inspect MATCHING/results/profile_names_jw.md under '## Men, death month on profile, model names present: first name and surname' row '| 4 |'.

**Suggested fix**  
Check if r(N)==0 before formatting means, and print '-' or 'n/a' instead of formatting missing values as '.', or suppress the row if empty.

---

### 4. Fallback to Ancestry for ours+Anc is evaluated on raw strings while model presence is evaluated after normalization

`fallback-pre-normalization-asymmetry` · **nit** · correctness · confidence: **verified** (traced in source)

**Where:** `MATCHING/profile_names_jw.do:108-111, 136-138`

**What the code does**  
Lines 108-111 construct namefrst_mf and namelast_mf using 'fb_f = strtrim(namefrst_ml)==\"\"' and 'fb_l = strtrim(namelast_ml_ditto)==\"\"' before normalization. In contrast, lines 136-138 define model presence using 'hm_f = cf_ml!=\"\"' and 'hm_l = cl_ml!=\"\"' after pnorm. If a model transcription contains non-empty characters that normalize to empty (e.g. punctuation or noise), fallback to Ancestry is not triggered, yet the record is treated as missing under hasml.

**Why it matters**  
If unparseable non-alphabetic strings occur in raw model transcriptions, ours+Anc fails to substitute Ancestry's name, leaving an empty normalized name that scores 0. In practice, model names in the dataset are predominantly cleaned or empty, making the numerical consequence negligible.

**How to check**  
Run in Stata: count if strtrim(namefrst_ml)!=\"\" & cf_ml==\"\". If 0, no records are affected.

**Suggested fix**  
Evaluate fallback after normalization, or define cf_mf = cond(cf_ml==\"\", cf_anc, cf_ml).

---

## Checked and sound

- **Empty string comparison protection against '\"\"==\"\"' inflation** — MATCHING/profile_names_jw.do:132-133 checks 'cf_s!=\"\" & cl_s!=\"\"', and jwpair (lines 73, 81) explicitly drops empty strings before pairing and replaces outv = 0 where a==\"\". Empty transcriptions never score positive agreement against empty references.
- **Strict numeric missing value protections** — MATCHING/profile_names_jw.do:63 guards timestamp checks with 't_ref<. & t_pn<.', line 80 asserts 'outv<. if a!=\"\" & b!=\"\"', and sample definitions at lines 96-97 use 'sex==1' and 'sex==2' which cleanly exclude missing numeric sex.
- **Exact agreement benchmark replication against profile_names.md** — MATCHING/profile_names_jw.do:162-191 replicates exact agreement figures across 12 distinct sample and cell configurations for Ancestry, FamilySearch, and ML models, asserting equality against profile_names.md before writing output.
- **Row-order alignment for profile reference name merge** — MATCHING/profile_names_jw.do:86-88 creates '_id = _n' and merges with refs_fullname.dta using 'assert(match) nogen keepusing(ref_first ref_last)', guaranteeing 1:1 row alignment with zero unmatched records.
- **Memory management and distinct pair Jaro-Winkler computation** — MATCHING/profile_names_jw.do:67-82 computes jarowinkler strictly on distinct (a, b) pairs in temporary datasets rather than over 65M full records, and drops raw strings promptly after normalization (lines 128, 131).
- **Sex and gender consistency filtering** — MATCHING/profile_names_jw.do:96-98 requires 'sex==1 & lower(gender)!=\"female\"' for men and 'sex==2 & lower(gender)!=\"male\"' for women, ensuring gender contradictions are excluded identically to profile_names_score.do:173.
- **Surname exclusion for women in Jaro-Winkler scoring** — MATCHING/profile_names_jw.do:141-143 sets 'replace cl_s = \"\" if !men' and 'replace jl_s = . if !men', preventing women's surnames from biasing Jaro-Winkler scores and ensuring only first names are evaluated in women's specifications.

## What this review could not establish

- No paper draft was supplied: review evaluated code only; could not verify numbers or claims against manuscript text or presentation slides.
- Underlying data files (e.g. F:/.../profile_names.dta and refs_fullname.dta) could not be run end-to-end through StataMP in this environment; analysis relies on code reading, batch log inspection, and Python chunk verification.
- Stata batch execution of profile_names_jw.do was actively processing during review; final generated profile_names_jw.md containing the new hasml tables was not available for direct inspection on disk.
