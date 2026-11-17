# Antigravity review

*Rendered 2026-11-16 22:18. Source: `D:\repos\fixing_transcription_errors\review\reports\2026-11-16_221250-review_briefs_2026-11-16-profile-slide-modelpresent.md-agy.json`*

**Dimensions:** correctness, claims-vs-code

**Result:** no findings

## Summary

The slide update and supporting do-file changes are verified correct and consistent. Every statistic in the slide table matches the corresponding section and column of MATCHING/results/profile_names_jw.md, the sample restrictions and column definitions are accurately described, and the post-run edits to the do-file do not alter any numerical results. The slide explicitly clarifies that FamilySearch profiles reflect agreement rather than ground-truth accuracy.

## Findings

None reported. Read the section below before trusting that.

## Checked and sound

- **Slide table values match profile_names_jw.md exactly across all rows and columns** — Checked all 20 numerical values in slides_ssha2026.tex:362-366 against MATCHING/results/profile_names_jw.md lines 11, 13, 23, and 25. Men Target (disc) records (6,344,776), exact agreement (Ancestry 17.0%, Ours 51.9%), and full name JW (Ancestry 0.906, Ours 0.939) match lines 9-13; Men All records (26,230,508), exact agreement (Ancestry 59.1%, Ours 65.0%), and full name JW (Ancestry 0.946, Ours 0.951) match line 11; Women Target (disc) records (6,020,539), exact first agreement (Ancestry 53.7%, Ours 68.2%), and first name JW (Ancestry 0.896, Ours 0.919) match lines 21-25; Women All records (22,952,453), exact first agreement (Ancestry 72.2%, Ours 75.4%), and first name JW (Ancestry 0.925, Ours 0.930) match line 23.
- **Slide text and comments match sample definitions and scoring rules in the code** — slides_ssha2026.tex:336-353,371-373 accurately document the sample restrictions (1940 census, 49 model states, 4 human name fields present, 1:1 linked to FS profile without sex contradiction and with death month), gender-specific scoring (both names and average JW for men, first name only for women), and the 'model names present' restriction without fallback to Ancestry (matching MATCHING/profile_names_jw.do:85-155). The slide comments also correctly explain why Ancestry's target agreement is higher for women (women's target includes records where surnames disagree but first names agree, while scoring is on first names only).
- **Model-present indicator (hasml) strictly implements the stated condition** — MATCHING/profile_names_jw.do:135-155 defines hasml as `(men & hm_f & hm_l) | (wom & hm_f)` where hm_f and hm_l verify non-empty normalized model first name and surname after pnorm normalisation (cf_ml!="" and cl_ml!=""). Both Ancestry and Ours are summarized under this identical restriction in MATCHING/profile_names_jw.do:222.
- **Post-run do-file edits do not affect numerical calculations** — The two edits in MATCHING/profile_names_jw.do (adding an explanatory sentence in the file write header at line 197 and replacing empty cell display with '-' when r(N)==0 at line 225) only alter output formatting and documentation; they modify no data variables or estimation routines.
- **Hand-edited markdown matches do-file output formatting** — MATCHING/results/profile_names_jw.md:5 matches the verbatim text added in MATCHING/profile_names_jw.do:197, and MATCHING/results/profile_names_jw.md:17 contains '-' across all measures for group 4 (N=0) of men with model names present, exactly matching `if r(N)==0 local v "-"` at MATCHING/profile_names_jw.do:225.
- **Appropriate epistemic framing avoids overclaiming agreement as accuracy** — slides_ssha2026.tex:335,346,372 and MATCHING/results/profile_names_jw.md:5 explicitly frame the comparison as 'Agreement with FamilySearch profiles' rather than accuracy, and prominently include the disclaimer bullet: 'Agreement, not accuracy: profiles often draw on FamilySearch's transcription, which ours often match'.

## What this review could not establish

- No paper draft was supplied (review target was restricted to the slide diff in slides_ssha2026.tex and the brief); paper-wide claims-vs-code verification could not be performed beyond the slide and code comments.
- The external census and FamilySearch profile datasets on external drives (F: and Dropbox) were not directly readable, and the full Stata pipeline was not runnable in this review environment.
- Runtime verification of exact numbers relies on the verified execution log (MATCHING/profile_names_jw.log) and embedded do-file assertion checks rather than fresh pipeline re-execution.
