# SCOPE — what Codex checks in THIS project

> **This is the file you rewrite when you move to a different project.**
> `PROTOCOL.md`, `Run-Review.ps1`, and `schema/` stay as they are. Adding a
> dimension means adding a row below and a matching file in `checklists/`.

## Active dimensions

| Key | Checklist | Weight | Why it matters here |
|---|---|---|---|
| `correctness` | `checklists/correctness.md` | **high** | 27k lines of Stata with no test suite. A wrong `merge` or an empty-string comparison changes every number downstream and nothing errors. |
| `claims-vs-code` | `checklists/claims-vs-code.md` | **high** | The paper's headline is an accuracy comparison against Ancestry/FamilySearch. The gap between "agrees with" and "is correct" is exactly where this paper can be attacked. |
| `replication` | `checklists/replication.md` | **medium** | Paths are hardcoded to `D:\Dropbox` and `F:\`. Journals in this field increasingly demand a runnable archive. |
| `identification` | `checklists/identification.md` | **high** | Linked samples are selected, and transcription error affects selection into the link. That circularity is the referee's first question. |

## Project facts Codex should assume

- **Deadline-driven.** Submission is targeted within a few months of 2026-09-12.
  Prefer findings that change a number or a claim over findings that improve
  style. Rank accordingly.
- **Sources, not truth.** Ancestry and FamilySearch are *comparison
  transcriptions*, not ground truth. Any claim of "accuracy" that rests on
  agreement with one of them is a finding, not a nit.
- **Ditto asymmetry.** `namelast_ml_ditto` is ditto-resolved; `namefrst_ml` is
  not. Expressions comparing them jointly should be checked for whether the
  asymmetry is intended.
- **Stata's silent semantics.** Missing `.` is larger than any number;
  `""==""` is true; `merge` without `assert` hides mismatches. These produce
  wrong results without producing errors, so they outrank anything cosmetic.

## Out of scope

Do not report on: code formatting, variable naming, comment density, choice of
Stata idiom where behaviour is identical, or Python style. The author is under
deadline and these cost attention without changing a result.

## Changing scope

Run a subset for a fast pass:

```powershell
.\review\Run-Review.ps1 -Scope correctness
.\review\Run-Review.ps1 -Scope claims-vs-code,identification
```

Omitting `-Scope` runs every dimension in the table above.
