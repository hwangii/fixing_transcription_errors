# Review protocol — Claude writes, Codex checks

Project-agnostic. Copy this file, `Run-Review.ps1`, `schema/`, and the checklists
you want into any repo; then rewrite **`SCOPE.md`** only. Nothing here names this
project.

## The loop

```
  Claude Code does work  ──▶  review/Run-Review.ps1  ──▶  Codex reads the repo
         ▲                                                  (read-only sandbox)
         │                                                         │
         └──── Claude reads report, fixes or rebuts ◀── review/reports/*.md
                                                        + *.json (structured)
```

Three properties make this worth the ceremony:

1. **Independence.** Codex is a different model from a different lab. It does not
   inherit Claude's assumptions, and it did not write the code, so it has no
   stake in the code being right.
2. **Read-only.** Codex runs with `-s read-only`. It cannot edit, so a bad review
   costs you attention, never your working tree.
3. **Structured.** Findings come back against a JSON schema, so they can be
   counted, tracked across runs, and closed out — not just read once and lost.

## Running a review

```powershell
# everything not yet committed
.\review\Run-Review.ps1

# a specific commit range
.\review\Run-Review.ps1 -Target "HEAD~3..HEAD"

# specific files, only some dimensions
.\review\Run-Review.ps1 -Target "CODE/clean_ASV5_nber.do" -Scope correctness,replication

# the whole repo, not just a diff (slow; use before submission)
.\review\Run-Review.ps1 -Target full
```

Output lands in `review/reports/<timestamp>-<target>.md` (readable) and
`.json` (structured, schema-validated).

## Severity

Findings are ranked so you can triage under deadline.

| Severity | Means | Response |
|---|---|---|
| `blocker` | A result in the paper is wrong, or would be if this ran. | Fix before anything else. |
| `major` | A referee would demand this. Wrong sample, unsupported claim, broken replication. | Fix before submission. |
| `minor` | Real but survivable. Unclear code, fragile assumption, missing robustness. | Fix if time. |
| `nit` | Style, naming, comments. | Ignore until accepted. |

## Confidence

Codex must mark every finding:

- `verified` — it traced the logic and is stating a fact about the code.
- `likely` — the reading is strongly implied but depends on data it cannot see.
- `speculative` — worth a look, not yet established.

**`speculative` findings are not defects.** They are questions. Treat them as a
list of things to check yourself, and do not let them inflate the finding count.

## Closing the loop

Every finding gets one of three dispositions, recorded in the report's companion
`.md` when Claude responds:

- **Fixed** — with the commit that fixed it.
- **Rebutted** — with the reason the finding is wrong. Codex is not an oracle;
  it misreads Stata macro expansion and cannot see your data. Push back.
- **Accepted risk** — you know, you are not fixing it, here is why.

A finding left with no disposition is the one that reaches the referee.

## Honest limits

- Codex **cannot run the pipeline.** Data is gitignored and often on other
  drives. Everything it says about runtime behaviour is inference from source.
- It will **misread `#delimit ;` blocks and macro expansion** more often than it
  misreads Python. Verify Stata-specific findings before acting.
- It sees only what you point it at. A diff-scoped review cannot catch a problem
  in code the diff did not touch — run `-Target full` periodically.
