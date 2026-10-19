# Checklist — code correctness

Does the code do what it says? Stata's design is the adversary here: nearly every
item below produces a **wrong number rather than an error message**.

## Merges and joins

- `merge` without `assert()` or a follow-up `_merge` tabulation. Unmatched records
  are silently retained. What share failed to match, and is that share reported?
- `m:1` / `1:m` declared where the data is actually `m:m`. Stata will not always
  complain. Is the "1" side genuinely unique — is there a `isid` or `duplicates`
  check proving it?
- `keep if _merge==3` that quietly redefines the estimation sample. Is the drop
  counted and justified, or does the sample just shrink?
- Merging on a string key with inconsistent case, padding, or encoding.
- A merge whose master/using order determines which source wins a conflict, where
  that choice is not stated.

## Sample construction

- Every `keep if` / `drop if`: does the paper report this restriction? Cumulative
  restrictions rarely match the "N =" in the tables.
- **Missing values are `+infinity`.** `keep if age > 65` retains missing ages.
  `drop if x > 5` drops them. Flag every inequality on a variable that can be
  missing and has no `& !missing(x)`.
- Empty strings: `""==""` evaluates to **true**. Any agreement/equality count over
  name fields must establish that both sides are non-empty, or it inflates
  agreement wherever both transcriptions are blank.
- Loops over geography with entries commented out (e.g. a state removed from the
  list). Is the exclusion deliberate, documented, and reflected in the reported
  sample?
- `cd`-based iteration where a missing directory leaves the working directory
  wrong for subsequent iterations.

## Variable construction

- `egen group()` producing IDs that are not stable across runs or subsamples.
- `replace` before `generate` ordering, so a variable is overwritten mid-pipeline.
- Recodes where the `else` branch silently absorbs unintended categories.
- String-to-numeric via `destring` / `encode` without `force` diagnostics — check
  what failed to convert.
- Accumulator locals inside loops (`local n = `r(N)' + `n'`) where a `count`
  returning zero, or an iteration that errors, corrupts the total silently.

## Estimation

- Clustering level vs. the level treatment actually varies at. Too fine is the
  common error and understates standard errors.
- Fixed effects absorbed twice, or absorbed and also included as dummies.
- Weights: `fweight` vs `pweight` vs `aweight` are not interchangeable. Does the
  weight match what the sampling design implies?
- Regressions run on the wrong sample because a prior `keep` persisted.
- `reghdfe` / `areg` degrees-of-freedom adjustments differing from what is
  reported.

## Stata-specific traps

- `#delimit ;` blocks where a missing `;` silently joins two commands.
- Macro expansion in nested quotes, `` `"`x'"' `` forms, and locals that expand to
  empty because they went out of scope.
- `preserve` / `restore` imbalance inside conditional branches.
- Nonzero `_rc` swallowed by `capture`.
- `set seed` absent anywhere sampling or random assignment occurs.

## Python

- Pandas `merge` defaulting to `how='inner'` where a left join was intended.
- Silent `dtype` coercion on ID columns (leading zeros lost in FIPS codes).
- Exceptions caught and passed over inside download/scrape loops, so partial data
  looks complete.
