# Codex review

*Rendered 2026-11-16 10:34. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_103250-review_briefs_2026-11-16-profile-slide-jw.md-codex.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** 1 major, 1 minor

## Summary

All eight displayed numbers match the generated results and use the intended ours+Anc and sex-specific Jaro-Winkler columns. The main defect is that the visible slide describes a substantially broader sample than the code analyzes; it also leaves the men's Jaro-Winkler aggregation ambiguous.

## Triage

| # | Sev | Conf | Finding | Location | Disposition |
|---|-----|------|---------|----------|-------------|
| 1 | MAJOR | verified | The visible slide presents restricted estimates as covering all attached 1940 records with a death month | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:346-348, MATCHING/profile_names_build.do:43-45, MATCHING/profile_names_jw.do:90-98` || Fixed: first bullet now reads '1940 records (49 states, all four name fields) linked one-to-one to a FamilySearch profile with a death month'; the gender-consistency and usable-profile-name filters stay in the LaTeX comment. |
| 2 | minor | verified | The slide does not disclose that men’s Jaro-Winkler score is an arithmetic mean across two fields | `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:347-356, MATCHING/profile_names_jw.do:139` || Fixed: men's bullet now says 'Jaro-Winkler averaged over the two'. |

> Fill the Disposition column: **Fixed** (with commit) / **Rebutted** (with reason) / **Accepted risk** (with why).

## Findings

### 1. The visible slide presents restricted estimates as covering all attached 1940 records with a death month

`visible-slide-omits-sample-restrictions` · **MAJOR** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:346-348, MATCHING/profile_names_build.do:43-45, MATCHING/profile_names_jw.do:90-98`

**What the code does**  
The slide says only “1940 records attached to a FamilySearch family-tree profile with a death month.” The code first requires `namefrst!="" & namelast!="" & fs_namefrst!="" & fs_namelast!=""`, then defines men as `sex==1 & lower(gender)!="female" & ref_first!="" & ref_last!=""` and women as `sex==2 & lower(gender)!="male" & ref_first!=""`, retaining only `men | wom`. It also covers only the hard-coded 49-jurisdiction model universe. These restrictions appear in the LaTeX comment but not in the audience-visible slide.

**Why it matters**  
The displayed Ns and agreement rates describe a selected human-complete, profile-name-usable, gender-compatible subset, not all attached records with a death month. In particular, the women’s first-name estimates condition on both human surname fields being present even though surnames are not scored. Omitting these restrictions overstates the population to which the comparison applies and obscures potentially consequential selection.

**How to check**  
Tabulate the successive sample sizes in `profile_names_build.do` after the human-complete restriction, profile linkage, gender filter, usable profile-name filter, and death-month filter; compare the final sex-specific counts with 27,334,035 and 23,365,543.

**Suggested fix**  
Add a concise visible qualifier such as “49-jurisdiction, human-complete linked sample; compatible profile gender and usable reference names,” with a footnote if space is tight. For women, explicitly note that the base sample still requires all four human name fields.

---

### 2. The slide does not disclose that men’s Jaro-Winkler score is an arithmetic mean across two fields

`mens-jw-aggregation-not-visible` · **minor** · claims-vs-code · confidence: **verified** (traced in source)

**Where:** `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:347-356, MATCHING/profile_names_jw.do:139`

**What the code does**  
The table labels the measure only “Jaro-Winkler,” while the code computes men’s full-name value as `gen double jn_`s' = (jf_`s' + jl_`s')/2`. This is the mean of separately computed first-name and surname similarities, not Jaro-Winkler similarity of a concatenated full-name string or a requirement that both fields meet a threshold.

**Why it matters**  
A reader cannot determine the estimand from the visible slide, and may interpret the men’s values as full-string similarity. That changes how 0.904 and 0.935 should be understood and compared with the women’s first-name-only scores.

**How to check**  
Compare the men’s displayed values with the `JW full name` columns in `MATCHING/results/profile_names_jw.md:11-13`, then compare the construction at `MATCHING/profile_names_jw.do:139` with the generic slide heading.

**Suggested fix**  
Relabel the heading or bullet as “Jaro-Winkler: men = mean of first-name and surname scores; women = first-name score.”

---

## Checked and sound

- **Every displayed record count, exact-agreement percentage, and Jaro-Winkler value matches the generated results.** — Men Target/All match `MATCHING/results/profile_names_jw.md:11-13`; women Target/All match `MATCHING/results/profile_names_jw.md:35-37`; the slide values are at `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:358-362`.
- **The slide uses ours+Anc rather than the model-only `ours` columns.** — For example, men Target uses 49.6 and 0.935 rather than 47.7 and 0.900, and women Target uses 67.0 and 0.916 rather than 65.6 and 0.885; see `MATCHING/results/profile_names_jw.md:13,37` and the column-generation order at `MATCHING/profile_names_jw.do:206-212`.
- **The ours+Anc construction is field-by-field fallback to Ancestry when the raw model field is empty.** — `MATCHING/profile_names_jw.do:108-118` constructs `namefrst_mf` and `namelast_mf` with `cond(fb_*, Ancestry, model)`, consistent with the slide definition at `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:342,367`.
- **Exact agreement guards against empty candidate names, and missing source names receive Jaro-Winkler zero rather than blank-to-blank credit.** — The exact indicators require `cf_`s'!=""` and, for full names, `cl_`s'!=""` at `MATCHING/profile_names_jw.do:132-133`; `jwpair` assigns zero when the source name is empty at `MATCHING/profile_names_jw.do:65-82`.
- **The split-name merge is asserted one-to-one and matched, rather than silently retaining mismatches.** — `MATCHING/profile_names_jw.do:84-88` merges on `_id` using `merge 1:1 ... assert(match)`.
- **The visible language correctly calls the result agreement rather than accuracy and acknowledges the FamilySearch-reference bias.** — The slide warning appears at `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:368`; it is consistent with the stated construction bias at `MATCHING/profile_names_score.do:25-31`.
- **Target and All are mapped to the intended groups, and the LaTeX comment correctly identifies the disagreement definition.** — `MATCHING/profile_names_jw.do:163-165,200-202` maps `disc` to cells 1-4 and `all` to all observations; the underlying first-or-last-name disagreement is constructed at `MATCHING/profile_names_build.do:46-55` and described at `D:/repos/6638fa0fd89fbec05130caeb/slides_ssha2026.tex:344`.
- **The saved log reports a passed exact-agreement check and prints the same result rows as the Markdown artifact.** — `MATCHING/profile_names_jw.log:543-544` records `CHECK PASSED`; the men and women death-month rows are printed at `MATCHING/profile_names_jw.log:597-603,611-617`.

## What this review could not establish

- No paper draft was supplied, so claims-vs-code review was limited to the target slide and its comments; broader paper claims could not be checked.
- The underlying data were not available for inspection and the Stata pipeline was not rerun. Runtime results were assessed from source, the generated Markdown, and the supplied log.
- The slide deck was not compiled because the review was read-only, so visual overflow or rendering problems were not tested.
