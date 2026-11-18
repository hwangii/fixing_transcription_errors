# Review brief: scoring the target-only links (2026-11-17)

_tgt_only_run.do finished (exit 0): link1930_1940_mltgt1940_cleaned_noraceblock0.dta (model names on 1940 target records only) and link1930_1940_ml1940_cleaned_noraceblock0.dta (model names on every record, rerun same day by the same code). The paper's own all-records file, link1930_1940_true_cleaned_noraceblock0.dta (Feb), is 3.11 GB vs the rerun's 2.98 GB.

NEW MATCHING/score_tgt_links.do scores four link files (ans = paper Old, true = paper New, ml = rerun, mltgt = target-only) on all / target / non-target 1940 records: links, match rate, share validated (MI), V/U/C, C/(V+C), recall; plus a pair-by-pair comparison of ml with true. It must use the definitions of LINKAGE/code/01_abe_jw/linkage_analysis.do (machine B's slide-table code; read it) and stops unless ans and true reproduce the main-table values that file checks against.

CHECK: (1) faithful to linkage_analysis.do (sample, link filter, V/U/C, recall, MI); (2) the mltgt 1940 initial (from divided_file1940_tgt_cleaned) is the right choice; (3) non-target sample and truth restriction correct; (4) merges, tempfiles, missing-value traps; (5) anything else. Read-only except MATCHING/results/tgt_linkage_abe.md. Ignore MATCHING/_run__*.do (Run-Stata wrappers) and review/revision-notes-2026-11-13.md.

## Round 2
Fixes for report 2026-11-17_232137 (dispositions in its Disposition columns): truth count/uniqueness asserted; ans/true V/U/C and recall gated against the slide tables; mi sanity counts asserted; rerun-vs-paper pairs also on the sample; md states each column's 1940 initial; fixed Ancestry-MI share-validated row. CHECK the fixes, especially the preserve/restore and merges in the MI block of Part 1.
