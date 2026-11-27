# Handoff to machine A: name shards for a target-only Jaro-Winkler rerun (2026-11-27)

## Why

The author wants ABE Jaro-Winkler links rebuilt with our names on **target records only**, as machine A did for ABE exact. Machine B runs JW (Deaglan's pipeline, `F:\Deaglan\Census_Transcriptions\code\01_abe_jw\linkage\`), but every input it links on is a copy of a file machine A makes. Those copies predate the v26 rebuild: they carry the pre-0.25 abeclean "marshall" defect and are not the v26 men/names (`MATCHING/results/v26_linkage_abe.md`). So B should not build target-only names from its own copies: the JW columns would not be comparable with A's v26 ABE columns.

## The files B links on (everything else on B is derived from these)

`F:\Deaglan\Census_Transcriptions\abe_jw\data\full_census\names\`, one file per birthplace, `norace1.dta` ... :

| Folder on B | Files | Variables | Dated |
|---|---:|---|---|
| `divided_file1930_ans_cleaned` | 143 | `id age mi f_name l_name` | 2025-11-17 |
| `divided_file1940_ans_cleaned` | 139 | `id age mi f_name l_name` | 2025-11-17 |
| `divided_file1940_true_cleaned` | 139 | `id age mi_true_cleaned f_name l_name name_true_cleaned_exists` | 2026-02-15 |

Plus the census variables they are merged onto, `abe_jw\data\source_census\matching_intgen{1930,1940}.dta` (bpl, birthyr, race, sex; 2024-10-18, copied from `D:\ABE_JW\DATA\ORIGINAL`, origin undocumented).

`code\01_abe_jw\linkage\00_merge_names_to_census.do` appends each folder, merges 1:1 on `histid` (= `id`) with `matching_intgen`, and writes `clean_names_1930_old`, `clean_names_1940_old`, `clean_names_1940_new`; the prep scripts keep men and split by birthplace; the matcher reads those. Nothing downstream needs to change.

## What B needs from A

1. **The v26 versions of the four shard sets**, in the formats above (Ancestry: `mi`; ours: `mi_true_cleaned` and `name_true_cleaned_exists`, which `00_merge` renames/drops):
   - 1930 Ancestry; 1940 Ancestry; 1940 New (model names on every record); **1940 Target-only** (model names on target records, Ancestry's elsewhere) -- the inputs of `_v26_run.do`'s Old / New / Target-only.
   - Which target-only variant is authoritative for this (v26, `_tgtns`, or `_tgt`)? B will use only the one A names.
2. **The census variables.** Should `matching_intgen{1930,1940}` stay as B's copies, or should B take bpl/birthyr/race/sex from A's v26 base so the JW men equal the ABE v26 men (`check_v26_same_input.do`)? If A has its own copies, a SHA-256 of each settles whether B's are the same files.
3. **A SHA-256 manifest** of everything sent, so B can confirm the copy arrived intact before a run of ~10 days (JW took ~245 h for one vintage).

Data does not travel through git: the author will copy the files (as with `truth_from_machineA/`). B will put them in new folders beside the old ones, never overwriting Deaglan's copies.

## Then, on B

Build `clean_names_*` from the new shards, rerun JW prep and matching for Old / New / Target-only, and score them with the definitions of `LINKAGE/code/01_abe_jw/linkage_analysis.do` on all / target / non-target records, with the ABE exact v26 columns as a check where they overlap. Every new script gets the Codex + Antigravity review before it runs. The ~10-day JW run will need the reweighting (MDE) job paused; B will arrange that with its session when the inputs are in place.
