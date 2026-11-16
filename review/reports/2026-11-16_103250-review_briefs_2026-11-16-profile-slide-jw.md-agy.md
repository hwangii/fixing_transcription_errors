# Antigravity review

*Rendered 2026-11-16 10:40. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_103250-review_briefs_2026-11-16-profile-slide-jw.md-agy.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 major, 2 minor

## Summary

All eight numbers and four sample sizes on the revised slide exactly reproduce MATCHING/results/profile_names_jw.md using the intended ours+Anc series and sex-specific Jaro-Winkler columns. The primary claims-vs-code defect is that the visible slide text omits multiple restrictive sample criteria (49 model states, human completeness across all four name fields, non-contradictory sex, and usable parsed names), presenting selected estimates as if they covered all attached records with a death month. In addition, the slide leaves the men's Jaro-Winkler aggregation (an arithmetic mean of two separately computed field scores) undisclosed, and defines women's 'Target' discordance across first or last name even though women are evaluated exclusively on first names.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | Visible slide presents heavily restricted sample as all 1940 records attached to a profile with a death month | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:346-348, MATCHING/profile_names_build.do:31-64,43-45, MATCHING/profile_names_jw.do:90-98` || Fixed: first bullet now reads '1940 records (49 states, all four name fields) linked one-to-one to a FamilySearch profile with a death month'; the gender-consistency and usable-profile-name filters stay in the LaTeX comment. |
| 2 | minor | verified | Slide does not disclose that men's Jaro-Winkler score is the unweighted arithmetic mean of first-name and surname similarities | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:347-356, MATCHING/profile_names_jw.do:134-139` || Fixed: men's bullet now says 'Jaro-Winkler averaged over the two'. |
| 3 | minor | verified | Women's 'Target' row defines discordance across first or last name, including records where human first names agree | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:344,361-362, MATCHING/profile_names_build.do:46-55, MATCHING/profile_names_jw.do:164,201` || Accepted risk: Target is the deck's definition throughout (Ancestry and FamilySearch disagree on first or last name), so the women's row covers the same records as the other slides; a LaTeX comment now notes it includes women whose first names agree, which is why Ancestry's women's target share (53%) is far above the men's. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. Visible slide presents heavily restricted sample as all 1940 records attached to a profile with a death month

`visible-slide-omits-sample-restrictions` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:346-348, MATCHING/profile_names_build.do:31-64,43-45, MATCHING/profile_names_jw.do:90-98`

**What the code does**  
The audience-visible slide bullet at line 346 states: '1940 records attached to a FamilySearch family-tree profile with a death month.' In the code, the analyzed sample is subject to multiple cumulative restrictions: (1) restricted to 49 jurisdictions (Alaska and Hawaii excluded, MATCHING/profile_names_build.do:31-64); (2) human-complete condition: requires all four commercial name fields to be present (namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!="", MATCHING/profile_names_build.do:43-45) -- conditioning women on human surnames even though women are scored on first name only; (3) strict 1:1 crosswalk match: drops records attached to >1 profile and profiles attached to >1 record (MATCHING/profile_names_build.do:89-100); (4) profile gender cannot contradict census sex (MATCHING/profile_names_jw.do:96-97); (5) parsed profile reference name components must be usable (ref_first!="" & ref_last!="" for men; ref_first!="" for women); and (6) all ages included (0 to 100+), contrasting with the men 10+ cutoff on subsequent linkage slides. While these restrictions appear in the LaTeX comments (lines 339-342), none appear on the audience-facing slide.

**Why it matters**  
An audience or referee will understand the reported counts (27.3M men, 23.4M women) as representing the population of all linked records with a death month, rather than a highly selected subset with four non-empty human transcription fields and compatible profiles. For women, conditioning the first-name evaluation on commercial surname completeness excludes women whose surnames were missing or unindexed in either source. Furthermore, removing '(all ages)' from the previous slide revision leaves an unstated contradiction with the identical 'Target records' and 'All records' labels on slides 399 and 426, which restrict to men aged 10+.

**How to check**  
Trace sample attrition across filters in MATCHING/profile_names_build.do and MATCHING/profile_names_jw.do, verifying how many attached records with death months are excluded by the 49-state, human-completeness, 1:1 match, gender-consistency, and parsed-name filters before arriving at the reported 27,334,035 men and 23,365,543 women.

**Suggested fix**  
Add a concise visible qualifier or table note stating: '49 model states; human-complete (all four human name fields present); 1:1 linked profiles with compatible sex and usable names; all ages.' For women, explicitly note that the base sample requires commercial surnames even though surnames are not scored.

---

### 2. Slide does not disclose that men's Jaro-Winkler score is the unweighted arithmetic mean of first-name and surname similarities

`mens-jw-aggregation-not-visible` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:347-356, MATCHING/profile_names_jw.do:134-139`

**What the code does**  
The slide bullets state 'Men: first name and surname; women: first name only' and 'Agree: names identical; Jaro-Winkler: similarity, 1 = identical', and the table heading labels the columns simply 'Jaro-Winkler'. In code (MATCHING/profile_names_jw.do:139), men's full-name Jaro-Winkler value is computed as 'gen double jn_s = (jf_s + jl_s)/2', which is the unweighted arithmetic average of separately computed first-name and surname similarities.

