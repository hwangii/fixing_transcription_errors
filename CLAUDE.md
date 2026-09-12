# CLAUDE.md

## Project

Research code for a paper on fixing transcription errors in US census records
(1930, 1940). An ML model re-transcribes name fields from scanned images; output
is benchmarked against Ancestry (`namefrst`/`namelast`) and FamilySearch
(`fs_namefrst`/`fs_namelast`). Model fields are `namefrst_ml`, `namelast_ml`,
`namelast_ml_ditto`. **Target: submission within a few months of 2026-09-12.**

Data is gitignored and lives on `D:\Dropbox\...` and `F:\...`. Stata is the
analysis language; Python handles image acquisition.

## Independent review by Codex

This repo has a review system in `review/` so that work I produce is checked by a
model from a different lab. **Use it — it is not decoration.**

```powershell
.\review\Run-Review.ps1                                  # uncommitted changes
.\review\Run-Review.ps1 -Target "HEAD~3..HEAD"           # a commit range
.\review\Run-Review.ps1 -Target full -Scope correctness  # whole repo, one dimension
```

Codex runs read-only and returns findings against a JSON schema; reports land in
`review/reports/`. See `review/PROTOCOL.md` for the loop and `review/SCOPE.md`
for what is checked here.

**When to propose a review:** after any non-trivial change to analysis code,
before committing anything that changes a number in the paper, and before
submission (`-Target full`). Offer it; do not run it unprompted on every edit —
each run costs the user's ChatGPT quota.

**When a report comes back:** give every finding a disposition in the report's
Disposition column — Fixed / Rebutted / Accepted risk. Do not silently accept
Codex's findings: it cannot run Stata, cannot see the data, and misreads
`#delimit ;` blocks and macro expansion. Verify before acting, and rebut in
writing when it is wrong.

## Working on this code

Stata's silent failure modes are the main hazard, and they produce wrong numbers
rather than errors:

- Missing `.` is larger than any number — `keep if age>65` retains missing ages.
- `""==""` is true — empty name fields count as agreement unless excluded.
- `merge` without `assert()` hides mismatches.
- `#delimit ;` blocks: a missing `;` silently joins two commands.

Before changing an analysis file, check whether a `V2`/`V3`/`_nber`/`_SSHA2025`
variant is the one actually in use — several near-duplicates exist and only some
are wired into `_master_for_creating_training_dataset.do`.

## Conventions

- Never commit data. The `.gitignore` is deliberately aggressive.
- Do not "fix" hardcoded paths across files without asking — they map to drives
  and Dropbox folders that exist on the author's machine.
- Ask before deleting or consolidating superseded script variants; provenance of
  which file produced which conference version matters.
