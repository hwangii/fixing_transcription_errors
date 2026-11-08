# Handoff to machine B: what happened to the ground-truth links?

You are a Claude Code session on **machine B**. This is a read-only investigation.

## Before you start

- Run `.\Sync.ps1 -Pull` and tell me where the repo stands.
- Do not modify, move or re-save any truth file.
- Do not commit any data.
- Machine B owns `LINKAGE/`. Your findings go in one small tracked markdown file (see the end), which you push when done.

## The problem

There are two versions of the 1930→1940 "ground truth" links file, and they differ.

**Machine A**
- Path: `F:/fixing_transcription_errors/DATA/INTERMEDIATE/mlp_training1930_1940.dta`.
- Built by `CODE/create_linked_sample_for_MLP_training.do` (in this repo; read it). The do-file:
  - joins FamilySearch-profile crosswalks `unique_ID_to_census_crosswalk1930/1940.dta` from `F:\marital_distance\DATA\ORIGINAL\`;
  - merges `all_profiles.dta` (anon_id) and `anon_id_vital_dates.dta`;
  - keeps profiles with valid birth and death year/month and birth ≤ death;
  - keeps `histid1930 histid1940`.
- Sam (the author) gave this file to Deaglan Jakob, who built the linkage tables.
- What I measured on A on 2026-11-08:
  - Stata's internal save stamp (shown by `describe`): **16 Mar 2026 18:52**;
  - 36,690,338 obs, 2 vars, both `str36`; 2,641,715,872 bytes on disk;
  - one-to-one on both sides, no empty ids;
  - first hex character of `histid1930`, counts:

    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
    |---|---|---|---|---|---|---|---|
    | 2,293,650 | 2,292,842 | 2,297,462 | 2,290,711 | 2,293,975 | 2,295,413 | 2,292,004 | 2,292,990 |

    | 8 | 9 | A | B | C | D | E | F |
    |---|---|---|---|---|---|---|---|
    | 2,295,925 | 2,292,037 | 2,292,808 | 2,290,487 | 2,292,026 | 2,294,844 | 2,293,263 | 2,289,901 |

**Machine B**
- Path: `$REP_LINK/data/truth/mlp_training1930_1940.dta`, i.e. `F:\Deaglan\Census_Transcriptions\data\truth\`.
- Size 2,602,336,840 bytes; sha256 `6b585c82463c880cf14e6c3cd4130ec68d4c64f37185b2568fdf8ac6d491b6ac` (`replication/input_manifest_machineB.md`).
- 36,143,407 pairs, one-to-one (checked 2026-10-19, `LINKAGE/code/01_abe_jw/linkage_analysis.do:107`).
- This is the file behind every Verified / Unverifiable / Contradicted / recall number in the paper's ABE, JW and HLINK tables.

**The difference:** B has **546,931 fewer pairs (1.49%)**. File size per observation is the same on both machines, which is consistent with B being a filtered copy of A.

**Two existing guesses about where B's file came from:**
- `LINKAGE/DOCUMENTATION.md` says it was "almost certainly" extracted from the IPUMS MLP census crosswalk v2.0 (`data/truth/mlp_census_crosswalk_v2_0.stata.zip`), and that the extraction step is missing.
- The file name and A's build script point instead to Sam's FamilySearch-profile file.

One of these is wrong, and the replication README repeats the MLP claim.

## Why it matters

Machine A re-ran Deaglan's ABE scoring (`MATCHING/score_fs_links.do`, which mirrors `LINKAGE/code/01_abe_jw/linkage_analysis.do`) using A's truth file.
- Everything not involving truth reproduces the paper exactly: denominators, link counts, rates and middle-initial validation.
- Every truth-based count is off by about 1.5%.

| | A's truth file | Paper (B's file) |
|---|---|---|
| full, Ancestry: verified | 6,283,801 | 6,188,445 |
| full, Ancestry: unverifiable | 5,883,324 | 5,982,941 |
| full, Ancestry: contradicted | 348,279 | 344,018 |
| full, Ancestry: recall | 31.79 | 31.78 |
| full, ML: verified | 6,794,104 | 6,690,920 |
| restricted, Ancestry: verified | 523,399 | 515,555 |
| restricted, ML: verified | 1,320,314 | 1,300,253 |
| restricted, ML: recall | 28.07 | 28.06 |

Recall is almost unchanged, so the dropped pairs look like a roughly proportional slice rather than a particular kind of link. The FamilySearch-name comparison the referees asked for can't be scored against the paper's numbers until we know which file is right and why they differ.

## What to find out, in order

1. **Fingerprint B's file the same way.**
   - `describe`, and record Stata's internal save stamp. This is the most useful single clue: it says when the file was last saved, regardless of later moves.
   - Any `notes` or data label.
   - N; `duplicates report` on each id and on the pair; empty ids.
   - The same first-hex-character tab of `histid1930`.
   - If every bucket is about 1.49% below A's, that suggests a uniform filter of A. If the buckets are uneven, B is a different extraction.
2. **Find what produced B's file.** Search all of machine B, not just the repo, for:
   - any do-file, log, `.smcl`, notebook or script mentioning `mlp_training`, `mlp_census_crosswalk`, `unique_ID_to_census_crosswalk`, `anon_id` or `vital_dates`;
   - other copies of `mlp_training1930_1940*.dta`, with size, date and sha256 for each;
   - Deaglan's working folders under `F:\Deaglan\` (including old and retired code);
   - the `retired/` and `current/` folders in the Overleaf repo `deaglan_results/`, including `PROVENANCE.md`.

   Report each candidate with path, date, and the lines that read or write the truth file.
3. **Test the filter hypotheses** on B's data, using only B's files:
   - Are B's pairs restricted to ids that exist in the census files Deaglan used? Count how many of B's `histid1940` are in the 1940 men files and how many of B's `histid1930` are in the 1930 files. If B's file is exactly the subset present in some census file, that's the answer.
   - Is the IPUMS MLP crosswalk the source? Check the zip's contents listing only; don't unpack 62 GB unless I approve. Does it have a 1930→1940 pair structure whose count is close to 36,143,407?
   - Is B's file an older or newer build of Sam's script, where the FamilySearch profile inputs changed between versions? The save stamps will help here.
4. **The decisive test needs both files on one machine.** If steps 1–3 don't settle it, tell me how to get A's file (2.6 GB) onto B, for example via Dropbox or a shared drive. Then:
   - merge the two on `histid1930 histid1940`;
   - report how many pairs are in both, A only and B only;
   - for pairs in only one file, show whether the same `histid1930` appears with a different partner.

   Don't use git for this; data never goes through git.

## Output

Write your findings to `LINKAGE/notes/truth_file_provenance.md`.
- For each conclusion, say whether it is **confirmed by data** or **inferred**.
- If you find that `LINKAGE/DOCUMENTATION.md` or `replication/README.md` misstate the provenance, list the corrections as proposals. Don't edit those files yet.
- Push with `.\Sync.ps1 -Push -Message "LINKAGE/notes: truth-file provenance investigation"`.
- Then give me a short summary: which file the paper used, what was done to it, and whether machine A should switch to B's file for scoring.
