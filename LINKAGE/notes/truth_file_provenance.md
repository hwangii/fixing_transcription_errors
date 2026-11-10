# Truth-file provenance: what happened to `mlp_training1930_1940.dta`

Investigation on machine B, 2026-11-08, answering `review/handoff_truth_file_machineB.md`.
Read-only: no truth file was modified, moved or re-saved.
Every Stata check was run in Stata/MP 15.1 batch mode on B's file at `F:\Deaglan\Census_Transcriptions\data\truth\mlp_training1930_1940.dta`.
Tags: **[data]** = confirmed by data or logs on this machine; **[inferred]** = reasoning, not proven.

## Resolved 2026-11-08 (machine A), applied 2026-11-09 (machine B)

Machine A settled the open question (`review/handoff_truth_rerun_machineB.md`). **[data]**
- Machine A's file is correctly built: rebuilding it from its four inputs with `CODE/create_linked_sample_for_MLP_training.do` reproduces it exactly, the same 36,690,338 pairs in the same row order.
- Deaglan's file is a strict subset of A's, apart from the one truncated pair: 36,143,406 pairs in both, 546,932 in A only, and 1 in B only (the truncated `histid1940`, complete in A). None of the 546,932 people missing from B appears in B with a different partner.
- The missing pairs are two contiguous blocks of A's row order: rows 23,927,763–24,215,791 (288,029) and 24,859,830–25,118,732 (258,903).

So B's file is a **damaged copy**, not a different extraction or a deliberate filter.
- The likeliest account is that the two blocks were overwritten with copies of other rows, giving the 546,928 duplicates Deaglan's code dropped, probably when the file reached B around 2026-03-20. **[inferred]**

**When the id was truncated: not settled.** This corrects my 2026-11-08 statement that the 18 Aug re-save *caused* it.
- Machine A's evidence: the truncated pair is A's row 24,859,830, the first row of the second missing block, which suggests the same event as the block loss.
- Against that: the 17 Aug log (before the re-save) kept 19,473,337 truth pairs among 1940 men aged 8+, and every later log keeps 19,473,336. That is the count the truncation removes, so the id may still have been intact on 17 Aug.
- Both are inferences; the pre-August file no longer exists, so neither can be proven.

**Since 2026-11-09 the tables use machine A's file.** It sits at `F:\Deaglan\Census_Transcriptions\data\truth_from_machineA\` with sha256 `5507c60c…`, checked on arrival. In Stata it has 36,690,338 obs, `isid` on both ids, and every id is 36 characters.
- The code points there through `D_TRUTH` in `LINKAGE/code/shared/paths.do`.
- Deaglan's file stays in `data/truth/`, unmodified (hash re-checked 2026-11-09), as the record of what the earlier tables used.
- The doc corrections proposed below have been applied to `LINKAGE/DOCUMENTATION.md` and `replication/README.md`.

Everything below is the 2026-11-08 investigation as written. Items 1, 4 and 5 of its bottom line are superseded by this section.

## Bottom line (2026-11-08)

1. The paper's truth set is B's file as it stands today: 36,143,407 one-to-one pairs. **[data]**
2. B's file is **not** an extraction from the IPUMS MLP crosswalk. Everything points to Sam's FamilySearch-profile build, the same lineage as A's file. **[data + inferred, see 3]**
3. B's file was **edited and re-saved by Stata on 18 Aug 2026 12:32**. Before that it contained 546,928 exact duplicate pairs, and Deaglan's code dropped them at run time. **[data]**
4. The 18 Aug re-save also **corrupted one id**: one `histid1940` lost its last character. **[data]**
5. Why A's file has 546,931 more *distinct* pairs is **not settled**. It needs the two files on one machine (see "Next step").

## 1. Fingerprint of B's file  [data]

| | B (this machine) | A (from handoff) |
|---|---|---|
| Stata save stamp | **18 Aug 2026 12:32** | 16 Mar 2026 18:52 |
| File mtime / ctime | 2026-08-18 12:33:18 / 2026-03-20 15:20:59 | — |
| N | 36,143,407 | 36,690,338 |
| Vars | `histid1930 histid1940`, both str36 | same |
| Sorted by | `histid1930` | ? |
| Bytes on disk | 2,602,336,840 | 2,641,715,872 |
| Bytes minus N×72 | **11,536** | **11,536** |
| Data label / notes | none / none | ? |

