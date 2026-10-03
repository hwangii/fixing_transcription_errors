# Codex review

*Rendered 2026-10-02 05:12. Source: `review/reports/2026-10-02_033757-Census_Transcriptions-full-agy.json`*

**Dimensions:** correctness, claims-vs-code, replication, identification

**Result:** 1 blocker, 4 major, 3 minor

## Summary

The replication package is remarkably thorough and clearly documents its own limits, but suffers from critical classification masking in its linkage evaluations. The 1940-centric verification silently classifies 1930 records linked to out-of-sample 1940 records as 'Unverifiable' rather than 'Contradicted', masking false positives. Additionally, denominators are inconsistently defined across the three linkage tables, with the HLINK denominator including women despite captions claiming men only.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | BLOCKER | verified | 1940-centric verification masks false positives as 'Unverifiable' | `code/02_hlink/linkage_analysis_newlinks.do:295, code/01_abe_jw/linkage_analysis.do:607` | **CONFIRMED** — severity: major (blocker only if the draft quotes Contradicted as a false-positive rate) |
| 2 | MAJOR | verified | HLINK denominator includes women while caption claims men only | `code/02_hlink/linkage_analysis_newlinks.do:180-183, 491` | **CONFIRMED** — already in Deaglan's own §6; Overleaf caption is the correct one |
| 3 | MAJOR | verified | Mortality table uses BUNMD denominator, unlike other tables | `code/03_mortality/05_make_linkage_table.do:38` | **CONFIRMED** — three tables, three denominators |
| 4 | MAJOR | verified | Package relies on external or missing inputs for complete replication | `DOCUMENTATION.md:306, DOCUMENTATION.md:311` | **CONFIRMED** — matches §6; usa_00015.dat still missing |
| 5 | MAJOR | verified | Evaluating accuracy on a linked sample creates an upper bound | `code/01_abe_jw/linkage_analysis.do:300` | **ACCEPTED** — identification caveat for the text, not a code defect |
| 6 | minor | verified | Match rate can exceed 100% due to one-to-many pairs | `code/02_hlink/linkage_analysis_newlinks.do:93, 270` | **CONFIRMED — upgraded to major**: link file is not one-to-one; `first40` flag exists but is unused |
| 7 | minor | verified | Missing ages retained as positive infinity in denominator | `code/02_hlink/linkage_analysis_newlinks.do:182` | **CONFIRMED** — magnitude needs the data |
| 8 | minor | verified | Run log does not support 'byte-identical' claim | `README.md:17, output/logs/00_run_all_tables.log:3500` | **CONFIRMED** — no identity/diff/checksum anywhere in the 3,505-line master log |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. 1940-centric verification masks false positives as 'Unverifiable'

`unverifiable-masks-false-positives` · **BLOCKER** · correctness · confidence: **verified** (traced in source)

**Where:** `code/02_hlink/linkage_analysis_newlinks.do:295, code/01_abe_jw/linkage_analysis.do:607`

**What the code does**  
`merge m:1 histid1940 using \`true_by1940', keep(1 3)` classifies pairs with no 1940 truth match (`person_merge == 1`) as Unverifiable, without checking if the 1930 record was in the truth set.

**Why it matters**  
If a 1930 person is in the truth set but linked to an out-of-sample 1940 person, this false positive is counted as 'Unverifiable' rather than 'Directly Contradicted'. This hides errors and inflates the perceived accuracy of the matching algorithm.

**How to check**  
Merge the 'unverifiable' pairs against true_links on histid1930 to see how many have a known true link to someone else.

**Suggested fix**  
Merge matched pairs against the truth set using both histid1930 and histid1940. Classify as contradicted if either ID exists in the truth set but is linked differently.

---

### 2. HLINK denominator includes women while caption claims men only

`hlink-denominator-includes-women` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `code/02_hlink/linkage_analysis_newlinks.do:180-183, 491`

**What the code does**  
Uses divided_file1940_true_cleaned_women_added.dta, applies keep if age >= 8 without a sex filter, and assigns _N to scalar N_men_1940_full.

**Why it matters**  
The table caption explicitly claims 'all men in the 1940 census,' but the denominator includes both men and women, directly contradicting the caption and understating the linkage rate if interpreted as male-only.

**How to check**  
Run tabulate sex on cn1940_full to confirm the presence of women.

**Suggested fix**  
Add keep if sex == 1 before defining the denominator scalar, or update the caption and variables to reflect the full population.

---

### 3. Mortality table uses BUNMD denominator, unlike other tables

`mortality-base-differs` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `code/03_mortality/05_make_linkage_table.do:38`

