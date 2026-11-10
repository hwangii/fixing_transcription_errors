# Handoff to machine B: rerun the truth-based tables on the complete truth file

You are a Claude Code session on **machine B**. This follows up on your investigation in `LINKAGE/notes/truth_file_provenance.md`. Machine A has now settled the question you left open.

## Before you start

- Run `.\Sync.ps1 -Pull` and report where the repo stands.
- Pull the Overleaf repo too. Step 5 edits the draft.
- Never commit data.
- Never overwrite or delete Deaglan's truth file. It stays as the record of what the current tables used.
- Have new or changed do-files reviewed before running them: `.\review\Run-Review.ps1 -Reviewer both`. Give every finding a disposition, and verify Stata-specific claims in Stata.

## What machine A established (2026-11-08) [all confirmed by data]

1. **Machine A's truth file is correctly constructed.** Rebuilding it from its four inputs with `CODE/create_linked_sample_for_MLP_training.do` reproduces it exactly: the same 36,690,338 pairs in the same row order.
   - The 1930 and 1940 FamilySearch crosswalks join on 47,136,891 profiles.
   - All of them match `all_profiles` and `anon_id_vital_dates`.
   - The birth and death date filter drops 10,446,553, which leaves 36,690,338.
2. **Deaglan's file (B's `data/truth/mlp_training1930_1940.dta`) is a strict subset of A's file,** apart from the one pair with the truncated id. B's file was transferred to A and hash-checked (`6b585c82…`), then merged on the pair:
   - pairs in both files: 36,143,406;
   - pairs in A's file only: 546,932;
   - pairs in B's file only: 1, the truncated `histid1940` `0973832E-105E-4B70-9281-4FE163DD0F3`, which is complete in A.
   - None of the 546,932 people missing from B appears in B with a different partner.
3. **The missing pairs are two contiguous blocks of A's row order:**
   - rows 23,927,763–24,215,791 (288,029 pairs);
   - rows 24,859,830–25,118,732 (258,903 pairs).

   The truncated-id pair is A's row 24,859,830, the **first row of the second block**.
   - A deliberate filter would not remove two solid blocks. This looks like damage to B's copy, where the two blocks were overwritten with copies of other rows. That fits the 546,928 duplicates Deaglan's code dropped. **[inferred]**
   - The copy most likely happened on 20 Mar, when the file appeared on B. **[inferred]**
   - Your note says the 18 Aug re-save *caused* the truncation. Given point 3, it more likely happened in the same event as the block loss, and the re-save only preserved it. That is **not provable** now, because the pre-August file is gone.
4. **Consequence:** every Verified, Unverifiable, Directly Contradicted and recall number in the ABE/JW and HLINK tables was scored against a truth set missing 1.49% of its pairs. Nothing else in those tables uses the truth file:
   - denominators;
   - link counts and match rates;
   - middle-initial validation.

   The mortality table does not use the truth file at all.

## Step 1. Check the transferred file

Sam is putting A's file on B by Dropbox, in a new folder, suggested as `F:\Deaglan\Census_Transcriptions\data\truth_from_machineA\mlp_training1930_1940.dta`. Ask Sam where it actually landed if it isn't there.

It must be exactly:
- size 2,641,715,872 bytes;
- sha256 `5507c60c5898e4df228e5e9d1d82b9958fe38cd4c6e552b801b8e3863b42ce31`.

If either differs, stop and tell Sam. A Dropbox copy damaged in transit is exactly what we're trying to get away from.

Stata check: 36,690,338 obs; `isid histid1930`; `isid histid1940`; every id 36 characters long.

## Step 2. Point the pipeline at it, without touching Deaglan's file

Both readers take their path from `LINKAGE/code/shared/paths.do:88` (`global D_TRUTH "$DATA/truth"`):
- `LINKAGE/code/01_abe_jw/linkage_analysis.do:37`;
- `LINKAGE/code/02_hlink/linkage_analysis_newlinks.do:37`;
- the preflight check in `LINKAGE/code/shared/verify_paths.do:78`.

Make the smallest change that switches all three to the new file, for example by pointing `D_TRUTH` at the new folder. The file name is the same in both folders, so nothing else needs to change. Leave a comment saying why, with the date and a pointer to the provenance note.

Also update:
- `replication/input_manifest_machineB.md`: the new path, size and sha256 above, keeping the old file's row as "superseded, damaged copy";
- the hard-coded `36,143,407` comments in `linkage_analysis.do:107` and `linkage_analysis_newlinks.do:260`. After the switch it is 36,690,338.

