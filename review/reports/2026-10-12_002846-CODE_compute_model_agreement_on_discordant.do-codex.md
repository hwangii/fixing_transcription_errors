# Codex review

*Rendered 2026-10-12 00:32. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-10-12_002846-CODE_compute_model_agreement_on_discordant.do-codex.json`*

**Dimensions:** correctness

**Result:** 3 major

## Summary

The script does not safely support an “all-states” result: it excludes Alaska and Hawaii and can silently publish totals after additional states fail to load. Its as-coded agreement measure also counts blank-to-blank field comparisons as agreement, so the strict variant—or a more targeted nonmissing rule—should be used for reported agreement rates.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | Failed state loads are skipped while an incomplete TOTAL is still written | `CODE/compute_model_agreement_on_discordant.do:43-48, CODE/compute_model_agreement_on_discordant.do:99-112` | |
| 2 | MAJOR | likely | The as-coded rates can classify blank-to-blank fields as model agreement | `CODE/compute_model_agreement_on_discordant.do:54-70, CODE/compute_model_agreement_on_discordant.do:105-112` | |
| 3 | MAJOR | verified | The advertised all-states calculation omits Alaska and Hawaii | `CODE/compute_model_agreement_on_discordant.do:1-7, CODE/compute_model_agreement_on_discordant.do:28-30` | |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Failed state loads are skipped while an incomplete TOTAL is still written

`incomplete-run-still-publishes-total` · **MAJOR** · correctness · confidence: **verified** (traced in source)

**Where:** `CODE/compute_model_agreement_on_discordant.do:43-48, CODE/compute_model_agreement_on_discordant.do:99-112`

**What the code does**  
The state load is wrapped in `capture use ...`; on any nonzero `_rc`, the code executes `continue`. It nevertheless writes `TOTAL,...` and reports percentages based on the successfully loaded states, without asserting that `nok` equals the 49 entries in `states`. The intended complete-universe computation should fail rather than produce publication-ready partial totals.

**Why it matters**  
A missing, corrupt, or schema-incompatible state file changes every aggregate count and percentage without stopping the run. Although `nok` appears in console output, the CSV contains no completeness flag and can be consumed as if it represented the full intended sample.

**How to check**  
After a run, execute `import delimited "D:/SNU ECON Dropbox/sam hwang/fixing_transcription_errors/DATA/INTERMEDIATE/model_vs_human_discordant.csv", clear` followed by `count if state!="TOTAL"`; the result must be 49. Also search the run log for `COULD NOT READ`.

**Suggested fix**  
Track failed states and abort before writing the TOTAL or reporting percentages unless `nok==49`. Write the final CSV only after the completeness assertion succeeds.

---

### 2. The as-coded rates can classify blank-to-blank fields as model agreement

`empty-field-agreement-inflation` · **MAJOR** · correctness · confidence: **likely** (implied, depends on unseen data)

**Where:** `CODE/compute_model_agreement_on_discordant.do:54-70, CODE/compute_model_agreement_on_discordant.do:105-112`

**What the code does**  
The denominator requires only `(namefrst!=""|namelast!="")` and `(fs_namefrst!=""|fs_namelast!="")`, while agreement requires equality on both fields, such as `namefrst==namefrst_ml & namelast==namelast_ml_ditto`. Because Stata evaluates `""==""` as true, a record can be labeled as matching a source even when one of the two asserted field matches is merely two blanks. The intended whole-name agreement measure should establish that each compared field is observed, or explicitly define and report partial-name agreement.

**Why it matters**  
The displayed Ancestry, FamilySearch, and “one of the two” percentages can overstate substantive transcription agreement. The strict variant avoids this, but the script still emits and foregrounds the contaminated as-coded alternative for possible use in the paper.

**How to check**  
Within each state file, rerun the line-57 condition with `& (namefrst=="" | namelast=="")` and the line-60 condition with `& (fs_namefrst=="" | fs_namelast=="")`; sum those counts across states. Any positive count is an as-coded agreement relying on at least one empty human field.

**Suggested fix**  
Do not use the as-coded rates as whole-name agreement. Prefer the strict rates, or define source-specific eligibility requiring the two fields involved in each claimed match to be nonempty, and report the resulting denominator explicitly.

---

### 3. The advertised all-states calculation omits Alaska and Hawaii

`all-states-label-excludes-two-states` · **MAJOR** · correctness · confidence: **verified** (traced in source)

**Where:** `CODE/compute_model_agreement_on_discordant.do:1-7, CODE/compute_model_agreement_on_discordant.do:28-30`

**What the code does**  
The file describes itself as an `ALL-STATES REPLACEMENT`, but its state list contains 48 states plus DC and omits both `ak` and `hi`. Hawaii is excluded for missing comparison columns, while Alaska is excluded only to match another script's universe.

**Why it matters**  
The resulting number is not an all-states estimate, and omission of two geographically distinctive populations may change the aggregate agreement rate. Matching an earlier production script preserves its sample restriction; it does not justify an all-states label.

**How to check**  
Run `display word count "`states'"` in Stata and inspect the expanded list; it returns 49 jurisdictions and contains neither `ak` nor `hi`. Separately compute Alaska once added and compare the aggregate percentages with and without it.

**Suggested fix**  
Add Alaska when its six required fields are available, build the missing Hawaii comparison merge before claiming national coverage, or relabel the result and paper text explicitly as covering 48 states plus DC with Alaska and Hawaii excluded.

---

## Checked and sound

- **The strict variant prevents empty-string agreement in all six compared fields.** — Every strict denominator and category requires `namefrst`, `namelast`, `fs_namefrst`, `fs_namelast`, `namefrst_ml`, and `namelast_ml_ditto` to be nonempty at CODE/compute_model_agreement_on_discordant.do:75-87.
- **The Ancestry-only, FamilySearch-only, and neither conditions are mutually exclusive and exhaust the discordant denominator.** — The source-specific cells explicitly negate agreement with the other source, while `nei` negates both at CODE/compute_model_agreement_on_discordant.do:57-70. Under the discordance condition, simultaneous full-pair agreement with both sources is logically impossible.
- **Division by zero is guarded for both reported variants.** — Percentage displays are enclosed by `if `Tdisc'>0` and `if `Tdisc_s'>0` at CODE/compute_model_agreement_on_discordant.do:107-123.
- **State processing does not depend on the current working directory.** — The script constructs full input paths and uses them directly at CODE/compute_model_agreement_on_discordant.do:24-26, CODE/compute_model_agreement_on_discordant.do:43.
- **Per-state counts are accumulated consistently into the corresponding total locals.** — The accumulator loop covers all ten reported cells at CODE/compute_model_agreement_on_discordant.do:92-94, and the CSV column and TOTAL orders agree at CODE/compute_model_agreement_on_discordant.do:39, CODE/compute_model_agreement_on_discordant.do:99.
- **No merge or join is performed in the review target.** — The target only loads already-merged state files at CODE/compute_model_agreement_on_discordant.do:43, so no unchecked merge semantics occur within this file.

## What this review could not establish

- The underlying census data were unavailable in the review environment, so the prevalence and numerical effect of blank fields, skipped state files, and the state exclusions could not be measured.
- The Stata pipeline was not run; runtime consequences are inferred from the source and standard Stata semantics.
- No paper draft was supplied, so claims-vs-code could not be reviewed and the intended published choice between the as-coded and strict variants could not be established.
- Only the requested correctness dimension was reviewed. Replication and identification were outside this run.
