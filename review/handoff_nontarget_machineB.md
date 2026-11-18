# Handoff to machine B: non-target columns for the ABE-JW and MLP tables (2026-11-18)

## Why

On machine A, ABE exact links were rebuilt with our names on **target records only** (`MATCHING/_tgt_only_run.do`), and scored on all / target / non-target 1940 records (`MATCHING/score_tgt_links.do` -> `MATCHING/results/tgt_linkage_abe.md`). Replacing names on every record lowers the non-target records' match rate (28.30 -> 26.64) and recall; replacing them on target records only recovers most of that and raises overall quality (all records: match 24.60 -> 25.54, share validated 87.14 -> 87.96).

The author wants the same **target / non-target breakdown for ABE-JW and MLP (HLINK)**, Old vs New (New = our names on every record, the existing links), to gauge how much a target-only fix would help those methods too.

What machine A can already derive (All minus Target from `figures/deaglan_*.tex`, `MATCHING/nontarget_from_tables.py`; exact for counts and match rate, approximate for recall):

| Non-target, 36,620,316 records | Old match | New match | Old C/(V+C) | New C/(V+C) |
|---|---:|---:|---:|---:|
| ABE Jaro-Winkler | 26.12 | 25.25 | 3.76 | 3.60 |
| MLP (HLINK) | 69.02 | 68.17 | 1.42 | 1.40 |

**Missing: share validated (MI match rate) on non-target records.** Its denominator (links with both initials) is not printed, so it needs a run on machine B.

## What to do (machine B owns these scripts)

In both `LINKAGE/code/01_abe_jw/linkage_analysis.do` and `LINKAGE/code/02_hlink/linkage_analysis_newlinks.do`, add a third sample `non` = `target == 0` beside `full` and `restr`, built exactly like `restr`:

- `cn1940_non`, `den1940_non`, `true_pairs_non` (truth pairs whose 1940 person is non-target) -- as the `restr` versions, with `keep if target == 0`;
- run the outer `foreach samp in full restr` loop over `full restr non`;
- write the non-target Panel A (match rate, MI match rate, V/U/C, recall) to new files, e.g. `figures/deaglan_abe_jw_nontarget.tex` and `figures/deaglan_hlink_nontarget.tex`; leave the existing tables and the `CHECK PASSED` gate unchanged.

Checks to add: `N_men_1940_non == 36,620,316` and `N_men_1940_restr + N_men_1940_non == N_men_1940_full`; for every count, full = restr + non; the ABE exact non-target columns must equal `MATCHING/results/tgt_linkage_abe.md` "Non-target", Old and New (paper): match 28.30 / 26.64, share validated 88.87 / 88.21, links with both initials 2,203,905 / 2,046,592.

Then push the new `.tex` files (paper repo) and the script changes (this repo). Machine A will add them to the slides' appendix.

Note: the target-only rebuild of JW and MLP links themselves is a separate, larger job (not requested yet).
