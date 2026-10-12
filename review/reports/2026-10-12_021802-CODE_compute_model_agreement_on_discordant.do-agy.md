# Codex review

*Rendered 2026-10-12 02:27. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-10-12_021802-CODE_compute_model_agreement_on_discordant.do-agy.json`*

**Dimensions:** correctness

**Result:** 1 major, 1 minor, 1 nit

## Summary

The script has successfully addressed earlier concerns regarding incomplete run assertions and geographic coverage documentation, and the strict partition logic is sound. However, the strict variant defines its discordant denominator by requiring both model fields to be non-empty alongside human fields, silently dropping model transcription failures rather than classifying them as non-matching. The single most important fix is to define the strict denominator over non-empty human transcriptions only, so model omission is properly penalized in the evaluation.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | Strict variant conditions denominator on non-empty model output, dropping model transcription failures | `CODE/compute_model_agreement_on_discordant.do:80-83, CODE/compute_model_agreement_on_discordant.do:94-95, CODE/compute_model_agreement_on_discordant.do:136-143` | |
| 2 | minor | verified | CSV output writes vacuous-match-prone as-coded variant under primary column names | `CODE/compute_model_agreement_on_discordant.do:46, CODE/compute_model_agreement_on_discordant.do:61-77, CODE/compute_model_agreement_on_discordant.do:97, CODE/compute_model_agreement_on_discordant.do:119` | |
| 3 | nit | verified | Console display labels FamilySearch matches without the 'only' qualifier used for Ancestry | `CODE/compute_model_agreement_on_discordant.do:128-129, CODE/compute_model_agreement_on_discordant.do:138-139` | |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Strict variant conditions denominator on non-empty model output, dropping model transcription failures

`strict-denominator-drops-model-omissions` · **MAJOR** · correctness · confidence: **verified** (traced in source)

**Where:** `CODE/compute_model_agreement_on_discordant.do:80-83, CODE/compute_model_agreement_on_discordant.do:94-95, CODE/compute_model_agreement_on_discordant.do:136-143`

**What the code does**  
In lines 82-83, the strict denominator disc_s requires all six name fields to be non-empty: `namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!="" & !(namefrst==fs_namefrst & namelast==fs_namelast)`. Any record where human transcribers provide complete names but the model outputs blank (e.g. segmentation failure or unreadable text) is dropped from disc_s rather than counted as a failure of the model to match humans in nei_s.

**Why it matters**  
The paper reports these percentages as model agreement conditional on human transcribers disagreeing. Conditioning the denominator on non-empty model outputs creates survivorship/coverage selection bias by evaluating the model only on records it successfully transcribed. Because illegibility causing human disagreement also causes model transcription omission, dropping model blanks from the denominator shrinks disc_s and artificially inflates the headline agreement percentage (Tanc_s + Tfs_s)/Tdisc_s. Vacuous ""=="" agreement is fully prevented by requiring only the four human fields to be non-empty.

**How to check**  
Across state files, run: count if namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast) & (namefrst_ml=="" | namelast_ml_ditto==""). Sum this count across all states to quantify omitted records. Add this total to Tdisc_s and Tnei_s to evaluate the impact on reported agreement rates.

**Suggested fix**  
Define the strict denominator using only the four human fields: namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & !(namefrst==fs_namefrst & namelast==fs_namelast). Do not condition disc_s on namefrst_ml!="" & namelast_ml_ditto!="". Keep the model equality conditions as-is, and classify records where the model produces missing/empty output into nei_s (or report an explicit unread/omitted category).

---

### 2. CSV output writes vacuous-match-prone as-coded variant under primary column names

`as-coded-columns-retain-vacuous-matches` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `CODE/compute_model_agreement_on_discordant.do:46, CODE/compute_model_agreement_on_discordant.do:61-77, CODE/compute_model_agreement_on_discordant.do:97, CODE/compute_model_agreement_on_discordant.do:119`

**What the code does**  
The script computes the as-coded variant where `(namefrst!=""|namelast!="")` allows one name field to be blank, permitting vacuous agreement via Stata's `""==""` semantics. Although lines 19-22 document that the draft uses the strict variant and warn against publishing as-coded rates, lines 46, 97, and 119 write the as-coded metrics under the unqualified column names `disc,anc,fs,both,nei`, while the strict variant is relegated to `_s` suffixes.

**Why it matters**  
Any downstream Stata script or analysis importing model_vs_human_discordant.csv referencing the default column names `disc, anc, fs` will ingest the counts contaminated by empty-string matches rather than the strict counts.

**How to check**  
Inspect the generated CSV file header and rows; confirm that columns disc, anc, fs, both, and nei correspond to the as-coded lines 61-77. Check downstream analysis scripts to verify whether they ingest the un-suffixed columns.

**Suggested fix**  
Rename the CSV columns to distinguish the variants explicitly (e.g., disc_ascoded, anc_ascoded vs disc_strict, anc_strict) or write only the strict variant to the primary columns.

---

### 3. Console display labels FamilySearch matches without the 'only' qualifier used for Ancestry

`asymmetric-display-labels-familysearch-only` · **nit** · correctness · confidence: **verified** (traced in source)

**Where:** `CODE/compute_model_agreement_on_discordant.do:128-129, CODE/compute_model_agreement_on_discordant.do:138-139`

**What the code does**  
Lines 128 and 138 print "matches Ancestry only   :", whereas lines 129 and 139 print "matches FamilySearch    :" without "only". Both counts (fs and fs_s) explicitly negate agreement with Ancestry in code.

**Why it matters**  
The asymmetric labeling suggests FamilySearch agreement might be an inclusive or marginal share, whereas both categories are mutually exclusive source-only matches.

**How to check**  
Compare the display text at lines 128-129 and lines 138-139 against the count conditions at lines 67 and 88.

**Suggested fix**  
Update lines 129 and 139 to display "matches FamilySearch only:" to match the Ancestry label format.

---

## Checked and sound

- **Completeness assertion halts execution and suppresses output on missing or unreadable state files.** — CODE/compute_model_agreement_on_discordant.do:110-117 asserts that nok equals word count of states, erases the CSV file, and exits with code 459 before writing the TOTAL row or displaying percentages if any state fails to load.
- **Strict variant completely eliminates empty-string agreement.** — CODE/compute_model_agreement_on_discordant.do:82-95 requires all six compared name fields to be non-empty (namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="" & namefrst_ml!="" & namelast_ml_ditto!=""), completely precluding vacuous ""=="" evaluations in the strict variant.
- **Strict categories partition the discordant denominator exhaustively and mutually exclusively.** — CODE/compute_model_agreement_on_discordant.do:85-95 partitions disc_s into mutually exclusive anc_s, fs_s, both_s, and nei_s. By transitivity of string equality, both_s is logically 0 under human discordance.
- **Percentage calculations are guarded against division by zero.** — CODE/compute_model_agreement_on_discordant.do:127 and :137 guard display divisions behind if `Tdisc'>0 and if `Tdisc_s'>0.
- **Macro accumulation and CSV columns are consistent and correctly ordered.** — CODE/compute_model_agreement_on_discordant.do:39-41 initializes all 10 counters to 0, lines 99-101 accumulate each metric identically, and lines 46, 97, and 119 maintain identical column ordering across header, state rows, and TOTAL.
- **File loading and output paths avoid working-directory drift.** — CODE/compute_model_agreement_on_discordant.do:31-33 and :50 construct full paths with forward slashes and do not rely on cd commands, preventing directory corruption across iterations.
- **No unchecked merge or join operations exist in the review target.** — CODE/compute_model_agreement_on_discordant.do:50 loads pre-merged datasets via use ... using rather than performing merges within the script.

## What this review could not establish

- Census microdata on Dropbox (D:/SNU ECON Dropbox/.../DATA/TRANSCRIPTIONS/) were not accessible in the review environment, so the exact number of model omissions and numerical impact could not be calculated.
- The Stata pipeline was not executed; all runtime findings are inferred from reading the source code and Stata language semantics.
- No paper draft was supplied, so text claims in DHTS-2024-11-18.tex could not be audited directly.
- Only the requested correctness dimension was reviewed. Replication, claims-vs-code, and identification were out of scope for this run.
