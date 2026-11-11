# Handoff to machine B: bring the replication package up to date (2026-11-10)

You are a Claude Code session on **machine B**. This follows `review/handoff_truth_rerun_machineA.md`. Machine A has finished its side of that handoff and has updated its own half of the replication package. This asks you to do the same for B's half.

## Before you start

- Run `.\Sync.ps1 -Pull` and report where the repo stands.
- Pull the Overleaf repo too (`git pull --ff-only`).
- Never commit data.
- `replication/README.md` and `replication/claims.toml` are shared between the machines. Pull immediately before editing them and push immediately after.
- Have any changed do-file or script reviewed before running it: `.\review\Run-Review.ps1 -Reviewer both`. Give every finding a disposition.

## What machine A did today (for information)

| Commit | Repo | What |
|---|---|---|
| `bf7b3d7` | code | `MATCHING/score_fs_links.do`: the gate now uses the paper's new truth-based values. The rerun passed, with 36,690,338 truth pairs. `claims.toml`: Sec 4.3 registered (11 claims, 3 exhibits); 0 unregistered numbers. |
| `4acd317` | paper | Sec 4.3 tables: header comment only. |
| `de0e951` | paper | `DHTS-changes-since-2026-08-28.{tex,pdf}` regenerated. |
| `3bc57ff` | code | External Sec 4.3 reviews committed. |
| (today) | code | Machine A's replication package now produces Tables 9-11 (Sec 4.3); see below. |

**Machine A's package changes:**
- `run_machineA.do`:
  - the preflight now covers 389 inputs;
  - it runs `MATCHING/fs_avg_performance.do` and `MATCHING/fs_cells.do`.
- `Run-MachineA.ps1`:
  - it runs `MATCHING/fs_draft_tables.py` before the claim check;
  - it treats a changed `MATCHING/results/fs_avg_performance.tex` or `fs_cells.tex` as a failure to reproduce.
- `hash_inputs.py` and `input_manifest.md`: the new inputs are hashed.
- README: Tables 9-11 have been added to the exhibit table and the frozen-input table, and the runtime is updated.

None of this touches B's files.

## What machine B needs to do

### 1. Check that the package still resolves on B

```powershell
.\replication\Run-MachineB.ps1 -PreflightOnly
python replication\hash_inputs_machineB.py --check
python replication\check_claims.py
```

Expected results:
- The preflight passes.
- All 17 manifest hashes are unchanged.
- `check_claims.py` reports no MISMATCH and 0 unregistered numbers. The Sec 4.3 claims are machine A's, but they read the paper repo's `figures/fs_*_allstates.tex`, so they check on B too.

If any of these fail, stop and report.

### 2. Bring the README's machine B record up to date

In `replication/README.md`, section "Two machines", the machine B paragraph still describes the **2026-10-19** run on Deaglan's damaged truth file. Update it from your 2026-11-09/10 rerun (`Run-MachineB.ps1`, 258 minutes, on machine A's truth file):

- Give the run date, the runtime and the commit the run used.
- What changed, and why that is expected:
  - only the truth-based rows of Tables 5-8 moved, because the truth file changed;
  - denominators, link counts, match rates and middle-initial rows are unchanged;
  - the mortality table is byte-identical;
  - the ABE columns equal machine A's `score_fs_links.do` exactly.
- The draft numbers this run feeds, and the paper commit (`3ca56d2`).
- **Table numbering.** The mortality table is now **Table 12** (`tab:deaglan_mortality`), because Sec 4.3 added Tables 9-11. Fix every "Tables 5-8 and the mortality table" or "Table 9" reference to it, here and in the README's exhibit table. That table now lists Tables 9-11 (A's); add a Table 12 row for the mortality table (B's).
- Check that the preflight count, "22 inputs", is still right after the truth-path switch.

Change only the machine B parts. Machine A has just edited the frozen-input table, the exhibit table (the Tables 9-11 row) and the runtime paragraph.

### 3. Optional: a reproduction run

The committed tables come from your 2026-11-09/10 run, so a second full run should reproduce them byte-identically. That run takes about 4 hours; do it only if Sam asks. Run `Run-MachineB.ps1`; any changed `figures/deaglan_*.tex` is a failure to reproduce.

### 4. Not for you

The licence cell for the truth file (`replication/README.md`, data table, "To confirm") waits on Sam. Leave it.

## Report back

When done, push. Then give Sam a short summary:
1. the three checks from step 1;
2. what you changed in the README;
3. any review dispositions.
