# Handoff to machine B: the v26 data machine A built for the Jaro-Winkler rerun (2026-11-28)

Machine A built everything B asked for in `review/handoff_jw_inputs_machineA.md`.
The item-by-item answers, and the reasons behind them, are in `review/handoff_jw_inputs_reply_machineB.md`.
This note says what the data is, how it was checked, how to confirm B's copy, and what B has to change before running.

## What was built

All files are in `F:/enum_date/DATA/INTERMEDIATE/` on A; the author copies them to B (data does not travel through git).
Put them in **new folders beside Deaglan's copies**; overwrite nothing.

| On A | Files | Records (men) | Variables | Replaces on B |
|---|---:|---:|---|---|
| `divided_file1930_v26_ans_cleaned/norace*.dta` | 143 | 62,079,010 | `id age mi f_name l_name` | `divided_file1930_ans_cleaned` |
| `divided_file1940_v26_ans_cleaned/norace*.dta` | 143 | 66,134,357 | `id age mi f_name l_name` | `divided_file1940_ans_cleaned` (Old) |
| `divided_file1940_v26_true_cleaned/norace*.dta` | 143 | 66,134,357 | `id name_true_cleaned_exists age mi_true_cleaned f_name l_name` | `divided_file1940_true_cleaned` (New) |
| `divided_file1940_v26_tgt_cleaned/norace*.dta` | 143 | 66,134,357 | same as true | new: Target-only |
| `jw_census_vars1930_v26.dta` | 1 | 62,079,010 | `histid bpl birthyr race sex` | `matching_intgen1930.dta` |
| `jw_census_vars1940_v26.dta` | 1 | 66,134,357 | `histid bpl birthyr race sex` | `matching_intgen1940.dta` |

In all: 574 files, 26,637,900,781 bytes.

- **Names:** rebuilt from the raw IPUMS names (00655 for 1930, 00656 for 1940) with abeclean 0.26, by `MATCHING/1f_v26_inputs.do`. There is no "marshall" defect, and "InvalidPred" is blanked before the fallback to Ancestry.
- **Target-only:** the model's names on target records, Ancestry's elsewhere. This is the authoritative version; do not use `_tgt` or `_tgtns`.
- **Census variables:** written by `MATCHING/1j_v26_jw_census_vars.do` from `matching_intgen{1930,1940}_women_added`, the source of the v26 base. One 1940 file serves Old, New and Target-only, because the three shard sets hold the same men.
- **All races:** every race is included, as it was in the old files. The birthplace list was drawn from race 1|2, but each birthplace file holds every race.

## How it was checked on A

| Check | Result |
|---|---|
| The ABE shards hold the same men and names as the MLP files sent to IPUMS (`check_v26_same_input.do`) | 0 differences |
| Three birthplaces rebuilt from the raw sources with separately written code (`verify_mlp_v26_independent.do`) | 0 differences |
| Every shard man is in the census source exactly once (`1j`) | 0 missing, 0 duplicated |
| His source birthplace and age equal his shard's (`1j`) | 0 differences |
| Sex is 1; race and birth year are non-missing (`1j`) | 0 exceptions |
| Missing age, every shard set (one-off count, 2026-11-28) | 0 (ranges 0-125 in 1930, 0-120 in 1940) |
| A's ABE exact on these shards (`MATCHING/results/v26_linkage_abe.md`) | ran and scored; the paper's columns reproduce the main table |

## Step 1 on B: confirm the copy

```
python replication/hash_jw_v26.py --check --dir <folder holding the copied folders and files>
```

It compares every file with `replication/jw_v26_manifest.md` (SHA-256, by path relative to the data folder), reports MISSING / EXTRA / CHANGED, and exits 1 on any.
Do not start a run of about 10 days on a copy that has not passed.

## Step 2 on B: what has to change in the code

`LINKAGE/code/01_abe_jw/linkage/00_merge_names_to_census.do`:

- point the three shard folders at the v26 copies, and add a fourth block for Target-only (`clean_names_1940_tgt`), like the `_new` one;
- set `a_dataset` / `b_dataset` to `jw_census_vars{1930,1940}_v26.dta`;
- replace `keep if _merge == 3` with an assert that every shard record matched: B's old `matching_intgen` copies would have dropped v26 men silently, and these files must not;
- allow for 143 birthplace files in 1940 (B's copies had 139) and for the different variable order in the true/tgt shards.

Nothing downstream of `clean_names_*` needs to change. Every new or changed script goes through the Codex + Antigravity review before it runs.

## Step 3 on B: scoring

Score Old / New / Target-only on all, target and non-target records, with the definitions of `LINKAGE/code/01_abe_jw/linkage_analysis.do`.
There is one exception: the middle initials.
`linkage_analysis.do` takes the 1940 initials from `linkage_sample1940.dta`, which predate v26.
Use instead each version's own v26 initials from the shards (1930 `mi`; 1940 `mi` for Old, `mi_true_cleaned` for New and Target-only), as `MATCHING/score_v26_links.do` does, and keep the paper's Ancestry initials as the fixed-yardstick rows.
The JW columns are then comparable with A's `MATCHING/results/v26_linkage_abe.md`.

The men and names are the same as in A's ABE exact columns.
Any difference between the two sets of columns is therefore down to the method: JW blocks on birthplace, first and last initial and race, and uses age as a distance; ABE exact blocks on birthplace, without race.

## Machine A will not touch

B's scripts, `figures/deaglan_*.tex`, and anything under `F:\Deaglan\` on B.
If B finds a problem with the data, it should write a note under `review/` and push it; A rebuilds and sends a new manifest.