- Duplicates: none on `histid1930`, `histid1940` or the pair, and no empty ids. All ids are upper case.
- The identical 11,536-byte non-data overhead suggests the two files carry the same header and characteristics block. **[inferred]**
- `_dta` characteristics hold leftovers from earlier `reshape` commands. This was read from the raw header, and nothing was loaded and saved.
  - `ReS_Xij` stubs `spouse_name`, `spouse_gender`, `spouse_marriagedate`, `spouse_marriageplace`, `spouse_lifespan` (1–20).
  - Stubs `parent_mardate`, `parent_marplace`, `parent1_lifespan`, `parent2_lifespan` (1–5).
  - `ReS_i=county_state`, `ReS_Xij=countyicp`.
  - These are FamilySearch-profile fields, inherited from Sam's master data, not from IPUMS.
- **Malformed id:** exactly one `histid1940` has 35 characters.
  - The pair is `histid1930 = 3939A9BD-FA56-44D1-BC0E-6E25706FC405`, `histid1940 = 0973832E-105E-4B70-9281-4FE163DD0F3`.
  - The 1940 census has `0973832E-105E-4B70-9281-4FE163DD0F3E`, a 40-year-old man; the final `E` is missing.
- First hex character of `histid1930`:

| | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| B | 2,259,368 | 2,258,793 | 2,263,078 | 2,256,282 | 2,259,772 | 2,261,309 | 2,258,122 | 2,258,724 |
| A−B, % | 1.495 | 1.485 | 1.497 | 1.503 | 1.491 | 1.486 | 1.478 | 1.494 |

| | 8 | 9 | A | B | C | D | E | F |
|---|---|---|---|---|---|---|---|---|
| B | 2,261,849 | 2,257,405 | 2,258,856 | 2,256,670 | 2,257,822 | 2,260,464 | 2,258,926 | 2,255,967 |
| A−B, % | 1.484 | 1.511 | 1.481 | 1.476 | 1.492 | 1.498 | 1.497 | 1.482 |

The gap is uniform: χ² = 21.2 on 15 df against uniform thinning, p ≈ 0.13.
Caveat: `histid` is a random UUID, so *any* row selection not based on the id looks uniform here. This rules out an id-range cut but does not tell a filter of A apart from a different extraction. **[inferred]**

## 2. What produced B's file  [data]

- **No script on this machine writes the truth file.**
  - A search of drives C, D, E, F and G found no `save` to it and no reader of `mlp_census_crosswalk_v2_0`, apart from Claude-written docs.
  - `C:\Users\deaglanj` is permission-denied, so it was not searched.
- **No other copy exists.** There is no other `mlp_training1930_1940*.dta` and none of the build inputs (`unique_ID_to_census_crosswalk*.dta`, `all_profiles*.dta`, `anon_id_vital_dates*.dta`) on any drive.
- **The MLP crosswalk zip is a different object.** It is one member, `mlp_census_crosswalk_v2_0.dta` (66.9 GB, 26 Jun 2025), holding 175,649,924 obs of a wide person panel.
  - Its variables are `histid_1850 … histid_1950` (underscore) plus `hik`.
  - It has no characteristics. The truth file uses Sam's naming (`histid1930`) and carries FamilySearch reshape characteristics.
  - Only the header was read; the zip was not unpacked.
- **Deaglan's own code calls it the FamilySearch file:**
  - `F:\Deaglan\HLINK\code\build_training_data.py:12,26`: "FamilySearch training file", read from `D:/Deaglan/Census_Transcriptions/data/True_Links/mlp_training1930_1940.dta`.
  - `F:\Deaglan\HLINK\code\build_training_data.py:58` (2026-04-27): "2 string columns × 36.7M rows". That is the row count *before* 18 Aug, close to A's.
  - `F:\Deaglan\HLINK\code\build_negatives.py:11`: "full FamilySearch file".
