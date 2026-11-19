# Brief: MATCHING/linked_groups_socio.do (2026-11-19)

New, read-only script. Author's request: compare socio-demographic characteristics of 1940 men (10+) who are linked to 1930 under both the Ancestry ("before") and the target-only ("after", link1930_1940_mltgt1940) transcription; linked only after; linked in neither. Before-only (lost links) is reported too.

- Input temp_tgt.dta, saved by CODE/create_figures_SSHA2025.do (target-only switch) with linked_before / linked_after (fiveyr==1) and the socio-demographic variables. Gate: N and both linkage rates equal MATCHING/results/create_figures_SSHA2025_tgt.tex raw values.
- Recodes copied from create_figures_SSHA2025.do Figure 4 (the variables used in its loop); labels from CODE/label_socio_demo.do.
- Shares within group among non-missing; mean age, target share, mean legibility.
- Writes MATCHING/results/linked_groups_socio.md.

Check: recodes identical to Figure 4; group assignment; denominators; missing values (Stata . > any number) in recode/levelsof/count; label do-file interaction; output formatting.

## Round 2 (after 2026-11-19_153735)
- target rebuilt as 1 - congruent (temp_tgt.dta has congruent, not target), gated on pctTargetOfTable raw 28.2473163170171.
- incnonwg recoded (0 9=.) so both categories stay; label added for value 1.
- Codex "no portable entry point": rebutted (exploratory slide-support script, same config pattern as every MATCHING script; not part of the paper's replication).
