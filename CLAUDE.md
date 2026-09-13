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

## Codex on this machine: use the native binary

`Run-Review.ps1` works. It did not, for most of 2026-09-12, and the cause is
worth knowing because it is invisible from the error messages.

**Root cause: the npm shim.** `npm i -g @openai/codex` puts `codex.ps1` on PATH,
and that shim pipes through node (`$input | & node ...`). The pipe leaves stdio
non-TTY, which breaks Codex two different ways:

- Interactive `codex` refuses to start: `Error: stdout is not a terminal`.
- Non-interactive `codex exec` fails to spawn any subprocess, reporting
  `CreateProcess ... Rejected ... blocked by policy` for powershell, cmd, bash,
  `rg` and `git` alike - so it reads nothing and returns an empty review.

That second message reads like a sandbox or OS-support problem and is not one.
Hours went into chasing it as such. Ruled out along the way, so do not re-test:
the OS-level sandbox (`codex sandbox pwsh/cmd/git` all run fine), the workspace
cloud policy (it only pins a model), PowerShell 5.1 (7.6.6 is installed at
`C:\Users\hwangii\pwsh7`; Codex used it and still failed), `.rules` files, and
antivirus.

**The fix:** call the native `codex.exe` under the npm package's
`vendor\...\bin\`, never the shim. `Run-Review.ps1` resolves this itself, and
that directory is first on the user PATH so bare `codex` also gets the .exe.

Two settings that matter, already in the script: `--sandbox read-only`, and
`-c approval_policy="never"` because a non-interactive run has nobody to answer
an approval prompt.

## Reading a report

`review_limits` is not boilerplate. An empty findings list next to a populated
`review_limits` means *could not review*, not *passed* - that distinction is the
main reason the schema exists.

Codex is wrong often enough to matter, and is most dangerous when confident. On
2026-09-13 it reported, as `major` / `verified`, that the `display` command at
`CODE/comparing_model_transcription_with_anc_fs_SSHA2025.do:62` was invalid
syntax printing nothing. Tested in Stata/MP 15.1: it returns rc=0 and prints all
five values, because a comma in `display` separates directives and adds a space.
The commas are load-bearing - without them the values run together as `10020`.
**Verify Stata-specific findings against Stata before acting.** Batch mode on
Stata 15 is `/b`, not `/e`:

```
& "C:\Program Files (x86)\Stata15\StataMP-64.exe" /b do test.do
```

It leaves a GUI process running after a batch job; close it when done.
