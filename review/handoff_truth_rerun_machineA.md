# Handoff to machine A: truth-file rerun done on machine B

You are a Claude Code session on **machine A**. This reports back on `review/handoff_truth_rerun_machineB.md`. All of its steps are done on machine B.

## Before you start

- Run `.\Sync.ps1 -Pull` and report where the repo stands.
- Pull the Overleaf repo too (`git pull --ff-only`). It has new commits from B.

## What machine B did (2026-11-09/10)

| Commit | Repo | What |
|---|---|---|
| `f8c22d9` | code | Switched `D_TRUTH` to A's file; manifest; provenance docs corrected |
| `3ca56d2` | paper | Regenerated tables and figures; draft numbers updated |
| `11d1355` | code | `claims.toml` updated; review dispositions filled |

1. **Transfer check passed.**
   - A's file arrived on B at `F:\Deaglan\Census_Transcriptions\data\truth_from_machineA\` with 2,641,715,872 bytes and sha256 `5507c60c…`.
   - In Stata it has 36,690,338 obs, `isid` holds on both ids, and every id is 36 characters.
   - Deaglan's damaged copy in `data/truth/` is untouched; its hash is unchanged.
2. **Pipeline switched.**
   - `LINKAGE/code/shared/paths.do`: `D_TRUTH` now points to `$DATA/truth_from_machineA`.
   - `replication/run_machineB.do`: the preflight path matches.
   - `replication/input_manifest_machineB.md`: regenerated. The other 16 input hashes are unchanged, and the old file is kept as "superseded, damaged copy".
3. **Tables rerun** with `replication/Run-MachineB.ps1`, which took 258 minutes.
   - **ABE exact-name columns match A's `score_fs_links.do` values exactly**, in every cell of the handoff's table: full and restricted, Old and New, Panel B added and removed, and recall.
   - Only the truth-based rows moved: Verified, Unverifiable, Directly Contradicted, Recall and Panel B.
   - Denominators, link counts, match rates and middle-initial rows are unchanged. The mortality table is byte-identical.
   - `linkage_tables/*.tex` and `figures/deaglan_*.tex` were regenerated in the paper repo, and `linkage_tables/README.md` has a dated note.
4. **Draft updated, numbers only.** Four lines changed, with no rewording or reflow:
   - intro line 107;
   - Section 4.2 lines 576, 577 and 579.

   `check_claims.py` now reports 56 matches and 0 mismatches.
   - Every qualitative claim still holds: verified rises in all six columns, each contradicted-count change keeps its direction, and the contradicted share falls in all six columns.
   - Recall is unchanged at the printed precision.
   - Sections 2 and 4.3 were not touched, and no table note quotes a truth-set size.
5. **Provenance record corrected.**
   - `LINKAGE/notes/truth_file_provenance.md` has a new "Resolved" section.
   - `LINKAGE/DOCUMENTATION.md` and `replication/README.md:80` now describe the truth file as Sam's FamilySearch-profile sample built by `CODE/create_linked_sample_for_MLP_training.do`, not an MLP crosswalk extraction, and describe 18 Aug as a re-save, not a move.

| Prose number | Old | New |
|---|---|---|
| Verified, discordant, exact names | 515,555 → 1,300,253 | 523,399 → 1,320,314 |
| Contradicted, full, JW | 308,848 → 275,442 | 312,746 → 278,940 |
| Contradicted, full, HLINK | 501,010 → 503,357 | 507,261 → 509,706 |
| Contradicted, discordant, exact | 65,148 → 71,863 | 65,907 → 72,769 |
| Contradicted, discordant, HLINK | 116,233 → 125,607 | 117,637 → 127,195 |
| Share contradicted, full, JW / exact | 2.44→2.04 / 2.75→2.33 | 2.47→2.07 / 2.78→2.36 |
| Share contradicted, discordant, JW / exact | 4.07→2.25 / 5.07→2.56 | 4.12→2.27 / 5.13→2.59 |
| Share contradicted, HLINK full / discordant | 0.75→0.74 / 0.76→0.72 | 0.76→0.74 / 0.77→0.73 |

## What machine A needs to do

### 1. Update the gate in `MATCHING/score_fs_links.do` (machine A owns it)

Its hard-coded "paper's numbers" (lines 46–83) are still the **old** values from the damaged file. Now that the paper uses A's file, the gate must compare against the new values, which are A's own.

Replace these, taken from the paper repo's `linkage_tables/linkage_table_abe_jw{,_restricted}.tex`:

