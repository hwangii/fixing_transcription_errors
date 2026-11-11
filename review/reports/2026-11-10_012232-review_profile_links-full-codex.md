# Codex review

*Rendered 2026-11-10 01:24. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-10_012232-review_profile_links-full-codex.json`*

**Dimensions:** correctness, claims-vs-code, replication, identification

**Result:** 4 major

## Summary

The SQL classification logic, Stage-1 parser, and table arithmetic are internally coherent, with strong fail-fast reconciliation checks. The main problem is interpretation: FamilySearch profile agreement is labeled as correctness, and the overall Census Tree scores include links derived from the same FamilySearch tree used as the benchmark. Reproducibility is also blocked by machine-specific paths and an unspecified Python environment.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | Agreement with FamilySearch profiles is reported as correctness despite lacking ground truth | `profile_links_vs_machine.py:21-25, profile_links_vs_machine.py:197-204, README.md:10-12, diagnostics_stage1.md:50-51` | |
| 2 | MAJOR | verified | Overall Census Tree scores include links sourced from the FamilySearch tree used as the benchmark | `profile_links_vs_machine.py:117-118, profile_links_vs_machine.py:123-167, profile_links_vs_machine.py:205-224` | |
| 3 | MAJOR | likely | Recall and precision condition on successful FamilySearch attachment, selecting the easiest records | `profile_links_vs_machine.py:107-110, profile_links_vs_machine.py:140-167, profile_links_vs_machine.py:187-204` | |
| 4 | MAJOR | verified | The analysis cannot be reproduced outside the author's machine from this package | `config.py:68-90, config.py:109-121, profile_links_vs_machine.py:50-59` | |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Agreement with FamilySearch profiles is reported as correctness despite lacking ground truth

`profile-agreement-labeled-ground-truth` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:21-25, profile_links_vs_machine.py:197-204, README.md:10-12, diagnostics_stage1.md:50-51`

**What the code does**  
The code counts `a.unique_ID = b.unique_ID` as `same` and `a.unique_ID <> b.unique_ID` as `diff`, then reports `1000*r.diff/j` under the heading `wrong per 1,000 judged`. The documentation likewise calls 11same `correct`, 11diff `wrong`, and the reference report calls this `precision against descendant ground truth`. It actually measures agreement with FamilySearch profile assignments, not verified person identity.

**Why it matters**  
Incorrect or duplicate FamilySearch profiles can make a valid machine link appear different, while a mistaken shared attachment can make a bad link agree. Consequently, the reported quantity cannot support an error rate, correctness, or precision claim without independent validation.

**How to check**  
Draw samples from the 11same and 11diff categories and independently adjudicate identity from census images and non-FamilySearch evidence. Also count cases where the two unique_ID values are known duplicate profiles for the same person.

**Suggested fix**  
Rename the measure throughout to `FamilySearch-profile agreement`, replace `wrong per 1,000` with `different-profile assignments per 1,000`, and reserve correctness or precision language for an independently hand-validated sample.

---

### 2. Overall Census Tree scores include links sourced from the FamilySearch tree used as the benchmark

`ct-benchmark-incorporation-bias` · **MAJOR** · identification · confidence: **verified** (traced in source)

**Where:** `profile_links_vs_machine.py:117-118, profile_links_vs_machine.py:123-167, profile_links_vs_machine.py:205-224`

**What the code does**  
All CT rows enter `found`, `same`, `diff`, and the pooled CT results without excluding `ct_family_tree`. The flag is used only to produce a supplementary precision split through `ft = 1`; the headline per-pair and pooled CT recall and precision still include flagged links.

**Why it matters**  
Agreement for a CT link taken from the FamilySearch tree is partly mechanical when evaluated against FamilySearch profile attachments. Including those rows in the overall CT metric overstates the evidence that CT independently recovers correct links and makes an overall CT-versus-MLP comparison non-comparable.

**How to check**  
Recompute every CT metric twice using `WHERE coalesce(ft,0) <> 1` and `WHERE ft = 1`, including recall and pooled results, then compare the unflagged CT result with the published overall CT result.

**Suggested fix**  
Make unflagged CT results the primary CT benchmark, report flagged CT links as an explicitly non-independent diagnostic, and provide both recall and precision—including pooled values—for each group. Confirm whether any other CT source flags also use FamilySearch information.

---

### 3. Recall and precision condition on successful FamilySearch attachment, selecting the easiest records

`selected-profile-benchmark` · **MAJOR** · identification · confidence: **likely** (implied, depends on unseen data)

**Where:** `profile_links_vs_machine.py:107-110, profile_links_vs_machine.py:140-167, profile_links_vs_machine.py:187-204`