**Why it matters**  
A reader cannot determine how full-name Jaro-Winkler similarity is constructed from the visible slide. Standard expectations for multi-token or full-name string similarity include computing Jaro-Winkler on concatenated strings (which produces different values because Winkler's 4-character prefix bonus applies only to the beginning of the first name, giving the surname zero prefix weighting). Averaging the two field scores separately grants independent prefix bonuses to both first name and surname. In addition, displaying men's two-field average (0.935) alongside women's single first-name score (0.916) under an identical column header invites misleading direct comparisons without disclosing that the estimands differ in field structure.

**How to check**  
Compare MATCHING/results/profile_names_jw.md:11-13 columns 'JW full name' (0.904 / 0.935) with 'JW first' (0.891 / 0.912) and 'JW surname' (0.917 / 0.958); confirm that 0.904 = (0.891 + 0.917)/2 and 0.935 = (0.912 + 0.958)/2. Verify that neither the slide bullets nor table headers state that Men's JW is an arithmetic mean of two separate field similarities.

**Suggested fix**  
Clarify in the bullet or table footnote: 'Jaro-Winkler: mean of first-name and surname scores for men; first-name score for women.'

---

### 3. Women's 'Target' row defines discordance across first or last name, including records where human first names agree

`womens-target-discordance-includes-surname-disagreements` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:344,361-362, MATCHING/profile_names_build.do:46-55, MATCHING/profile_names_jw.do:164,201`

**What the code does**  
The slide defines women as scored on first name only ('women: first name only'), but groups records into 'Target' using 'disc = !(namefrst==fs_namefrst & namelast==fs_namelast)' from MATCHING/profile_names_build.do:46. This assigns a record to 'Target' whenever Ancestry and FamilySearch disagree on *either* first name *or* surname. As a result, women's 'Target' records include records where Ancestry and FamilySearch have identical first names and disagree only on surname.

**Why it matters**  
The presentation frames 'Target records' as challenging cases where commercial transcribers disagree and our model breaks the tie. For women, however, because only first names are evaluated, records with identical commercial first names (differing only in surname) are pooled into 'Target'. This mechanically inflates the baseline first-name agreement rate on 'Target' records (Ancestry achieves 53.0% and Ours achieves 67.0% on women Target, compared to 17.1% and 49.6% on men Target), conflating genuine first-name tie-breaking with cases where human transcribers were already in full agreement on the scored field.

**How to check**  
In profile_names.dta, count how many observations with 'sex==2 & inrange(cell,1,4)' satisfy 'namefrst == fs_namefrst'. Tabulate exact agreement on profile first name separately for female records that disagree on first name versus those that disagree only on surname.

**Suggested fix**  
Either define women's 'Target' records based on first-name discordance ('namefrst != fs_namefrst'), or add a note clarifying that Target records include cases discordant on either name field, meaning human first names agree for a substantial fraction of target women.

---

## Checked and sound

- **All eight displayed numbers and four record counts match MATCHING/results/profile_names_jw.md exactly.** — Men Target/All values (6,897,127 records, 17.1% / 49.6% exact, 0.904 / 0.935 JW; 27,334,035 records, 58.4% / 64.1% exact, 0.945 / 0.950 JW) match MATCHING/results/profile_names_jw.md:11-13; Women Target/All values (6,250,365 records, 53.0% / 67.0% exact, 0.894 / 0.916 JW; 23,365,543 records, 71.8% / 74.9% exact, 0.924 / 0.929 JW) match MATCHING/results/profile_names_jw.md:35-37; slide table is at D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:358-362.
- **The slide uses the intended ours+Anc columns rather than raw model-only columns.** — On Target records, the slide reports Ours exact agreement as 49.6% for men and 67.0% for women, and Ours JW as 0.935 for men and 0.916 for women; these correspond to the ours+Anc columns of MATCHING/results/profile_names_jw.md:13,37 rather than raw ours (47.7%, 65.6%, 0.900, 0.885).
- **The ours+Anc construction correctly implements field-by-field fallback to Ancestry when the model transcription is empty.** — MATCHING/profile_names_jw.do:108-111 defines fb_f and fb_l as strtrim(ml)=="" and assigns namefrst_mf = cond(fb_f, namefrst, namefrst_ml) and namelast_mf = cond(fb_l, namelast, namelast_ml_ditto), which is accurately described by the visible bullet 'Ours: model names, Ancestry's where the model gave none' at D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:367.
- **Exact agreement and Jaro-Winkler similarity prevent false agreement from empty strings.** — MATCHING/profile_names_jw.do:132-133 requires cf_s!="" and cl_s!="" for exact match indicators, preventing ""=="" inflation; jwpair at MATCHING/profile_names_jw.do:81 assigns outv = 0 if a=="", ensuring missing source names score 0 similarity.
- **Profile name references are attached with verified 1:1 matching without record duplication or Cartesian matches.** — MATCHING/profile_names_jw.do:86-88 merges reference names on row identifier _id using 'merge 1:1 _id using ... assert(match) nogen', ensuring every row matches exactly once.
- **Exact agreement regression check passes and log confirms zero errors.** — MATCHING/profile_names_jw.do:148-177 recomputes exact agreement across all groups and asserts equality against profile_names.md; MATCHING/profile_names_jw.log:543-544 records 'CHECK PASSED: exact agreement reproduces profile_names.md' and exits with RUN-STATA-RC: 0 at line 635.
- **The slide explicitly caveats that the metric is agreement rather than accuracy and discloses the FamilySearch tree bias.** — The visible slide at D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:368 explicitly notes 'Agreement, not accuracy: profiles often draw on FamilySearch's transcription, which favours names that agree with it, as ours often do', consistent with the caution in MATCHING/profile_names_score.do:25-31.

## What this review could not establish

- No paper draft was supplied for this run; claims-vs-code review was conducted against the presentation slide diff (slides_ssha2026.tex), the review brief, and comments/labels embedded in the Stata code.
- The underlying microdata, FamilySearch profile scrapes, and intermediate .dta files reside on external storage drives and could not be inspected or executed in this sandbox.
- The slide deck was not compiled or rendered to PDF because the review environment is read-only, so visual layout, slide geometry, and font sizing could not be visually confirmed.
