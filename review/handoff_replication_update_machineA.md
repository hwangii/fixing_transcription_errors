# Handoff to machine A: machine B's replication update is done (2026-11-11)

You are a Claude Code session on **machine A**. This reports back on `review/handoff_replication_update_machineB.md`. Every step in it is done on machine B except the optional reproduction run.

## Before you start

- Run `.\Sync.ps1 -Pull` and report where the repo stands.
- Pull the Overleaf repo too (`git pull --ff-only`).

## What machine B did

| Commit | Repo | What |
|---|---|---|
| `a545456` | paper | Truth-set wording: "independent" dropped; selection caveats added (author's instruction, 2026-11-10) |
| `9987296` | code | Finding 1 of the 2026-11-10 review marked addressed; the earlier machine A handoff updated |
| `79dea33` | code | README machine B parts; `Run-MachineB.ps1` log fix; DOCUMENTATION source note; review reports |

### 1. Checks on B: all passed

- `Run-MachineB.ps1 -PreflightOnly`: all 22 inputs present. The "22 inputs" in the README is still right after the truth-path switch.
- `hash_inputs_machineB.py --check`: 17 unchanged, 0 changed.
- `check_claims.py`: 63 MATCH, 0 mismatch, 0 unregistered numbers, 17 exhibits registered. Your Section 4.3 registration checks on B too.

### 2. README changes (machine B parts only)

- **"Two machines", machine B paragraph:** the full-run record is now the 2026-11-09 rerun:
  - 258 minutes, on machine A's truth file, code `f8c22d9`, paper `3ca56d2`;
  - only the truth-based rows of Tables 5-8 moved; the mortality table was byte-identical;
  - the ABE columns equal your `score_fs_links.do` exactly.

  The 2026-10-19 run is kept as one sentence of history.
- **Table numbering:**
  - The mortality table is now **Table 12**. It has its own row in the exhibit table, placed after your Tables 9-11 row.
  - The Tables 5-8 row now names its four labels and files explicitly, instead of `deaglan_*`, which would have included the mortality table.
  - The ownership table and the driver usage line also mention Table 12.
- **Corrected:** the driver compares regenerated tables with the paper repo's `linkage_tables/`, not `deaglan_results/current/`. Deaglan's originals stay frozen in `deaglan_results/current/`.
- **Manifest note:** dated 2026-11-09, 66.9 GB, 4 minutes. The replaced truth copy is listed there as superseded.

Your parts are untouched: the frozen-input table, your exhibit rows and the runtime paragraph.

### 3. A lost log, and a driver fix

- My `-PreflightOnly` check **overwrote the only log of the 2026-11-09 full run**. `Run-MachineB.ps1` wrote every run's log to `replication/run_machineB.log`, which is untracked.
- The tables and draft are unaffected.
- The only figures that existed nowhere else were the HLINK pair-change counts (added / removed / changed / unchanged) in `LINKAGE/DOCUMENTATION.md`. They were transcribed the day before, and its source note now says so.
- **Fix:** a preflight-only run now writes `run_machineB_preflight.log`.
- `Run-MachineA.ps1` has no preflight mode, so it is not exposed in the same way. If you ever add one, give it its own log.

### 4. Review

`review/reports/2026-11-11_143021-working-*` (Codex and Antigravity) both raised the same single minor finding: those pair-change counts no longer have a preserved source.

- **Disposition: accepted risk.** The counts are in no draft or table, only in the documentation.
- The denominators beside them do have a tracked source: they are written by `repnum` and checked by `claims.toml`.
- If a full machine B run happens anyway, add `repnum` for the pair-change counts to `LINKAGE/code/02_hlink/linkage_analysis_newlinks.do` first.

## Not done

- **Optional 4-hour reproduction run on B:** not run; only if Sam asks.
- **Licence cell** for the truth file (README data table, "To confirm"): still waiting on Sam.

## For machine A

Nothing from B is blocking you. Two things to know:

- **Section 4.2 wording changed** (paper `a545456`). It now says the truth set covers only people whose FamilySearch profiles are attached to both censuses and who have complete vital dates. It adds that any circularity would tend to favour links built on the existing transcriptions.
  - That last clause is reasoning, not a checked fact.
  - Machine A holds `unique_ID_to_census_crosswalk1930/1940.dta`. If you can establish whether census names were used to attach those profiles, record it in `LINKAGE/notes/truth_file_provenance.md` and tell Sam if it contradicts the sentence.
- If Section 4.3 or your truth-based figures describe the truth set as "independent", they should match the new wording.
