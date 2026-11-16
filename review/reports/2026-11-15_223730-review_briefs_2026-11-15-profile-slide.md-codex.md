# Codex review

*Rendered 2026-11-15 22:39. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-15_223730-review_briefs_2026-11-15-profile-slide.md-codex.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 major, 1 minor

## Summary

The slide reproduces all four reported values exactly and correctly presents the exercise as agreement rather than accuracy. The main defect is that its “Ours” column uses raw model output, while the linkage tables’ “New” names replace missing model fields with Ancestry; those are not the same name set. The displayed sample description also omits the small additional requirement that the parsed profile contain usable first- and last-name components.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | The slide’s “Ours” series is not the same name set that the linkage tables call “New” | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:339-340, MATCHING/profile_names_score.do:182-198, MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do:158-170` || Fixed: column relabelled 'Ours (model)'; slide comment now says raw model names, missing = not agreeing, and that linkage New falls back to Ancestry (would score slightly higher). Not regenerated: raw-model is the conservative version. |
| 2 | minor | verified | The visible sample description omits the usable parsed profile-name restriction | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:342-343, MATCHING/profile_names_score.do:243-250, MATCHING/results/profile_names.md:120-146` || Fixed: usable profile first name and surname now stated in the slide's source comment (excludes 16 of 27.3M records; too small for the slide face). |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. The slide’s “Ours” series is not the same name set that the linkage tables call “New”

`ours-is-not-linkage-new` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:339-340, MATCHING/profile_names_score.do:182-198, MATCHING/1_divide_and_clean_everyoneV5_women_addedV2.do:158-170`

**What the code does**  
The profile score assigns the model fields directly with `local f_ml namefrst_ml` and `local l_ml namelast_ml_ditto`, then requires each normalized field to be nonempty in expressions such as `cf_ml==ref_first & cf_ml!=""`. By contrast, linkage “New” renames those model fields and then executes `replace namefrst_true_cleaned=namefrst_ans if namefrst_true_cleaned=="" & namefrst_ans!=""` and the analogous surname replacement. Thus linkage New is a field-by-field model/Ancestry hybrid, whereas the slide score treats missing model output as disagreement.

**Why it matters**  
The slide comment explicitly equates “Ours” with linkage New, but records with one or both missing model fields receive different names under the two constructions. Consequently the displayed 47.7% and 62.4% agreement rates cannot be interpreted as validation of the exact name input responsible for the linkage-table New results.

**How to check**  
In Stata, merge the profile-scoring records to the linkage-input records by `histid`, then run `count if namefrst_ml=="" | namelast_ml_ditto==""` and tabulate whether linkage New equals Ancestry within those records. Recompute the two profile-agreement rates after applying linkage lines 169-170; compare them with 47.7% and 62.4%.

**Suggested fix**  
Either describe the column as raw model output and remove the claim that it is linkage New, or construct the scored names with exactly the same field-by-field Ancestry fallback and eligibility rules used by the linkage pipeline, then regenerate the table.

---

### 2. The visible sample description omits the usable parsed profile-name restriction

`usable-profile-name-restriction-omitted` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:342-343, MATCHING/profile_names_score.do:243-250, MATCHING/results/profile_names.md:120-146`

**What the code does**  
For the joint first-name-and-surname measure, `scoreblock` defines eligibility as ``svar' & ref_first!="" & ref_last!=""` and then adds `has_dmonth`. The slide instead describes all attached male profiles recording a death month, without saying that profiles whose normalized name cannot supply both parsed components are excluded.

**Why it matters**  
The Records column is not literally all men meeting the displayed conditions. The output shows the restriction is small but real: the joint-name all-record denominator is 27,334,035, versus 27,334,051 for first name and 27,336,289 for surname.

**How to check**  
Run `count if men & has_dmonth`, followed by `count if men & has_dmonth & ref_first!="" & ref_last!=""`, and tabulate which missing parsed component accounts for the difference.

**Suggested fix**  
Add “with a usable profile first name and surname” to the sample description or a table note.

---

## Checked and sound

- **All four slide values match the designated generated-results rows.** — The slide reports Target N=6,897,127, Ancestry=17.1%, Ours=47.7% and All N=27,334,035, Ancestry=58.4%, Ours=62.4% at D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:350-351; these exactly match the `disc` and `all` rows at MATCHING/results/profile_names.md:120-122.
- **Target records are correctly defined as disagreement between Ancestry and FamilySearch on either first name or surname, after requiring all four human fields.** — The build first requires all four fields to be nonempty and defines `disc = !(namefrst==fs_namefrst & namelast==fs_namelast)` at MATCHING/profile_names_build.do:43-46; the score maps `disc` to cells 1-4 at MATCHING/profile_names_score.do:251-254.
- **The 49-state universe and one-to-one profile attachment are enforced rather than merely documented.** — The explicit state list is followed by `assert `z'==49` at MATCHING/profile_names_build.do:31-63. Conflicting record/profile mappings are dropped, both identifiers are checked with `isid`, and only matched census records are retained at MATCHING/profile_names_build.do:85-107.
- **The displayed men, death-month, and noncontradictory-gender restrictions match the scoring code.** — Contradictory profile gender is dropped at MATCHING/profile_names_score.do:166-173; men are `sex==1` at line 202; a profile death-month indicator is constructed at lines 153-160 and imposed in the requested score block at line 285.
- **Empty model names cannot create false agreement through Stata’s `""==""` behavior.** — Every match indicator additionally requires the normalized transcription to be nonempty at MATCHING/profile_names_score.do:193-198; joint agreement is the conjunction of first- and surname indicators at lines 243-247.
- **The slide does not relabel agreement as accuracy and acknowledges the direction of the FamilySearch-reference bias.** — The visible caveat says “Agreement, not accuracy” and explains the FamilySearch-derived-profile bias at D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:355-356, consistent with the warning in MATCHING/profile_names_score.do:25-31.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to the slide text and comments in the review target; broader paper claims could not be checked.
- The external data were not inspected and the Stata pipeline was not run. Reported generated values were checked against the committed Markdown output, while runtime sample composition and rates remain dependent on unseen data.
- The review established the semantic difference between raw model names and linkage New from source code, but could not quantify how much applying the linkage fallback would change the slide percentages.