**What the code does**  
Computes the denominator by keep if sex == 1 & byear <= 1940 on the BUNMD raw file.

**Why it matters**  
This is a completely different denominator base (BUNMD men vs. 1940 census men/population) compared to the other two tables. Readers may incorrectly compare linkage rates across tables assuming a consistent base.

**How to check**  
Compare the denominator definition in 05_make_linkage_table.do:38 with 02_hlink/linkage_analysis_newlinks.do:180.

**Suggested fix**  
Explicitly state in the paper that the mortality linkage rate is conditional on appearing in BUNMD, not the 1940 census.

---

### 4. Package relies on external or missing inputs for complete replication

`missing-external-inputs` · **MAJOR** · replication · confidence: **verified** (traced in source)

**Where:** `DOCUMENTATION.md:306, DOCUMENTATION.md:311`

**What the code does**  
The package relies on usa_00015.dat (missing) and D:\\ABE_JW\\DATA\\ORIGINAL\\matching_intgen1940.dta (outside repo).

**Why it matters**  
An external replicator cannot rebuild the data from raw inputs, violating portability and replication requirements.

**How to check**  
Search the project directory for usa_00015.dat and matching_intgen1940.dta.

**Suggested fix**  
Provide the missing files within $ROOT or document the exact IPUMS extraction criteria to regenerate them.

---

### 5. Evaluating accuracy on a linked sample creates an upper bound

`linked-sample-accuracy-upper-bound` · **MAJOR** · identification · confidence: **verified** (traced in source)

**Where:** `code/01_abe_jw/linkage_analysis.do:300`

**What the code does**  
Evaluates 'Verified Correct' by comparing matched links against mlp_training1930_1940.dta, which is itself a linked sample.

**Why it matters**  
Records with unusually bad transcriptions are less likely to be in the linked ground truth. Therefore, the ground truth under-represents records where the transcription model matters most, meaning measured accuracy is an upper bound.

**How to check**  
Methodological design critique based on sample selection.

**Suggested fix**  
State in the paper that the ground truth selects on records legible enough to be linked, so accuracy figures represent an upper bound.

---

### 6. Match rate can exceed 100% due to one-to-many pairs

`n-linked-pair-count-inflation` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `code/02_hlink/linkage_analysis_newlinks.do:93, 270`

**What the code does**  
duplicates drop histid1930 histid1940, force removes exact duplicate pairs but retains one-to-many links. The match rate uses this pair count.

**Why it matters**  
Because it counts pairs rather than unique individuals, if the method produces many one-to-many links, N_linked can exceed the number of individuals in the denominator, artificially inflating the linkage rate.

**How to check**  
Compare the unique count of histid1930 against _N right before calculating the rate.

**Suggested fix**  
Decide whether the match rate should count unique 1930 individuals linked or total pairs, and document this clearly. If individuals, dedup by histid1930.

---

### 7. Missing ages retained as positive infinity in denominator

`age-missing-values-retained` · **minor** · correctness · confidence: **verified** (traced in source)

**Where:** `code/02_hlink/linkage_analysis_newlinks.do:182`

**What the code does**  
keep if age >= 8 evaluates missing values (.) as positive infinity, retaining them.

**Why it matters**  
Missing ages are improperly included in the '8 and above' denominator, slightly inflating it.

**How to check**  
Run count if age == . after the keep if step.

**Suggested fix**  
Change to keep if age >= 8 & !missing(age).

---

### 8. Run log does not support 'byte-identical' claim

`byte-identical-claim-unsupported` · **minor** · replication · confidence: **verified** (traced in source)

**Where:** `README.md:17, output/logs/00_run_all_tables.log:3500`

**What the code does**  
The log shows the table scripts completing but contains no cf or compare commands to computationally verify byte-identity.

**Why it matters**  
The README claims the log supports the byte-identical finding, but the log provides no such evidence, meaning the claim relies on an undocumented manual check.

**How to check**  
grep -i 'identical' output/logs/00_run_all_tables.log yields no results.

**Suggested fix**  
Add an explicit cf or compare step at the end of the master script to computationally assert byte-identity.

---

## Checked and sound

- **Numerator and denominator for the restricted sample identically filter on congruent == 0.** — code/02_hlink/linkage_analysis_newlinks.do:197 and :267 both merge against restr1940.
- **Empty strings correctly handled in middle-initial agreement, preventing false inflation.** — code/02_hlink/linkage_analysis_newlinks.do:326 explicitly requires keep if mi1930 != '' & mi1940 != ''.
- **build_matched_links.do is an independent reconstruction, not a copy of prep_HLINK_matches.do.** — code/02_hlink/build_matched_links.do uses merge m:1 keep(master) for collision dropping, whereas _archive/code/prep_HLINK_matches.do uses append and bysort group tracking.
- **ABE reconstruction exactness test is valid.** — code/01_abe_jw/linkage/validate_abe_reconstruction.do tests pairs exactly on Massachusetts, rather than just matching counts.