## Step 3. Rerun the ABE/JW and HLINK tables

Rerun whatever `LINKAGE/code/00_run_all_tables.do` uses to rebuild `linkage_tables/linkage_table_abe_jw{,_restricted}.tex` and `linkage_table_hlink{,_restricted}.tex`. Skip mortality, which is unaffected. Use the usual mechanical extraction into the draft's `figures/deaglan_*.tex`.

**Cross-machine check (exact-name ABE columns).** Machine A's `MATCHING/score_fs_links.do` mirrors `linkage_analysis.do` and has already been run against A's truth file. Your rerun's ABE exact-name Old (Ancestry) and New (ML) columns must reproduce these values **exactly**:

| | A's value | Current paper |
|---|---|---|
| full Old: verified / unverifiable / contradicted | 6,283,801 / 5,883,324 / 348,279 | 6,188,445 / 5,982,941 / 344,018 |
| full Old: recall | 31.79 | 31.78 |
| full New: verified / unverifiable / contradicted | 6,794,104 / 6,375,502 / 317,830 | 6,690,920 / 6,482,670 / 313,846 |
| full New: recall | 34.37 | 34.36 |
| full Panel B added: ver / unv / con | 1,081,009 / 1,199,711 / 81,640 | 1,064,715 / 1,216,975 / 80,670 |
| full Panel B removed: ver / unv / con | 571,902 / 708,243 / 110,183 | 563,429 / 717,953 / 108,946 |
| restricted Old: ver / unv / con | 523,399 / 694,933 / 65,907 | 515,555 / 703,536 / 65,148 |
| restricted Old: recall | 11.13 | 11.12 |
| restricted New: ver / unv / con | 1,320,314 / 1,411,579 / 72,769 | 1,300,253 / 1,432,546 / 71,863 |
| restricted New: recall | 28.07 | 28.06 |
| restricted Panel B added: ver / unv / con | 945,322 / 969,084 / 50,582 | 930,996 / 984,046 / 49,946 |
| restricted Panel B removed: ver / unv / con | 150,060 / 253,120 / 41,385 | 147,928 / 255,723 / 40,914 |

- The denominators, link counts, match rates and middle-initial rows must be **unchanged** from the current tables.
- Any number outside the truth columns that moves is a bug. Stop and report it.
- If the ABE values don't match machine A's exactly, report the differences. Don't adjust anything to force a match.
- The JW and HLINK truth columns have no machine A benchmark. Report old vs new for those.

## Step 4. Correct the provenance record

- **`LINKAGE/notes/truth_file_provenance.md`:**
  - add a "Resolved 2026-11-08" section with the facts above;
  - correct the claim that the 18 Aug re-save corrupted the id. It is now inferred to come from the same damage as the block loss, unprovable;
  - state that the tables now use A's file.
- **Apply the documentation corrections you proposed** to `LINKAGE/DOCUMENTATION.md` and `replication/README.md:80`. The truth file is Sam's FamilySearch-profile linked sample, built by `CODE/create_linked_sample_for_MLP_training.do`, not an MLP crosswalk extraction. Also mention the damaged copy and its replacement.
  - `replication/README.md` is shared between the machines. Pull immediately before editing it and push immediately after.

## Step 5. Update the draft's prose

The Section 4.2 text quotes truth-based numbers in the "Robustness to the Linking Algorithm" subsection, around the paragraphs beginning "These tables also serve as our external validation" and "Links the reference standard directly contradicts":
- verified counts;
- recall under all three linkers;
- contradicted counts and contradicted shares.

Then:
- Update each such number from the regenerated tables, one sentence per line. Never reflow a paragraph.
- Check that every qualitative claim still holds: verified rises in every column; the contradicted share falls in all six columns; the direction of each contradicted-count change.
- If a claim no longer holds, flag it to Sam rather than rewording around it.
- Table notes that quote truth-set sizes need the same update.
- Do not touch Section 2, or the new Section 4.3, "Comparison with a Second Human Transcription" (machine A's).
- Pull the Overleaf repo immediately before editing; commit and push immediately after.

## Report back

When done, push both repos. Then give Sam a short summary:
1. the transfer check (sha matched or not);
2. whether the ABE columns matched machine A's values exactly;
3. old vs new for each truth-based number quoted in the prose, including JW and HLINK;
4. any qualitative claim that changed;
5. the review dispositions.