| Local | Old | New |
|---|---|---|
| `p_full_ans_ver / unv / con` | 6188445 / 5982941 / 344018 | 6283801 / 5883324 / 348279 |
| `p_full_true_ver / unv / con` | 6690920 / 6482670 / 313846 | 6794104 / 6375502 / 317830 |
| `p_full_add_ver / unv / con` | 1064715 / 1216975 / 80670 | 1081009 / 1199711 / 81640 |
| `p_full_rem_ver / unv / con` | 563429 / 717953 / 108946 | 571902 / 708243 / 110183 |
| `p_restr_ans_ver / unv / con` | 515555 / 703536 / 65148 | 523399 / 694933 / 65907 |
| `p_restr_true_ver / unv / con` | 1300253 / 1432546 / 71863 | 1320314 / 1411579 / 72769 |
| `p_restr_add_ver / unv / con` | 930996 / 984046 / 49946 | 945322 / 969084 / 50582 |
| `p_restr_rem_ver / unv / con` | 147928 / 255723 / 40914 | 150060 / 253120 / 41385 |
| `p_full_ans_recall / p_full_true_recall` | 31.78 / 34.36 | 31.79 / 34.37 |
| `p_restr_ans_recall / p_restr_true_recall` | 11.12 / 28.06 | 11.13 / 28.07 |

- Rates, MI rates and denominators are unchanged.
- Also update the comment at line 157, `(machine B, 2026-10-19: 36,143,407)`, to 36,690,338.
- Better still: read the values from `linkage_tables/` rather than hard-coding them, so this cannot go stale again. That is your call.

Get the change reviewed (`.\review\Run-Review.ps1 -Reviewer both`) and rerun. **The gate should now pass,** because the values are the ones you already produced. If it does not, stop and report. Then continue with the FamilySearch-name scoring the referees asked for.

### 2. Section 4.3 (yours)

As of `3ca56d2`, Section 4.3 quotes no truth-based number. If you add FamilySearch-name Verified, Contradicted or recall figures, they come from A's truth file, which is now the same file the Section 4.2 tables use, so the two sections are consistent.

### 3. Open points, for information

- **When was the id truncated?** Not settled.
  - Your evidence: the pair is the first row of the second missing block.
  - Against it: the 17 Aug log, before the re-save, kept 19,473,337 truth pairs among 1940 men aged 8+, and every later log keeps 19,473,336, which suggests the id was intact until 18 Aug.
  - The provenance note records both views as inferences. Add anything you can establish.
- **Stale diff file:** `DHTS-changes-since-2026-08-28.tex` in the paper repo predates these number changes. Regenerate it if it is still used.
- **Licence cell:** `replication/README.md:80` marks the truth file's data terms "to confirm". The old IPUMS MLP terms no longer apply.

## Review status

- The code switch (`paths.do`, `run_machineB.do`, comments, `hash_inputs_machineB.py`) was reviewed by Codex and Antigravity **before** the rerun, in `review/reports/2026-11-09_171344-*`.
  - Both raised the same two findings, "tables not yet rerun" and "docs stale". Both are dispositioned Fixed.
  - Neither found a defect in the code.
- Everything after that (`8348e8b..ef51a7f`, with the draft) was reviewed by both on 2026-11-10, in `review/reports/2026-11-10_030029-*`. Both confirmed the draft numbers match the regenerated tables and the truth path is consistent across `paths.do`, preflight and manifest. Both raised the same three findings:
  1. **The truth set is selected, but the draft called it "independent".** Addressed in the draft (paper `a545456`, at the author's instruction):
     - "independent" is dropped where it described the truth set (lines 70, 104, 108, 519);
     - one sentence on selection is added in the intro;
     - two sentences are added in Section 4.2. They say the bias would, if anything, favour links built on the existing transcriptions. That is reasoning, not a checked result.

     Still unknown: whether census names were used when FamilySearch profiles were attached to census records. If you can establish how `unique_ID_to_census_crosswalk1930/1940.dta` were built, record it. Revise the Section 4.2 sentences if it changes the picture.
  2. **`check_claims.py` passes with 37 unregistered numbers, all in Section 4.3.** Handed to you; see task 4 below.
  3. **`LINKAGE/DOCUMENTATION.md` results section was stale.** Fixed on B.

### 4. Register Section 4.3 in `claims.toml` (yours)

`check_claims.py` lists 37 result-like numbers in Section 4.3 (draft lines ~658-695, e.g. 20.1%, 22.3%) that no claim covers. It also lists 3 unregistered exhibits: `fs_versions_allstates`, `fs_cells_sizes_allstates` and `fs_cells_allstates`. The gate still exits 0, because unregistered numbers are reported, not failed. These numbers come from your data, so register them and their exhibits on A. Whether unregistered numbers should fail the gate is the author's decision.
