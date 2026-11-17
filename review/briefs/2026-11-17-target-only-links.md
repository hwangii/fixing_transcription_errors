# Review brief: target-only 1940 names for the ABE links (2026-11-17)

The slides say we replace names only on target records (Ancestry and FamilySearch disagree on first or last name). The paper's "New" links (link1930_1940_true_cleaned_noraceblock0.dta) instead use the model's names on every 1940 record with model output. At the author's request we build a separate target-only version, without overwriting anything, and a same-code baseline with model names on every record, so the two differ only in which 1940 records get model names.

New/changed files (nothing has been run yet):
- MATCHING/1c_tgt_divided_files.do (new): builds a target flag by histid from each state's merged_data.dta (same definition as MATCHING/fs_cells.do), then writes divided_file1940_tgt_cleaned: per birthplace, target records from divided_file1940_true_cleaned, all others from divided_file1940_ans_cleaned. Checks that the Ancestry fallback inside _true_cleaned (name_true_cleaned_exists==0) equals _ans_cleaned.
- MATCHING/3_append_and_clean_all_links_christian_torbenV2.do: new arg 9 mltype ("_true_cleaned" default / "_tgt_cleaned"); the FamilySearch/ML branch now also runs with ml_years and no fs_years; output tag _ml<yrs> or _mltgt<yrs>.
- MATCHING/_tgt_only_run.do (new driver): 1c, then stage 2 (2_ABE_matchingV3_christian_torben.do 1930 1940 _ans_cleaned 1 <type>) and stage 3 for _tgt_cleaned and _true_cleaned. Refuses to overwrite existing outputs.

Known facts (verified on the data): divided_file1940_true_cleaned and _ans_cleaned hold the same 139 birthplace files and identical id sets (checked norace44). _true_cleaned files: id name_true_cleaned_exists age mi_true_cleaned f_name l_name; _ans_cleaned: age id mi f_name l_name. 1930 side is _ans_cleaned; the master's earlier check showed divided_file1930_true_cleaned identical to _ans_cleaned in id f_name l_name age.

CHECK: (1) the target-only file does what is described, with no silent Stata failure (merge, empty strings, missing); (2) the stage-3 change leaves existing FamilySearch runs (fs_years set) producing the same file names and contents; (3) the two new link files are comparable (same code path, only 1940 names differ); (4) nothing overwrites existing data.

## Round 2 (after review 2026-11-17_014017)
Fixed: target flag now from census1940_all_labeled_data.dta, `!(namefrst==namefrst_fs & namelast==namelast_fs)`, as fs_avg_performance.do (isid histid asserted); overwrite guards for every intermediate folder/file; display distinguishes target records with and without model names. CHECK the fixes, and anything else, before the first run.