**What the code does**  
Recall is computed only for records present in both yearly clean crosswalks through an inner join on `unique_ID`. Precision excludes machine links unless both endpoints have non-null profile assignments, using `same/(same+diff)`; links with one or neither endpoint attached are omitted from that rate.

**Why it matters**  
FamilySearch attachment is unlikely to be random: legible records, common linkage fields, and easier identities are more likely to receive usable profiles. The resulting agreement and recall rates may therefore be higher than performance for all census records or all machine links. Reporting the judged share does not remove this selection problem.

**How to check**  
For each pair and linkage, compare attachment/judgeability rates by name rarity, race, nativity, age consistency, geography, image quality, and machine-link score. Report best- and worst-case bounds that classify all unjudgeable links as agreement versus disagreement.

**Suggested fix**  
Describe all metrics as conditional on FamilySearch attachment, add covariate balance and subgroup diagnostics for judged versus unjudged links, report bounds, and avoid generalizing these rates to the full census population without an independent probability sample.

---

### 4. The analysis cannot be reproduced outside the author's machine from this package

`machine-specific-unpinned-run` · **MAJOR** · replication · confidence: **verified** (traced in source)

**Where:** `config.py:68-90, config.py:109-121, profile_links_vs_machine.py:50-59`

**What the code does**  
Importing `config` fixes inputs, scratch space, and outputs to literal `D:` and `F:` paths and creates those directories. The script requires `duckdb` and `pandas`, while the reviewed tree contains no requirements, lockfile, environment specification, or configurable command-line paths.

**Why it matters**  
An external replicator cannot locate the inputs or reproduce the software environment, and importing the configuration can mutate the filesystem before analysis begins. Package results therefore cannot be regenerated from the supplied tree.

**How to check**  
Copy the five reviewed files to a clean machine or container and run `python profile_links_vs_machine.py`; verify that the drive paths are unavailable and that no documented command provisions the required dependency versions or data layout.

**Suggested fix**  
Accept input/output roots through a documented configuration file or CLI, remove directory creation from module import, provide a pinned Python environment, and document provenance and expected checksums/schema for every input.

---

## Checked and sound

- **Backbone and machine-link uniqueness assumptions are checked before category calculations.** — The script compares row counts with distinct histid and unique_ID counts and rejects null backbone keys at profile_links_vs_machine.py:95-101; it similarly requires each machine-link endpoint to be unique at profile_links_vs_machine.py:119-121.
- **Recall categories partition profile links under the enforced one-to-one assumptions.** — The exact match, alternative-link, and neither-linked predicates at profile_links_vs_machine.py:124-133 are mutually exclusive after the uniqueness check, and their sum is explicitly checked against the profile-link denominator at profile_links_vs_machine.py:135-138.
- **Precision categories are exhaustive and null-safe.** — The same-profile, different-profile, one-attached, and neither-attached predicates explicitly handle null profile IDs at profile_links_vs_machine.py:141-152.
- **The key recall and precision event is reconciled from both directions.** — The script stops unless profile links found exactly equal machine links whose two endpoints share a profile at profile_links_vs_machine.py:155-156.
- **Stage-1 parsing isolates the intended sections and rejects incomplete extraction.** — Section labels are parsed at profile_links_vs_machine.py:75-85, so section `3b` is distinct from `3`, and the parser requires exactly 16 rows from each intended table at profile_links_vs_machine.py:86-87.
- **Current classifications are reconciled to the Stage-1 totals.** — For every linkage and pair, total links, 11same, and 11diff must match the parsed Stage-1 report at profile_links_vs_machine.py:157-158.
- **Markdown per-pair and pooled arithmetic uses the stated denominators.** — Recall percentages divide by profile links at profile_links_vs_machine.py:191-193; precision and disagreement divide by `same + diff` at profile_links_vs_machine.py:201-204; pooled quantities are summed and recomputed at profile_links_vs_machine.py:218-224.
- **The source files are syntactically valid Python.** — AST parsing succeeded for classify.py, config.py, and profile_links_vs_machine.py; the reviewed target's entry point is at profile_links_vs_machine.py:230-231.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to claims embedded in README.md, diagnostics_stage1.md, docstrings, and generated report text.
- The underlying parquet and Stata datasets were unavailable, and the new script was explicitly described as not yet run; runtime counts and data-dependent effects could not be verified.
- The Stata pipeline was not runnable or relevant to this Python-only review target.
- The provenance and semantics of CT flags other than `ct_family_tree` were not supplied, so their independence from FamilySearch could not be established.
- Data-dependent selection bias is strongly plausible but its magnitude cannot be determined without the inputs or an independent validation sample.
