# Reply to machine B: v26 inputs for the Jaro-Winkler rerun (2026-11-27)

Answers `review/handoff_jw_inputs_machineA.md`, item by item.
The author copies the data; nothing here travels through git except this note, the scripts and the manifest.

## 1. Name shards: use v26

Target-only is **v26** (`divided_file1940_v26_tgt_cleaned`), not `_tgtns` or `_tgt`.
v26 already blanks "InvalidPred" before the fallback (the `_tgtns` fix) and is rebuilt from the raw names with abeclean 0.26 (no "marshall" defect).

| B's folder | Send (from `F:/enum_date/DATA/INTERMEDIATE/` on A) | Files | Variables |
|---|---|---:|---|
| `divided_file1930_ans_cleaned` | `divided_file1930_v26_ans_cleaned` | 143 | `id age mi f_name l_name` |
| `divided_file1940_ans_cleaned` | `divided_file1940_v26_ans_cleaned` | 143 | `id age mi f_name l_name` |
| `divided_file1940_true_cleaned` | `divided_file1940_v26_true_cleaned` | 143 | `id name_true_cleaned_exists age mi_true_cleaned f_name l_name` |
| (new) | `divided_file1940_v26_tgt_cleaned` | 143 | same as true |

Differences from B's copies that `00_merge_names_to_census.do` must allow for:

- 1940 has **143** birthplace files, not 139 (extract 00656, not 00450); 1930 is 143 as before.
- Variable order differs in the true/tgt shards; names are the same.
- The Target-only folder is new: `00_merge` needs a fourth block (`clean_names_1940_tgt`) like the `_new` one.
- Every race is included (the old ones too): `0_create...:159` limits only the birthplace list to race 1|2.

The four sets are the inputs of A's v26 ABE exact Old / New / Target-only (`MATCHING/results/v26_linkage_abe.md`); `check_v26_same_input.do` confirmed they hold the same men and names as the MLP files sent to IPUMS.

## 2. Census variables: take A's v26 files, not B's `matching_intgen` copies

B's copies predate the v26 base, so `00_merge`'s `keep if _merge == 3` would silently drop v26 men and give others the old extract's birthplace and age.
A wrote the same variables for exactly the v26 men, from the source the v26 base was built from (`matching_intgen{1930,1940}_women_added`, IPUMS 00655/00656), with `MATCHING/1j_v26_jw_census_vars.do`:

- `jw_census_vars1930_v26.dta`, `jw_census_vars1940_v26.dta`: `histid bpl birthyr race sex`, one row per v26 man, sorted by `histid`.
- Checked: every shard man is in the source exactly once, with his shard's birthplace and age, sex 1, race non-missing (exit 9 otherwise).
- One 1940 file serves Old, New and Target-only (same men).

Use them as `a_dataset` / `b_dataset` in `00_merge`; after the merge, `_merge==3` should be every shard record (assert it rather than `keep`).

## 3. Manifest

`replication/jw_v26_manifest.md` (written by `replication/hash_jw_v26.py`) lists every file above with its SHA-256, by path relative to the data folder.
On B, after the copy: `python replication/hash_jw_v26.py --check --dir <folder holding the copied folders and files>`; it reports MISSING / EXTRA / CHANGED and exits 1 on any.

## Scoring: use the v26 middle initials

`linkage_analysis.do` takes the 1940 initials from `linkage_sample1940.dta` (`mi_anc`, `mi_ml`), which predate v26.
For the v26 columns, score as `MATCHING/score_v26_links.do` does: each version's own initials from the v26 shards (1930 `mi`; 1940 `mi` for Old, `mi_true_cleaned` for New and Target-only), with the paper's Ancestry initials as the fixed-yardstick rows.
Otherwise the JW share-validated rows will not be comparable with `MATCHING/results/v26_linkage_abe.md`.

## One method difference to keep in mind

JW blocks on `bpl`, first and last initial and `race`, and uses age as a distance (`run_full_census_prep.do` keeps `birthyr` only briefly; `run_full_census_match.do`); A's ABE exact blocks on birthplace and uses no race block.
The men and names are the same, so differences between the JW and ABE exact columns come from the methods.
`birthyr` is in `jw_census_vars` only because `00_merge` asks for it.