## What this review could not establish

- Data (325 GB) cannot be read directly.
- Master script takes ~4h and was not run; inference is based purely on source reading and logs.
- HLINK matching logic was performed by a third party and is not in the repository, so it cannot be audited or regenerated.
- mlp_training1930_1940.dta extraction script is missing, so 1930-1940 subsetting from the full MLP crosswalk could not be verified.

## Claude's verification (2026-10-02)

Every finding was checked against the source before acceptance. Antigravity
(gemini-3.1-pro-high, plan mode, 265 s, 128k tokens, no denied actions).

### 1. One-sided truth classification — CONFIRMED, major

`linkage_analysis_newlinks.do:295` merges linked pairs on **`histid1940` only**
against `true_by1940`; `person_merge==1` → *Unverifiable*, `==3` with matching
`histid1930` → *Verified*, `==3` otherwise → *Contradicted*. There is no
1930-side check anywhere in the block (`:285-315`); the FN step at `:307`
measures recall only. So a pair whose 1940 record is outside the truth set is
called *Unverifiable* **even when its 1930 record is in the truth set paired
with a different 1940 record** — a wrong link, by the truth set's own
testimony. *Contradicted* is undercounted and *Unverifiable* overcounted, in
both the old and new arms. Whether this is a blocker depends on the draft: if
it presents *Directly Contradicted* as a false-positive rate, it is one. Fix:
also merge on `histid1930` against `true_by1930` and classify a pair as
contradicted if either side's truth partner differs.

### 2. HLINK denominator is men **and** women — CONFIRMED

Input is `divided_file1940_true_cleaned_women_added.dta` (`:180-183`); the
scalar is still named `N_men_1940_full` and the caption says "all men".
Deaglan's `DOCUMENTATION.md` §6 admits the naming is stale. The Overleaf
caption ("men and women aged 8+") is the correct one; the package regenerated
the stale wording.

### 3. Three tables, three denominators — CONFIRMED

ABE/JW: men aged 8+ in the 1940 census (`clean_names_1940_new`, men only).
HLINK: men **and** women aged 8+. Mortality (`05_make_linkage_table.do:38-42`):
**BUNMD death records**, `sex==1 & byear<=1940`. The draft must not present the
three match rates as one series.

### 6. Match rate is a pair count — CONFIRMED, upgraded to major

`:270` sets `N_linked = _N` after `prep_links`, whose only dedup is
`duplicates drop histid1930 histid1940` (`:93`, exact pairs). The link builder
`build_matched_links.do:207,220` computes `first30`/`first40` flags
(`by histid1940: _n==1`) but only for its summary — it never keeps one link
per person. So the published "Match Rate" is pairs ÷ persons, and any 1940
person with several candidate 1930 links inflates it. Current values (58-60%)
are below 100% only because multiplicity is modest; the retired table's 116%
shows what happens when the denominator shrinks. Fix is one line: compute the
rate on `first40 == 1`. Independently found by Claude before this review ran.

### 7. Missing ages retained — CONFIRMED

`:182` is `keep if age >= 8` with no `& !missing(age)`; in Stata `.` exceeds
any number, so records with missing age enter the denominator. Magnitude
unknown without the data. Exactly the checklist's first Stata trap.

### 8. "Byte-identical" is unsupported — CONFIRMED

`README.md:17` claims every table reproduced byte-identically on 2026-09-06.
`output/logs/00_run_all_tables.log` (3,505 lines) contains no `cf`, `diff`,
checksum or comparison step — it writes the five tables and stops. If a
comparison happened it is not in the package; the claim should be made by a
script or withdrawn.

### Agreements with the scope file's prior findings

Age cutoff 8 (`:182`, `linkage_analysis.do:38`); restricted-sample numerator and
denominator both filter on `congruent==0` (its `verified_clean` #1 matches my
own read); ABE reconstruction test judged valid; `build_matched_links.do`
judged an independent reconstruction, not a copy.

### Codex pass

Completed later the same day: `2026-10-02_150627-Census_Transcriptions-full-codex.md`.
Side-by-side: `2026-10-02-Census_Transcriptions-comparison.md`. Codex's
`verified_clean` passes Question 3; finding #1 above still stands — see the
adjudication in the Codex report.