- **The duplicate drop.** `F:\Deaglan\Census_Transcriptions\_archive\output_previous\linkage_table_newlinks.log` (opened 17 Aug 2026 10:43) shows:
  ```
  . use "`true_links'", clear
  . keep histid1930 histid1940
  . duplicates drop histid1930 histid1940, force
  (546,928 observations deleted)
  . merge m:1 histid using `men1940_full', keep(3)   ->  matched 19,473,337
  ```
  Every log after 18 Aug shows `(0 observations are duplicates)` at the same step and **19,473,336** matched. One example is `output\logs\linkage_analysis.log:228,237` (5 Sep).
  The pair lost is the one whose `histid1940` was truncated. It can no longer match its 40-year-old man.
- **Overleaf `deaglan_results/`:** `current/PROVENANCE.md` and `retired/` say nothing about the truth file's origin.

## 3. Filter hypotheses

- **Census-subset filter: rejected [data].**
  - Of B's 36,143,407 pairs, 19,479,920 have `histid1930` in `clean_names_1930_old`, and 19,484,761 have `histid1940` in `clean_names_1940_new`.
  - 19,416,370 pairs have both ends in those files; 19,473,336 have their 1940 end among men aged 8+.
  - Nearly half of B's pairs point outside Deaglan's census files, so B is not "the subset present in Deaglan's census files".
- **MLP crosswalk as source: rejected as a direct extraction [inferred].**
  - The variable names, the characteristics and the absence of any reader all argue against it.
  - Not tested: whether a 1930–1940 subset of the crosswalk would give a similar count. That would need the 67 GB unpack, which was not approved.
- **Older or newer build of Sam's script: likely the same lineage, but the content is unresolved.**
  - A's save is 16 Mar; B's copy was created on this disk on 20 Mar, four days later. The non-data overhead is identical. That suggests Sam's 16 Mar file was copied to Deaglan. **[inferred]**
  - Pre-18-Aug B contained 546,928 duplicate pairs. **[data]**
  - A is reported one-to-one, and A's scoring (`MATCHING/score_fs_links.do:156`, the same `duplicates drop`) still yields ~1.5% more truth matches. So A's file has ~546,931 more *distinct* pairs than B. If B had been a byte copy of A's current file, deduping it could not remove 546,928 rows.
  - **These two facts conflict.** Either B before 18 Aug was not identical to A's current file, or A's one-to-one check is mistaken.

## Next step: check on A first (cheap)

Run on machine A, read-only:
```stata
use "F:/fixing_transcription_errors/DATA/INTERMEDIATE/mlp_training1930_1940.dta", clear
duplicates report histid1930 histid1940
char list _dta[]
count if histid1940 == "0973832E-105E-4B70-9281-4FE163DD0F3E"
count if histid1930 == "3939A9BD-FA56-44D1-BC0E-6E25706FC405"
```
- If the pair `duplicates report` shows 546,928 (or 546,931) surplus, the puzzle is solved: B = dedup(A) plus one corrupted id. A's scoring difference would then need re-checking.
- If it shows 0 surplus, the files really differ, and the decisive merge below is needed.

**Decisive merge (needs approval):** copy A's 2.6 GB file to B via Dropbox or a shared drive, never git. Then merge on the pair, and report in-both / A-only / B-only, plus re-partnered `histid1930`s.
A cheaper variant: each machine exports only the pairs whose `histid1930` begins with `00` (~140k rows, ~10 MB), moves them by Dropbox, and merges them. Because ids are random, that 1/256 sample answers the question.

## Proposed doc corrections (not applied)

- `LINKAGE/DOCUMENTATION.md:72`: delete "Almost certainly the source `mlp_training1930_1940.dta` was extracted from".
  Replace it with: "Not the source of the truth file, which is Sam Hwang's FamilySearch-profile linked sample (`CODE/create_linked_sample_for_MLP_training.do`); see `LINKAGE/notes/truth_file_provenance.md`."
- `LINKAGE/DOCUMENTATION.md:74-77`: the missing step is Sam's build script, which is in the repo, not an MLP extraction.
- `LINKAGE/DOCUMENTATION.md:255-260`: "the timestamp records the file being moved … not edited" is **false**. Stata's internal stamp is 18 Aug 2026 12:32.
  Say instead: on that date 546,928 duplicate pairs were removed and one `histid1940` was truncated by one character.
- `replication/README.md:80`:
  - Replace the MLP-crosswalk attribution with the FamilySearch-profile build.
  - Replace "records a move, not an edit" with the 18 Aug edit above.
  - Note that the truncated id costs one truth pair (19,473,336 vs 19,473,337 among 1940 men aged 8+).
