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

## Known issue: Codex review is blocked on this machine

As of 2026-09-12, `Run-Review.ps1` **does not work on this box**. Codex installs,
authenticates, and starts a session, but in non-interactive `codex exec` every
attempt to spawn a process is refused with `CreateProcess ... Rejected ...
blocked by policy`, so it cannot read any file and returns an empty review.

Ruled out, so do not re-test these:

| Suspect | Result |
|---|---|
| OS-level sandbox | Works — `codex sandbox pwsh/cmd/git` all run fine |
| Workspace cloud policy | Only pins a model; no exec restrictions |
| PowerShell 5.1 | Installed 7.6.6 at `C:\Users\hwangii\pwsh7`; Codex used it, still refused |
| Project `.rules` | `--ignore-rules` changed nothing |
| Approval policy | `-c approval_policy="never"` worked once, not reproducibly |
| Missing helpers / antivirus | All helper binaries present; no Defender detections |

What remains is Codex's Windows sandbox layer itself — likely a privileged
one-time setup that cannot run without admin, on an OS (Server 2019, build
17763) that OpenAI does not support. Not fixable from this account.

**The schema earns its keep here.** Because every failed run reported empty
findings *alongside* a populated `review_limits`, the reports read as "could not
review" rather than as a clean bill of health. Never treat an empty findings list
as a pass without reading `review_limits`.

Workarounds, in order of preference: run `codex` interactively (a human answers
the approval prompts that the non-interactive path auto-rejects); or fall back to
copy-paste review packets, which involve no sandbox. The checklists, `SCOPE.md`,
and the severity/disposition discipline work unchanged with either.
